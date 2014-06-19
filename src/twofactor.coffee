# Description:
#   Accepts a POST request via webhook from the twillio service.
#
# Dependencies:
#   "twilio": "~1.6.0"
#
# Commands:
#   TWILIO_ACCOUNT_SID
#   TWILIO_AUTH_TOKEN
#   HUBOT_TWOFACTOR_ROOM
#
# URLs:
#   POST /hubot/sms/twofactor
#
# Author:
#   delianides
#

twilio = require('twilio')()

module.exports = (robot) ->
  robot.router.post '/hubot/sms/twofactor', (req, res) ->
    room = process.env.HUBOT_TWOFACTOR_ROOM
    messageId = req.body.MessageSid

    twilio.getSms messageId, (error, sms) ->
      robot.send room, "#{sms.body}"

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'




