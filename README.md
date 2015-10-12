Hubot 2FA
=========

[Two Factor Authentication](https://en.wikipedia.org/wiki/Two-factor_authentication) is a really great and easy way to secure the important services we use everyday. Most of the popular services (Github, Dropbox, Gmail, etc) support 2fa and recommend its use. However, occasionally there are some services that don't allow for different users to be defined under the same account (Twitter, NameCheap). This tool simply acts as a group based 2fa system where you create a [Twilio](http://twilio.com) phone number and add the hubot urls as phone/sms webhooks under that number. Then you use the phone number as a 2fa method for which ever service you choose. The output from twilio is unchanged so there isn't any confusion about which service the token goes to. 

**NOTE: I am aware this slightly goes against 2FA methodology. I don't recommend using this setup for something that manages payment information or sensative data. If a service does allow for multiple users then don't be lazy and create the appropirate access accounts for your team.**
