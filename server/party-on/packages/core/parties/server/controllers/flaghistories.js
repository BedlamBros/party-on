'use strict';

/**
 * Module dependencies.
 */
var mongoose = require('mongoose'),
    async = require('async'),
    Party = mongoose.model('Party'),
    FlagHistory = mongoose.model('FlagHistory'),
    config = require('meanio').loadConfig(),
    _ = require('underscore');

// Number of unique party complaints to get you banned
var BAN_COMPLAINT_THRESHOLD = 3;
// Number of complaints that, if made against
// any single party of yours, gets you banned immediately
var ABSURD_SINGLE_PARTY_THRESHOLD = 10;

module.exports = function(FlagHistories) {
  return {
    raise: function(req, res) {
      FlagHistory.registerComplaint(req.party, req.body.complaint, function(err, status) {
	if (err) return res.status(500).send(err);
	return res.json(status);
      });
    },
    isBanned: function(req, res) {
      async.waterfall([
	function(cb) {
	  FlagHistory.findOne({user: req.user}, cb);
	},
	function(flagHistory, cb) {
	  var banned = false;
	  if (!flagHistory) {
	    // no complaints filed at all
	    banned = false;
	  } else {
	    // tally up complaints against this user
	    var complaints = {};
	    _.forEach(flagHistory.flags, function(flagId) {
	      var existingCount = complaints[flagId];
	      // init existingCount to 0 if it is a falsey value
	      existingCount = (existingCount) ? existingCount : 0;
	      complaints[flagId] = existingCount + 1;
	    });
	    if (_.keys(complaints).length >= BAN_COMPLAINT_THRESHOLD) {
	      // three different party complaints, you're out
	      banned = true;
	    } /* TODO: decide if we want to implement the 'horrible party' rule
	       else {
	      banned = _.find(complaints, function(count, partyId) {
		// you had a really awful party, banned
		return count >= ABSURD_SINGLE_PARTY_THRESHOLD;
	      });
	    }*/
	  }
	  cb(null, banned);
	}], function(err, isBanned) {
	  if (err) return res.status(500).send(err);
	  return res.json({banned: isBanned});
	});
      }
  };
};
