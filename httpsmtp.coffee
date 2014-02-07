express = require "express"
nodemailer = require "nodemailer"
logger = require('caterpillar').createLogger()
human = require('caterpillar-human').createHuman()
logger.pipe(human).pipe require('fs').createWriteStream './debug.log'

app = express()
app.use express.json()
app.use express.urlencoded()
app.use require('express-validator')()

# create reusable transport method (opens pool of SMTP connections)
smtpTransport = nodemailer.createTransport "SMTP",
	host: "mail.google.com"
	port: 25

### setup e-mail data with unicode symbols
mailOptions =
    from: "Fred Foo ✔ <foo@blurdybloop.com>" # sender address
    to: "bar@blurdybloop.com, baz@blurdybloop.com" # list of receivers
    subject: "Hello ✔" # Subject line
    text: "Hello world ✔" # plaintext body
    html: "<b>Hello world ✔</b>" # html body
###
    # if you don't want to use this transport object anymore, uncomment following line
    # smtpTransport.close(); # shut down the connection pool, no more messages

app.post "/send-email", (req, res) ->
	req.sanitize('from').toString()
	req.sanitize('to').toString()
	req.sanitize('subject').toString()
	req.sanitize('text').toString()
	req.sanitize('html').toString()
	
	# send mail with defined transport object
	smtpTransport.sendMail req.body, (error, response) ->
	    if error
	    	logger.log "alert", error
	    	res.json 300,
	    		result: error
	    else
	    	logger.log "info", "Message sent: #{response.message}"
	    	res.json 200,
	    		result: response.message

port = process.env.PORT or 5000
app.listen port, 'localhost', -> #only listen to local requests
	logger.log "info", "Starting up and listening on #{port}"