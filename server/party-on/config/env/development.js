'use strict';

module.exports = {
  db: 'mongodb://' + (process.env.DB_PORT_27017_TCP_ADDR || 'localhost') + '/party-on-test',
  debug: true,
  logging: {
    format: 'tiny'
  },
  //  aggregate: 'whatever that is not false, because boolean false value turns aggregation off', //false
  aggregate: false,
  mongoose: {
    debug: false
  },
  http: {
    port: 80
  },
  hostname: 'http://localhost:80',
  app: {
    name: 'The Docket - Get to the party faster, safer, and easier'
  },
  strategies: {
    local: {
      enabled: true
    },
    landingPage: '/',
    facebook: {
      clientID: '127159637632248',
      clientSecret: '195b073dc2194ae6b6fc2c5b1d198fdf',
      callbackURL: 'http://ec2-52-10-210-220.us-west-2.compute.amazonaws.com/api/auth/facebook/callback',
      enabled: true
    },
    twitter: {
      clientID: 'DEFAULT_CONSUMER_KEY',
      clientSecret: 'CONSUMER_SECRET',
      callbackURL: 'http://localhost:3000/api/auth/twitter/callback',
      enabled: false
    },
    github: {
      clientID: 'DEFAULT_APP_ID',
      clientSecret: 'APP_SECRET',
      callbackURL: 'http://localhost:3000/api/auth/github/callback',
      enabled: false
    },
    google: {
      clientID: 'DEFAULT_APP_ID',
      clientSecret: 'APP_SECRET',
      callbackURL: 'http://localhost:3000/api/auth/google/callback',
      enabled: false
    },
    linkedin: {
      clientID: 'DEFAULT_API_KEY',
      clientSecret: 'SECRET_KEY',
      callbackURL: 'http://localhost:3000/api/auth/linkedin/callback',
      enabled: false
    }
  },
  emailFrom: 'SENDER EMAIL ADDRESS', // sender address like ABC <abc@example.com>
  mailer: {
    service: 'SERVICE_PROVIDER', // Gmail, SMTP
    auth: {
      user: 'EMAIL_ID',
      pass: 'PASSWORD'
    }
  }, 
  secret: 'SOME_TOKEN_SECRET'
};
