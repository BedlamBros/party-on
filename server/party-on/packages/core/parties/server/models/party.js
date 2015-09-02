'use strict';

/**
 * Module dependencies.
 */
var mongoose = require('mongoose'),
  Schema = mongoose.Schema,
  _ = require('underscore');

var supportedUniversities = ['Indiana University'];

/**
 * Party Schema
 */
var PartySchema = new Schema({
  created: {
    type: Date,
    default: Date.now
  },
  formattedAddress: {
    type: String,
    required: true
  },
  latitude: {
    type: Number,
    required: true,
    min: -180.0,
    max: 180.0
  },
  longitude: {
    type: Number,
    required: true,
    min: -180.0,
    max: 180.0
  },
  maleCost: {
    type: Number,
    required: true,
    default: 0,
    min: 0
  },
  femaleCost: {
    type: Number,
    required: true,
    default: 0,
    min: 0
  },
  startTime: {
    type: Date,
    required: true
  },
  byob: {
    type: Boolean,
    required: true,
    default: true
  },
  colloquialName: {
    type: String,
    required: false,
    maxlength: 50
  },
  description: {
    type: String,
    required: false,
    maxlength: 256
  },
  endTime: {
    type: Date,
    required: false
  },
  user: {
    type: Schema.ObjectId,
    required: true,
    ref: 'User'
  },
  university: {
    type: String,
    required: true,
    enum: supportedUniversities
  }
});

/**
 * Validations
 */
PartySchema.path('formattedAddress').validate(function(addr) {
  return !!addr;
}, 'Address cannot be blank');

PartySchema.path('latitude').validate(function(lat) {
  return lat === 0 || !!lat;
}, 'Latitude cannot be blank');

PartySchema.path('longitude').validate(function(lon) {
  return lon === 0 || !!lon;
}, 'Longitude cannot be blank');

PartySchema.path('maleCost').validate(function(cost) {
  return cost === 0 || !!cost;
}, 'Male Cost cannot be blank');

PartySchema.path('femaleCost').validate(function(cost) {
  return cost === 0 || !!cost;
}, 'Female Cost cannot be blank');

PartySchema.path('startTime').validate(function(startTime) {
  return !!startTime;
}, 'Start Time cannot be blank');

PartySchema.path('byob').validate(function(byob) {
  return byob === false || byob === true;
}, 'BYOB cannot be blank');

PartySchema.path('user').validate(function(userRef) {
  return !!userRef;
}, 'User cannot be blank');

PartySchema.path('university').validate(function(university) {
  return !!university;
}, 'University cannot be blank');

/**
 * Statics
 */
PartySchema.statics.load = function(id, cb) {
  this.findOne({
    _id: id
  }).populate('user', 'name username').exec(cb);
};

/**
 * Retrieve all parties happening at a university around now
 * 
 * @method currentForUniversity
 * @param {String} universityName Name of the university at which to search
 * @return {Promise} A promise that will deliver query results
 */
PartySchema.statics.currentForUniversity = function(universityName) {
  if (!_.contains(supportedUniversities, universityName)) {
    return new mongoose.Promise()
      .reject(new Error('University ' + universityName + ' is not supported'));
  }
  var now = new Date();

  // parties that started 8 hours ago will be considered
  var earliestStart = new Date(now.getTime());
  earliestStart.setHours(earliestStart.getHours() - 8);

  // parties that start 24 hours from now will be considered
  var latestStart = new Date(now.getTime());
  latestStart.setHours(latestStart.getHours() + 24);

  var promise = this.find({
    university: universityName
  })
  .gte('startTime', earliestStart)
  .lte('startTime', latestStart)
  .exec();
  
  return promise;
};

mongoose.model('Party', PartySchema);
