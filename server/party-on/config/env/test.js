'use strict';

module.exports = {
  db: 'mongodb://' + (process.env.DB_PORT_27017_TCP_ADDR || 'localhost') + '/party-on-test',
  http: {
    port: 3002
  },
  aggregate: false,
  assets: {
    hash: false
  },
  logging: {
    format: 'common'
  },
  hostname: 'http://localhost:3001',
  app: {
    name: 'MEAN - A Modern Stack - Test'
  },
  testUsers: {
    // permanent test users that should not be deleted
    facebook: {
      userId: '135895850095335',
      accessToken: 'CAABzpqkH5PgBAGTPOu8OJ5GfOXE728RJWmtUbKIDReoBOXLdFZAkURiSO77aFRN2usmM8L7dwjBwo9jDWwGZAodPZAxZAqnG5iwnUALMT5uuCFGfvcWDIwKle4AEZBS3uTDeGc78doMs16xQSziVZCOonOMzqhbNf8hRtdpG1ZBKRO9wdk0X28NsV4kAhZBvIvUoI99GuST4agZDZD'
    }
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
      clientID: 'CONSUMER_KEY',
      clientSecret: 'CONSUMER_SECRET',
      callbackURL: 'http://localhost:3000/auth/twitter/callback',
      enabled: false
    },
    github: {
      clientID: 'APP_ID',
      clientSecret: 'APP_SECRET',
      callbackURL: 'http://localhost:3000/auth/github/callback',
      enabled: false
    },
    google: {
      clientID: 'APP_ID',
      clientSecret: 'APP_SECRET',
      callbackURL: 'http://localhost:3000/auth/google/callback',
      enabled: false
    },
    linkedin: {
      clientID: 'API_KEY',
      clientSecret: 'SECRET_KEY',
      callbackURL: 'http://localhost:3000/auth/linkedin/callback',
      enabled: false
    }
  },
  emailFrom: 'SENDER EMAIL ADDRESS', // sender address like ABC <abc@example.com>
  mailer: {
    service: 'SERVICE_PROVIDER',
    auth: {
      user: 'EMAIL_ID',
      pass: 'PASSWORD'
    }
  },
  secret: 'SOME_TOKEN_SECRET'
};
