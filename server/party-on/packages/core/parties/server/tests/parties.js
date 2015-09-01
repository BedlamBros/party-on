/* jshint -W079 */
/* Related to https://github.com/linnovate/mean/issues/898 */
'use strict';

/**
 * Module dependencies.
 */
var expect = require('expect.js'),
  mongoose = require('mongoose'),
  User = mongoose.model('User'),
  Party = mongoose.model('Party');

/**
 * Globals
 */
var user;
var party;

/**
 * Test Suites
 */
describe('Create and save user', function() {
  describe('Model Party:', function() {
    beforeEach(function(done) {
      this.timeout(10000);
      user = new User({
        name: 'Full name',
        email: 'test@test.com',
        username: 'user',
        password: 'password'
      });
      user.save(function() {
        party = new Party({
          formattedAddress: "629 S Woodlawn Ave.",
          latitude: 73.2,
          longitude: -176.32,
          maleCost: 5,
          startTime: new Date(),
          user: user,
          university: "Indiana University"
        });
        done();
      });


    });
    describe('Method Save', function() {

      it('should be able to save without problems', function(done) {
        this.timeout(10000);

        return party.save(function(err, data) {
          expect(err).to.be(null);
          expect(data.maleCost).to.equal(5);
          expect(data.femaleCost).to.equal(0);
          expect(data.user.length).to.not.equal(0);
          expect(data.university).to.equal("Indiana University");
          done();
        });

      });

      it('should be able to show an error when try to save without formattedAddress', function(done) {
        this.timeout(10000);
        party.formattedAddress = '';

        return party.save(function(err) {
          expect(err).to.not.be(null);
          done();
        });
      });

      it('should be able to show an error when try to save with bad latitude type', function(done) {
        this.timeout(10000);
        party.latitude = 34345.2;
        return party.save(function(err) {
          expect(err).to.not.be(null);
          done();
        });
      });

      it('should be able to show an error when try to save without user', function(done) {
        this.timeout(10000);
        party.user = {};

        return party.save(function(err) {
          expect(err).to.not.be(null);
          done();
        });
      });
    });

    afterEach(function(done) {
      this.timeout(10000);
      party.remove(function() {
        user.remove(done);
      });
    });
  });
});
