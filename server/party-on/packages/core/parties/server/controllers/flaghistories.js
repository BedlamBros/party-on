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

module.exports = function(FlagHistories) {
  return {
    raise: function(req, res) {
      FlagHistory.registerComplaint(req.party,req.body.complaint, function(err, status) {
	if (err) return res.status(500).send(err);
	return res.json(status);
      });
    }
  };
};
