'use strict';
var mongoose = require('mongoose'),
  async = require('async'),
  User = mongoose.model('User'),
  FBLogin = mongoose.model('FBLogin'),
  _ = require('lodash');


var findUser = exports.findUser = function(id, cb) {
  User.findOne({
        _id: id
    }, function(err, user) {
        if (err || !user) return cb(null);
        cb(user);
    });
};


/**
 * Generic require login routing middleware
 */
exports.requiresLogin = function(req, res, next) {
  if (!req.isAuthenticated()) {
    // attempt to authorize user with provided strategy
    var authHeader = req.headers['authorization'];
    var authStrategy = req.headers['passport-auth-strategy'];
    if (authHeader && authStrategy) {
      var splitUp = authHeader.split(' ');
      if (splitUp.length == 2 && splitUp[0].toLowerCase() == 'bearer') {
	// using the bearer strategy
	var token = splitUp[1];
	switch(authStrategy.toLowerCase()) {
	  case 'facebook':
	    return async.waterfall([function(cb) {
	      return FBLogin.findOne({accessToken: token}, cb);
	      },
	      function(tokenRecord, cb) {
		if (!tokenRecord) return cb(new Error('Could not find facebook with that token'));
		return User.findOne({facebook: tokenRecord._id})
		  .populate('facebook')
		  .exec(cb);
	      }], function(err, user) {
		if (err) return res.status(401).send(err.toString());
		if (!user) return res.status(401).send(new Error('Could not find a user for this token'));
		req.user = user;
		return next();
	      });
	    break;
	  default:
	    // couldn't find a supported token strategy, oh well
	    break;
	}
      }
    }
    return res.status(401).send('User is not authorized');
  }

  findUser(req.user._id, function(user) {
      if (!user) return res.status(401).send('User is not authorized');
      req.user = user;
      next();
  });
};


/**
 * Generic require Admin routing middleware
 * Basic Role checking - future release with full permission system
 */
exports.requiresAdmin = function(req, res, next) {
  if (!req.isAuthenticated()) {
    return res.status(401).send('User is not authorized');
  }
  findUser(req.user._id, function(user) {
      if (!user) return res.status(401).send('User is not authorized');

      if (req.user.roles.indexOf('admin') === -1) return res.status(401).send('User is not authorized');
      req.user = user;
      next();
  });
};

/**
 * Generic validates if the first parameter is a mongo ObjectId
 */
exports.isMongoId = function(req, res, next) {
  if ((_.size(req.params) === 1) && (!mongoose.Types.ObjectId.isValid(_.values(req.params)[0]))) {
      return res.status(500).send('Parameter passed is not a valid Mongo ObjectId');
  }
  next();
};
