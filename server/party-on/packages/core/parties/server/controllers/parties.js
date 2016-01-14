'use strict';
//in progress
var geocoder = require('./geocoder.js');

/**
 * Module dependencies.
 */
var mongoose = require('mongoose'),
    async = require('async'),
    Party = mongoose.model('Party'),
    Word  = mongoose.model('Word'),
    config = require('meanio').loadConfig(),
    geocoder = require('./geocoder.js'),
    _ = require('lodash');

module.exports = function(Parties) {

    return {
        /**
         * Find party by id
         */
        party: function(req, res, next, id) {
            Party.load(id, function(err, party) {
                if (err) return next(err);
                if (!party) {
                  return res.status(404).json({
                    error: "Party for id " + id + " does not exist"
                  });
                }
                req.party = party;
                next();
            });
        },
        /**
         * Create a party
         */
        create: function(req, res, next) {
	  var party = new Party(req.body);
	  var errorCode = null;
	  party.user = req.user;
	  // now using a callback pattern
	  async.waterfall([function(cb) {
	      geocoder.geocode(party.formattedAddress + " Bloomington, IN", cb);
	    },
	    function(geocodeResponse, cb) {
	      party.formattedAddress = geocodeResponse[0].streetNumber 
		+ " " + geocodeResponse[0].streetName;
	      party.latitude = geocodeResponse[0].latitude;
	      party.longitude = geocodeResponse[0].longitude;
	      if (geocodeResponse[0].extra.confidence < 0.7){
		//set an error code for unkown address
		errorCode = "UNKNOWN";
	      }
	      if (!errorCode){
	        party.save(cb);
	      } else {
	        cb();
	      }
	    }], 
	    function(err, savedParty) {
	      if (err) {
		console.log(err);
	      }
	      //if an error exists, add it to the json
	      if (errorCode == "UNKNOWN"){
		party.errorCode = errorCode;
		return res.json({
		  errorCode: "UNKNOWN"
		});
	      }
	      return res.json(party);
	    });
        },
        /**
         * Update a party
         */
        update: function(req, res) {
	  var errorCode = null;
	  
          var party = req.party;
          party = new Party(_.extend(party.toJSON(), req.body));
	  party.isNew = false;
	  async.waterfall([function(cb) {
	    geocoder.geocode(party.formattedAddress + " Bloomington, IN", cb);
	    }],
	    function(err, geocodeResponse) {
	      if (err || geocodeResponse[0].extra.confidence < 0.7) {
		errorCode = "UNKNOWN";
	      }
	      else if (geocodeResponse[0]) {
		party.formattedAddress = geocodeResponse[0].streetNumber
		  + " " + geocodeResponse[0].streetName;
		party.latitude = geocodeResponse[0].latitude;
		party.longitude = geocodeResponse[0].longitude;
	      }
	      
	      if (errorCode){
		return res.json({
		  errorCode: errorCode
	      	});
	      } else {
		party.save(function(err) {
		  if (err) {
   	            return res.status(500).json({
        	      error: 'Cannot update the party'
		    });
              	  }
		  return res.json(party);
		});
	      }
	    });
	  },
        /**
         * Delete a party
         */
        destroy: function(req, res) {
            var party = req.party;

            party.remove(function(err) {
                if (err) {
                    return res.status(500).json({
                        error: 'Cannot delete the party'
                    });
                }

                /*Parties.events.publish({
                    action: 'deleted',
                    user: {
                        name: req.user.name
                    },
                    name: party.title
                });*/

                res.json(party);
            });
        },
        /**
         * Show a party
         */
        show: function(req, res) {

            /*Parties.events.publish({
                action: 'view',
                user: {
                    name: req.user.name
                },
                name: req.party.title,
                url: config.hostname + '/parties/' + req.party._id
            });*/
            res.json(req.party.toJSON());
        },
        /**
         * List of Parties for University
         */
        listCurrent: function(req, res) {
            Party.currentForUniversity(req.params.universityName)
            .then(function(parties) {
              res.json({
                  parties: parties
              });
            }, 
            function(err) {
              return res.status(500).json({
                error: err.toString()
              });
            });
        },
	/**
	 * Add a Word to a Party
	 */
	addAWord: function(req, res) {
	  var word = new Word(req.body);
	  req.party.theWord.push(word);
	  req.party.save(function(err, saved) {
	    if (err) return res.status(500).send(err.toString());
	    return res.json(saved);
	  });
	}
    };
};

var getAddressEncoding = function(geocodeResponse){
    //if no errors exist in the geocodeResponse, format the address and return
    if (geocodeResponse[0].streetName){
      return geocodeResponse[0].streetNumber 
	+ " " + geocodeResponse[0].streetName;
    } else {
      return "UNKNOWN";
    }
    
};


