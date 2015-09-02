'use strict';

/*
 * Defining the Package
 */
var Module = require('meanio').Module;

var Parties = new Module('parties');

/*
 * All MEAN packages require registration
 * Dependency injection is used to define required modules
 */
Parties.register(function(app, auth, database, circles, swagger) {

  //We enable routing. By default the Package Object is passed to the routes
  Parties.routes(app, auth, database);

  /*
    //Uncomment to use. Requires meanio@0.3.7 or above
    // Save settings with callback
    // Use this for saving data from administration pages
    Parties.settings({'someSetting':'some value'},function (err, settings) {
      //you now have the settings object
    });

    // Another save settings example this time with no callback
    // This writes over the last settings.
    Parties.settings({'anotherSettings':'some value'});

    // Get settings. Retrieves latest saved settings
    Parties.settings(function (err, settings) {
      //you now have the settings object
    });
    */

  // Only use swagger.add if /docs and the corresponding files exists
  //swagger.add(__dirname);
	
  return Parties;
});
