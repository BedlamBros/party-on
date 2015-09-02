'use strict';

/**
 * Module dependencies.
 */
var mongoose = require('mongoose'),
    Party = mongoose.model('Party'),
    config = require('meanio').loadConfig(),
    _ = require('lodash');

module.exports = function(Parties) {

    return {
        /**
         * Find party by id
         */
        party: function(req, res, next, id) {
            Party.load(id, function(err, party) {
                if (err) return next(err);
                if (!party) return next(new Error('Failed to load party ' + id));
                req.party = party;
                next();
            });
        },
        /**
         * Create a party
         */
        create: function(req, res) {
            var party = new Party(req.body);
            party.user = req.user;
            
            party.save(function(err) {
                if (err) {
                    return res.status(500).json({
                        error: 'Cannot save the party'
                    });
                }

                /*Party.events.publish({
                    action: 'created',
                    user: {
                        name: req.user.name
                    },
                    url: config.hostname + '/parties/' + parties._id,
                    name: party.title
                });*/

                res.json(party);
            });
        },
        /**
         * Update a party
         */
        update: function(req, res) {
            var party = req.party;
            party = _.extend(party, req.body);
            
            party.save(function(err) {
                if (err) {
                    return res.status(500).json({
                        error: 'Cannot update the party'
                    });
                }

                /*Parties.events.publish({
                    action: 'updated',
                    user: {
                        name: req.user.name
                    },
                    name: article.title,
                    url: config.hostname + '/parties/' + party._id
                });*/

                res.json(party);
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

            res.json(req.party);
        },
        /**
         * List of Parties for University
         */
        listCurrent: function(req, res) {
            console.log('listcur');
            Party.currentForUniversity(req.params.universityName)
            .then(function(parties) {
              res.json(parties);
            }, 
            function(err) {
              return res.status(500).json({
                error: err.toString()
              });
            });
        }
    };
};
