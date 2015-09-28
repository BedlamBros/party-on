'use strict';

var path = require('path'),
  rootPath = path.normalize(__dirname + '/../..');

module.exports = {
  root: rootPath,
  http: {
    port:  3001
  },
  https: {
    port: false,

    // Paths to key and cert as string
    ssl: {
      key: '',
      cert: ''
    }
  },
  hostname: process.env.HOST || process.env.HOSTNAME,
  db: process.env.MONGOHQ_URL,
  templateEngine: 'swig',

  // The secret should be set to a non-guessable string that
  // is used to compute a session hash
  sessionSecret: 'MEAN',

  // The name of the MongoDB collection to store sessions in
  sessionCollection: 'sessions',

  // The session cookie settings
  sessionCookie: {
    path: '/',
    httpOnly: true,
    // If secure is set to true then it will cause the cookie to be set
    // only when SSL-enabled (HTTPS) is used, and otherwise it won't
    // set a cookie. 'true' is recommended yet it requires the above
    // mentioned pre-requisite.
    secure: false,
    // Only set the maxAge to null if the cookie shouldn't be expired
    // at all. The cookie will expunge when the browser is closed.
    maxAge: null
  },
  /**
  * Relevant Facebook app secrets are stored here. These should never
  * be visible in plaintext.
  */
  strategies: {
    facebook: {
      "clientID": "127159637632248", //is this the same as the app_id?
      "clientSecret": "1020894c3f6aeeda2b5ab661ab03effb",
      "callbackURL": ""
    }
  },
  public: {
    languages: [{
      locale: 'en',
      direction: 'ltr',
    }, {
      locale: 'he',
      direction: 'rtl',
    }],
    currentLanguage: 'en',
    cssFramework: 'bootstrap'
  },
  // The session cookie name
  sessionName: 'connect.sid'
};
