/* jshint -W079 */
/* Related to https://github.com/linnovate/mean/issues/898 */
'use strict';

/**
 * Module dependencies.
 */
var expect = require('expect.js'),
  config = require('meanio').loadConfig(),
  request = require('request'),
  _ = require('underscore'),
  mongoose = require('mongoose'),
  User = mongoose.model('User'),
  Party = mongoose.model('Party');

/**
 * Globals
 */
var user, party, loginToken;

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

        request({
          uri: config.hostname + '/api/login',
          method: 'POST',
          json: {
            email: user.email,
            password: user.password
          }
        }, function(err, resp, loginBody) {
          // obtain a login token for the user
          loginToken = loginBody.token;
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

    describe('CRUD Methods for Party over http', function() {    
      var crudParty;

      it('should be able to POST a party', function(done) {
        this.timeout(10000);
        
        crudParty = new Party(_.omit(party.toJSON(), '_id'));
        crudParty.startTime.setHours(party.startTime.getHours() + 4);
            
        var requestConfig = {
          uri: config.hostname + '/api/parties',
          auth: {
            bearer: loginToken
          },
          method: 'POST',
          json: crudParty.toJSON()
          };
          
          request(requestConfig, function(err, resp, body) {
            expect(err).to.be(null);
            expect(resp.statusCode).to.be(200);
            expect(body.formattedAddress).to.be
            .equal(requestConfig.json.formattedAddress);

            crudParty = new Party(body);
            done();
          });
        });

      it('should be able to GET a party', function(done) {
        this.timeout(10000);
        request.get({
          uri: config.hostname + '/api/parties/' + crudParty.id.toString(), 
          auth: {
            bearer: loginToken
          },
          method: 'GET'
        }, function(err, resp, body) {
          // @hack - re-serialize body because 
          // it uses some black magic that makes it
          // come as not a real json object at all
          body = JSON.parse(body.toString());
          
          expect(err).to.be(null);
          expect(body['_id']).to.be
            .equal(crudParty.id.toString());
          expect(body.formattedAddress).to.be
            .equal(crudParty.formattedAddress);
          done();
          });
      });

      it('should be able to PUT an updated party', function(done) {
       this.timeout(10000);

        var updatedParty = new Party(crudParty.toJSON());
        updatedParty.endTime = new Date(crudParty.startTime.getTime());
        updatedParty.endTime.setHours(updatedParty.endTime.getHours());
        updatedParty.byob = !crudParty.byob;

        var requestConfig = {
          uri: config.hostname + '/api/parties/' + crudParty.id.toString(),
          auth: {
            bearer: loginToken
          },
          method: 'PUT',
          json: updatedParty.toJSON()
        };

        request(requestConfig, function(err, resp, body) {
          expect(err).to.be(null);
          expect(resp.statusCode).to.be(200);
          crudParty = new Party(body);
          expect(crudParty.id.toString()).to.be
            .equal(updatedParty.id.toString());
          expect(crudParty.endTime.getTime()).to
            .be(updatedParty.endTime.getTime());
          expect(crudParty.byob).to
            .be(updatedParty.byob);
          
            done();
        });
      });

      it('should be able to DELETE a party', function(done) {
        this.timeout(10000);  
        
        var requestConfig = {
          uri: config.hostname + '/api/parties/' + crudParty.id.toString(),
          auth: {
            bearer: loginToken
          },
          method: 'DELETE',
          json: {}
        };
        
        request(requestConfig, function(err, resp, body) {
          expect(err).to.be(null);
          expect(resp.statusCode).to.be(200);

          done();
        });
      });
    });

    describe('something else', function() {

    });
  });
});
