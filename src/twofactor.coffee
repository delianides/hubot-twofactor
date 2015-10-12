# Description:
#   Accepts a POST request via webhook from the twillio service.
#
# Dependencies:
#   "twilio": "~1.6.0",
#   "valid-url": "1.0.9"
#
# Configuration:
#   TWILIO_ACCOUNT_SID
#   TWILIO_AUTH_TOKEN
#   HUBOT_TWOFACTOR_ROOM
#   HEROKU_URL
#
# Commands:
#   hubot 2fa number, displays the number that will be contacted
#   hubot 2fa set response <message>, A message that is played back when someone calls.
#   hubot 2fa set urls, Sets the URLs in twilio for the specified number.
#
# URLs:
#   POST /hubot/sms/twofactor
#   GET /hubot/call/twofactor
#
# Author:
#   delianides
#

if process.env.TWILIO_ACCOUNT_SID and process.env.TWILIO_AUTH_TOKEN
  twilio = require('twilio')(process.env.HUBOT_TWILIO_ACCOUNT_SID, process.env.HUBOT_TWILIO_AUTH_TOKEN)
else
  return false

url = require('valid-url')

module.exports = (robot) ->
  robot.respond /2fa number/i, (msg) ->
      twilio.incomingPhoneNumbers.list({ friendlyName: 'hubot-2fa', }).then (results) ->
        msg.send "Set Two Factor Authentication: #{results.incoming_phone_numbers[0].phone_number}"

  robot.respond /2fa set response (.*)/i, (msg) ->
    response = msg.match[1]
    robot.brain.set 'twilioTwofactorResponse', msg.match[1]
    msg.reply 'Ok, Your response is set to: "'+robot.brain.get('twilioTwofactorResponse')+'"'

  robot.respond /2fa set urls/i, (msg) ->
    if process.env.HEROKU_URL is '' or process.env.HEROKU_URL is null
      msg.send "HEROKU_URL config is not set."
      return false
    else
      twilio.incomingPhoneNumbers.list({ friendlyName: 'hubot-2fa', }).then (results) ->
        urls = {
            smsMethod: "POST",
            smsUrl: "#{process.env.HEROKU_URL}/hubot/sms/twofactor",
            voiceMethod: "GET",
            voiceUrl: "#{process.env.HEROKU_URL}/hubot/call/twofactor"
          }

        twilio.incomingPhoneNumbers(results.incoming_phone_numbers[0].sid).update urls, (error, data) ->
          if error
            msg.send "There was an error with Twilio!"
          else
            msg.send "Twilio webhook URLs have been updated!"


  robot.router.get '/hubot/call/twofactor', (req, res) ->
    twiml = robot.brain.get('twilioTwofactorResponse')

    if twiml is null or twiml is ''
      twiml = "Thanks, but no one is at this number. Have a nice day!"

    twilio = require('twilio')
    resp = new twilio.TwimlResponse()
    if url.isWebUri(twiml)
      resp.play(twiml)
    else
      resp.say(twiml)
    res.writeHead 200, {'Content-type': 'text/xml'}
    res.end resp.toString()

  robot.router.post '/hubot/sms/twofactor', (req, res) ->
    room = process.env.HUBOT_TWOFACTOR_ROOM
    messageId = req.body.MessageSid

    twilio.getSms messageId, (error, sms) ->
      robot.send room, "#{sms.body}"

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'
