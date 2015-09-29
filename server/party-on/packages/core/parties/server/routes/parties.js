'use strict';

// Party authorization helpers
var hasAuthorization = function(req, res, next) {
  if (!req.user.isAdmin && !req.party.user._id.equals(req.user._id)) {
    return res.status(401).send('User is not authorized');
  }
  next();
};

/*var hasPermissions = function(req, res, next) {

    req.body.permissions = req.body.permissions || ['authenticated'];

    for (var i = 0; i < req.body.permissions.length; i++) {
      var permission = req.body.permissions[i];
      if (req.acl.user.allowed.indexOf(permission) === -1) {
            return res.status(401).send('User not allowed to assign ' + permission + ' permission.');
        }
    }

    next();
};*/

module.exports = function(Parties, app, auth) {
  
  var parties = require('../controllers/parties')(Parties);
  var flaghistories = require('../controllers/flaghistories')(Parties);

  app.route('/api/parties')
    .post(auth.requiresLogin, parties.create);
  app.route('/api/parties/:partyId')
    .get(auth.isMongoId, parties.show)
    .put(auth.isMongoId, auth.requiresLogin, hasAuthorization, parties.update)
    .delete(auth.isMongoId, auth.requiresLogin, hasAuthorization, parties.destroy);
  app.route('/api/parties/university/:universityName')
    .get(parties.listCurrent);
  app.route('/api/parties/:partyId/word')
    .put(parties.addAWord);
  app.route('/api/parties/:partyId/flag')
    .post(flaghistories.sendEmail, flaghistories.raise);
  app.route('/api/users/bannedstatus')
    .get(auth.requiresLogin, flaghistories.isBanned);

  if (process.env.NODE_ENV == 'test') {
    // create a test route for .isBanned that doesn't authenticate
    app.route('/api/test/parties/bannedstatus')
      .post(function(req, res, next) {
	// pipe the user through like auth middleware would
	req.user = req.body.user;
	next();
      }, flaghistories.isBanned);
  }

  app.param('partyId', parties.party);
};
