(function () {
  'use strict';

  /* jshint -W098 */
  // The Package is past automatically as first parameter
  module.exports = function (System, app, auth, database) {

    app.get('/index', function (req, res, next) {
      System.render('index', {
        package: 'system'
      }, function (err, html) {
        //Rendering a view from the Package server/views
        res.send(html);
      });
    });
  };
})();
