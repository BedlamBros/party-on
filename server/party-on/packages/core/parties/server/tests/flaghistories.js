'use strict';

/**
 * Module dependencies.
 */
var expect = require('expect.js'),
  config = require('meanio').loadConfig(),
  async = require('async'),
  request = require('request'),
  _ = require('underscore'),
  mongoose = require('mongoose'),
  User = mongoose.model('User'),
  Party = mongoose.model('Party'),
  Flag = mongoose.model('Flag'),
  FlagHistory = mongoose.model('FlagHistory');

/**
 * Globals
 */
var user, doucheyPartyList;

/**
 * Test Suites
 */
describe('Testing FlagHistories and Banning', function() {
  describe('Flag Histories:', function() {
    
    before(function(done) {
      this.timeout(10000);
      var newUser = new User({
	name: Math.random().toString(),
	email: Math.random().toString() + '@test.com',
	username: Math.random().toString()
      });
      // create a test user
      newUser.save(function(err, savedUser) {
	user = savedUser;
	var setupTasks = [];
	// queue jobs for async.parallel
	for (var i = 0; i < 3; i++) {
	  // push 3 party creation jobs
	  setupTasks.push(function(cb) {
	    var doucheyParty = new Party({
	      formattedAddress: '123 Main St.',
	      latitude: 1.0,
	      longitude: 1.0,
	      startTime: new Date(),
	      university: "Indiana University",
	      user: user
	    });
	    doucheyParty.save(function(err) {
	      return cb(err, doucheyParty);
	    });
	  });
	}
	// now execute in parallel
	async.parallel(setupTasks, function(err, parties) {
	  expect(err).to.be(null);
	  expect(parties.length).to.be(3);
	  expect(_.all(parties, function(party) {
	    return !!party;
	  })).to.be(true);
	  doucheyPartyList = parties;
	  done();
	});

      });
    });

    it('should not ban a good user', function(done) {
      this.timeout(10000);
      var goodUser = _.clone(user);
      var endpoint = '/api/test/parties/bannedstatus';
      request({
	uri: config.hostname + endpoint,
	method: 'POST',
	json: {
	  user: goodUser
	}
      }, function(err, resp, body) {
	expect(err).to.be(null);
	expect(resp.statusCode).to.be(200);
	expect(body.banned).to.be(false);
	done();
      });
    });


    it('should be able to file a flag against a new user', function(done) {
      this.timeout(10000);
      var complaintBody = 'Meh I\'m angry';
      var doucheyUser = _.clone(user);
      var inappropriateParties = doucheyPartyList.slice(0);
      for (var idx in inappropriateParties) {
	// @hack - mongoose makes party.user disappear with black magic here
	// reinstate it by force-attaching it directly from the cloned doucheyUser
	inappropriateParties[idx].user = doucheyUser._id;
      }
      var flagTasks = _.map(inappropriateParties, function(party, idx) {
	// push tasks for an async.parallel flagging run
	return function(cb) {
	  FlagHistory.registerComplaint(party, complaintBody, cb);
	};
      });
      async.parallel(flagTasks, function(err, worthlessResponses) {
	expect(err).to.be(null);
	FlagHistory.findOne({user: doucheyUser._id})
	  .populate('flags').exec(function(err, flagRecord) {
	    expect(err).to.be(null);
	    expect(flagRecord.flags.length).to.be(3);
	    expect(_.all(flagRecord.flags, function(flag) {
	      return flag.complaint == complaintBody;
	    })).to.be(true);
	    done();
	});
      });
    });


    it('should ban a bad user', function(done) {
      this.timeout(10000);
      var badUser = _.clone(user);
      var endpoint = '/api/test/parties/bannedstatus';
      request({
	uri: config.hostname + endpoint,
	method: 'POST',
	json: {
	  user: badUser
	}
      }, function(err, resp, body) {
	expect(err).to.be(null);
	expect(resp.statusCode).to.be(200);
	expect(body.banned).to.be(true);
	done();
      });
    });


    after(function(done) {
      this.timeout(10000);
      var doucheyUser = _.clone(user);
      User.remove({_id: doucheyUser._id}, function(err, removed) {
	expect(err).to.be(null);
	
	var teardownTasks = [];
	for (var idx in doucheyPartyList) {
	  teardownTasks.push(function(cb) {
	    var doucheyParty = doucheyPartyList[idx];
	    Party.remove({user: doucheyUser._id}, cb);
	  });
	}
	async.parallel(teardownTasks, function(err, results) {
	  expect(err).to.be(null);
	  Flag.remove({}, function(err) {
	    expect(err).to.be(null);
	    done();
	  });
	});
      });
    });
  });
});
