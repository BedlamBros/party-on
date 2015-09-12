'use strict';

/**
 * Module dependencies.
 */
var mongoose = require('mongoose'),
  User = mongoose.model('User'),
  FBLogin = mongoose.model('FBLogin'),
  async = require('async'),
  config = require('meanio').loadConfig(),
  crypto = require('crypto'),
  nodemailer = require('nodemailer'),
  templates = require('../template'),
  request   = require('request'),
  _ = require('lodash'),
  jwt = require('jsonwebtoken'); //https://npmjs.org/package/node-jsonwebtoken



/**
 * Send reset password email
 */
function sendMail(mailOptions) {
    var transport = nodemailer.createTransport(config.mailer);
    transport.sendMail(mailOptions, function(err, response) {
        if (err) return err;
        return response;
    });
}



module.exports = function(MeanUser) {
    return {
        /**
         * Auth callback
         */
        authCallback: function(req, res) {
          var payload = req.user;
          var escaped = JSON.stringify(payload);      
          escaped = encodeURI(escaped);
          // We are sending the payload inside the token
          var token = jwt.sign(escaped, config.secret, { expiresInMinutes: 60*5 });
          res.cookie('token', token);
          var destination = config.strategies.landingPage;
          if(!req.cookies.redirect)
            res.cookie('redirect', destination);
          res.redirect(destination);
        },

        /**
         * Show login form
         */
        signin: function(req, res) {
          if (req.isAuthenticated()) {
            return res.redirect('/');
          }
          res.redirect('/login');
        },

        /**
         * Logout
         */
        signout: function(req, res) {

            MeanUser.events.publish({
                action: 'logged_out',
                user: {
                    name: req.user.name
                }
            });

            req.logout();
            res.redirect('/');
        },

        /**
         * Session
         */
        session: function(req, res) {
          res.redirect('/');
        },

        /**
         * Create user
         */
        create: function(req, res, next) {
            var user = new User(req.body);

            user.provider = 'local';

            // because we set our user.provider to local our models/user.js validation will always be true
            req.assert('name', 'You must enter a name').notEmpty();
            req.assert('email', 'You must enter a valid email address').isEmail();
            req.assert('password', 'Password must be between 8-20 characters long').len(8, 20);
            req.assert('username', 'Username cannot be more than 20 characters').len(1, 20);
            req.assert('confirmPassword', 'Passwords do not match').equals(req.body.password);

            var errors = req.validationErrors();
            if (errors) {
                return res.status(400).send(errors);
            }

            // Hard coded for now. Will address this with the user permissions system in v0.3.5
            user.roles = ['authenticated'];
            user.save(function(err) {
                if (err) {
                    switch (err.code) {
                        case 11000:
                        case 11001:
                        res.status(400).json([{
                            msg: 'Username already taken',
                            param: 'username'
                        }]);
                        break;
                        default:
                        var modelErrors = [];

                        if (err.errors) {

                            for (var x in err.errors) {
                                modelErrors.push({
                                    param: x,
                                    msg: err.errors[x].message,
                                    value: err.errors[x].value
                                });
                            }

                            res.status(400).json(modelErrors);
                        }
                    }
                    return res.status(400);
                }

                var payload = user;
                payload.redirect = req.body.redirect;
                var escaped = JSON.stringify(payload);
                escaped = encodeURI(escaped);
                req.logIn(user, function(err) {
                    if (err) { return next(err); }

                    MeanUser.events.publish({
                        action: 'created',
                        user: {
                            name: req.user.name,
                            username: user.username,
                            email: user.email
                        }
                    });

                    // We are sending the payload inside the token
                    var token = jwt.sign(escaped, config.secret, { expiresInMinutes: 60*5 });
                    res.json({ token: token });
                });
                res.status(200);
            });
        },
        /**
         * Send User
         */
        me: function(req, res) {
            if (!req.user || !req.user.hasOwnProperty('_id')) return res.send(null);

            User.findOne({
                _id: req.user._id
            }).exec(function(err, user) {

                if (err || !user) return res.send(null);


                var dbUser = user.toJSON();
                var id = req.user._id;

                delete dbUser._id;
                delete req.user._id;

                var eq = _.isEqual(dbUser, req.user);
                if (eq) {
                    req.user._id = id;
                    return res.json(req.user);
                }

                var payload = user;
                var escaped = JSON.stringify(payload);
                escaped = encodeURI(escaped);
                var token = jwt.sign(escaped, config.secret, { expiresInMinutes: 60*5 });
                res.json({ token: token });
               
            });
        },

        /**
         * Find user by id
         */
        user: function(req, res, next, id) {
            User.findOne({
                _id: id
            }).exec(function(err, user) {
                if (err) return next(err);
                if (!user) return next(new Error('Failed to load User ' + id));
                req.profile = user;
                next();
            });
        },

	/**
	 * Ensure that a purported FB user accessToken actually belongs to the user and is active
	 */
	verifyFBToken: function(req, res, next) {
	async.waterfall([
	  function(cb) {
	    /*
	     * Expect req to be of form {"user_id": USER_ID, "access_token": ACCESS_TOKEN}
	     * where user_id is the app-scoped userId and access_token is the purported
	     * access token owned by the user
	     */
	    if (!req.body.user_id || !req.body.access_token) {
	      // request did not have necessary parameters
	      return cb(new Error('request must specify user_id and access_token'));
	    }
	    //var fbEndpoint = 'https://graph.facebook.com/oauth/access_token';
	    var fbVerifyEndpoint = 'https://graph.facebook.com/debug_token';
	    request({url: fbVerifyEndpoint, qs: {
	      //client_id: config.strategies.facebook.clientID,
	      //client_secret: config.strategies.facebook.clientSecret,
	      //grant_type: 'client_credentials'
	      access_token: config.strategies.facebook.clientID + '|' + config.strategies.facebook.clientSecret,
	      input_token: req.body.access_token
	    }}, function(err, resp, body) {
	      if (err) return cb(err);
	      if (resp.statusCode != 200) {
		return cb(new Error('Could not validate authenticity of token from facebook'));
	      }
	      return cb(null, JSON.parse(body));
	    });
	  },
	  function(debugTokenResponse, cb) {
	    debugTokenResponse = debugTokenResponse.data;
	    if (!debugTokenResponse.is_valid || req.body.user_id != debugTokenResponse.user_id) {
	      return cb(new Error('Token is not considered valid for this user'));
	    }
	    // facebook says this token is good for this user
	    cb();
	  }
	],
          function(err, result) {
	    if (err) return res.status(401).send(err.toString());
	    return next();
	  });
	},
	/**
	 * Attempt to get a User by their facebook login info. If user doesn't exist or their access_token expired, update them in the database. NOTE: Assumes req.body.user_id and req.body.access_token are values from facebook that are KNOWN TO BE VALID
	 */
	getOrCreateFB: function(req, res) {
	    async.waterfall([
	      function(cb) {
		if (!req.body.user_id || !req.body.access_token) {
		  return cb(new Error('facebook user_id and access_token must be present in request body'));
		}
		FBLogin.findOne({
		  userId: req.body.user_id
		})
		.exec(function(err, fbLogin) {
		  if (err) return cb(err);
		  if (!fbLogin) return cb(null, null);
		  User.findOne({
		    'facebook': fbLogin._id
		  })
		  .populate('facebook')
		  .exec(cb);
		});
	      },
	      function(user, cb) {
		if (!user) {
		  // user does not exist for this user_id
		  var newFBLogin = new FBLogin({
		      userId: req.body.user_id,
		      accessToken: req.body.access_token
		  });
		  newFBLogin.save(function(err, fbLogin) {
		    if (err) return cb(err);
		    var newUser = new User({
		      name: 'Name NotImplemented',
		      email: 'facebook-' + req.body.user_id + '@fuckoff.com',
		      username: 'facebook-' + req.body.user_id,
		      provider: 'facebook',
		      facebook: fbLogin
		    });
		    return newUser.save(cb);
		  });
		} else {
		  // user already exists
		  if (user.facebook && user.facebook.access_token == req.body.access_token) {
		    // user access token matches current facebook access_token
		    return cb(null, user);
		  } else {
		    // user exists, but access_token has changed
		    console.log('user exists, but access_token changed');
		    user.facebook.accessToken = req.body.access_token;
		    return user.facebook.save(function(err, fblogin) {
		      return cb(err, user);
		    });
		  }
		}
	      }
	    ], function(err, result) {
	      if (err) console.log(err);
	      if (err) return res.status(500).send(err.toString());
	      return res.json(result);
	    });
	},
        /**
         * Resets the password
         */
        resetpassword: function(req, res, next) {
            User.findOne({
                resetPasswordToken: req.params.token,
                resetPasswordExpires: {
                    $gt: Date.now()
                }
            }, function(err, user) {
                if (err) {
                    return res.status(400).json({
                        msg: err
                    });
                }
                if (!user) {
                    return res.status(400).json({
                        msg: 'Token invalid or expired'
                    });
                }
                req.assert('password', 'Password must be between 8-20 characters long').len(8, 20);
                req.assert('confirmPassword', 'Passwords do not match').equals(req.body.password);
                var errors = req.validationErrors();
                if (errors) {
                    return res.status(400).send(errors);
                }
                user.password = req.body.password;
                user.resetPasswordToken = undefined;
                user.resetPasswordExpires = undefined;
                user.save(function(err) {

                    MeanUser.events.publish({
                        action: 'reset_password',
                        user: {
                            name: user.name
                        }
                    });

                    req.logIn(user, function(err) {
                        if (err) return next(err);
                        return res.send({
                            user: user
                        });
                    });
                });
            });
        },

        /**
         * Callback for forgot password link
         */
        forgotpassword: function(req, res, next) {
            async.waterfall([

                function(done) {
                    crypto.randomBytes(20, function(err, buf) {
                        var token = buf.toString('hex');
                        done(err, token);
                    });
                },
                function(token, done) {
                    User.findOne({
                        $or: [{
                            email: req.body.text
                        }, {
                            username: req.body.text
                        }]
                    }, function(err, user) {
                        if (err || !user) return done(true);
                        done(err, user, token);
                    });
                },
                function(user, token, done) {
                    user.resetPasswordToken = token;
                    user.resetPasswordExpires = Date.now() + 3600000; // 1 hour
                    user.save(function(err) {
                        done(err, token, user);
                    });
                },
                function(token, user, done) {
                    var mailOptions = {
                        to: user.email,
                        from: config.emailFrom
                    };
                    mailOptions = templates.forgot_password_email(user, req, token, mailOptions);
                    sendMail(mailOptions);
                    done(null, user);
                }
            ],
            function(err, user) {

                var response = {
                    message: 'Mail successfully sent',
                    status: 'success'
                };
                if (err) {
                    response.message = 'User does not exist';
                    response.status = 'danger';

                }
                MeanUser.events.publish({
                    action: 'forgot_password',
                    user: {
                        name: req.body.text
                    }
                });
                res.json(response);
            });
        }
    };
}

