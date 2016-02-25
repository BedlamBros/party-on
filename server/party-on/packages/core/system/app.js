'use strict';

/*
 * Defining the Package
 */
var meanio = require('meanio');
var Module = meanio.Module,
  config = meanio.loadConfig(),
  favicon = require('serve-favicon');

var SystemPackage = new Module('system');

/*
 * All MEAN packages require registration
 * Dependency injection is used to define required modules
 */
SystemPackage.register(function(app, auth, database, circles) {
  app.set('views', __dirname + '/server/views');
	console.log('System module views registering at ' + 
						 __dirname + '/server/views');
  //We enable routing. By default the Package Object is passed to the routes
  SystemPackage.routes(app, auth, database);
	SystemPackage.aggregateAsset('css', 'public/assets/css/common.css');
	SystemPackage.aggregateAsset('css', 'bootstrap.min.css');
	SystemPackage.aggregateAsset('css', 'cover.css');

  //SystemPackage.aggregateAsset('css', 'common.css');
	//SystemPackage.aggregateAsset('css', 'bootstrap.min.css');
  
  // The middleware in config/express will run before this code

  // Setting the favicon and static folder
  if(config.favicon) {
    app.use(favicon(config.favicon));
  } else {
    app.use(favicon(__dirname + '/public/assets/img/favicon.ico'));
  }

  // Adding robots and humans txt
  app.useStatic(__dirname + '/public/assets/');

  return SystemPackage;
});
