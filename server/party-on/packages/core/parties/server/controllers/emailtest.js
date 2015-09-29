'use strict';

/**
 * Module dependencies.
 */
var nodemailer = require('nodemailer'),
    sesTransport = require('nodemailer-ses-transport');

var transport = nodemailer.createTransport(sesTransport({
    accessKeyId: "AKIAJHZYHGSOB7VOYKMQ",
    secretAccessKey: "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",
    serviceUrl: 'email-smtp.us-west-2.amazonaws.com',
    region: 'us-west-2',
    rateLimit: 5 // do not send more than 5 messages in a second
}));

var subjectline = 'Flagged Party Received - ' + new Date().toString();

var mailOptions = {
    from: 'bedlamcorp.llc@gmail.com',
    to: 'bedlamcorp.llc@gmail.com',
    subject: subjectline,
    text: 'This is a test'
}

transport.sendMail(mailOptions, function(error, info){
    if (error){
	console.log("error on send");
        return console.log(error);
    }
    console.log('Message sent: ' + info.response);
});
