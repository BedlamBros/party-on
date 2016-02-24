'use strict';

/*
 * Defining the Package
 */
var Module = require('meanio').Module;
var Admin = new Module('admin');

/*
 * All MEAN packages require registration
 * Dependency injection is used to define required modules
 */

Admin.register(function(app, auth, database) {
		//configure admin module dependcies here
    // We enable routing. By default the Package Object is passed to the routes
    Admin.routes(app, auth, database);
    return Admin;
});
