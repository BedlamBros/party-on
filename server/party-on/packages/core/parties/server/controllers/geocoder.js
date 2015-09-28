geocoderProvider = 'google';
var httpAdapter = 'https';
// optionnal 
 var extra = {
     apiKey: 'AIzaSyDME6wRuiG06ZNGAg03dOeadTogAvOuhfo', // for Mapquest, OpenCage, Google Premier 
         formatterPatternKey: '%n%s' // 'gpx', 'string', ... 
         };
          
          var geocoder = require('node-geocoder')(geocoderProvider, httpAdapter, extra);

          // example
          geocoder.geocode('405 s ronson bloomington in', function(err, res) {
              console.log(res);
              });

              //TODO failover if l2short and l1short do not match model for university

              module.exports = geocoder;
