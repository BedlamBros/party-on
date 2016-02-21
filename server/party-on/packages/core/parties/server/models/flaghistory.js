'use strict';

/**
 * Module dependencies.
 */
var mongoose = require('mongoose'),
  Schema = mongoose.Schema,
  async = require('async'),
  _ = require('underscore');

/**
 * Individual Flag Schema 
 */

var FlagSchema = new Schema({
  party: {
    type: Schema.ObjectId,
    ref: 'Party',
    required: true
  },
  complaint: {
    type: String,
    maxlength: 500
  }
});

/**
 * Flag History Schema
 */
var FlagHistorySchema = new Schema({
  user: {
    type: Schema.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  flags: [{
    type: Schema.ObjectId,
    ref: 'Flag'
  }]
});

/**
 * Validations
 */
FlagSchema.path('party').validate(function(partyRef) {
  return !!partyRef;
});

FlagHistorySchema.path('user').validate(function(userRef) {
  return !!userRef;
}, 'User cannot be null');

/**
 * Statics
 */
FlagHistorySchema.statics.registerComplaint = function(party, complaint, callback) {
  var FlagHistory = mongoose.model('FlagHistory');
  var Flag = mongoose.model('Flag');
  async.waterfall([
    function(cb) {
      var flagRecordIfNotExists = new FlagHistory({
	user: party.user,
	flags: []
      });
      // try to insert a record for user, will probably fail
      // because user already exists here
      flagRecordIfNotExists.save(function(err, updateResult) {
	// hide unique violations silently
	return cb(null);
      });
    },
    function(cb) {
      var flag = new Flag({
	party: party,
	complaint: complaint
      });
      flag.save(function(err) {
	return cb(err, flag);
      });
    },
    function(flag, cb) {
      FlagHistory.update(
	{user: party.user},
	{$push: {flags: flag}}, cb);
    }],
    function(err, updateDetails) {
      // pass dumb object, NOT actual FlagHistory object
      return callback(err, {status: 'ok'});
    });
};

mongoose.model('Flag', FlagSchema);
mongoose.model('FlagHistory', FlagHistorySchema);
