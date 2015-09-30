geocoderProvider = 'google';
var httpAdapter = 'https';
// optionnal 
 var extra = {
     apiKey: 'AIzaSyDME6wRuiG06ZNGAg03dOeadTogAvOuhfo', // for Mapquest, OpenCage, Google Premier 
         formatterPatternKey: '%n%s' // 'gpx', 'string', ... 
         };
          
          var geocoder = require('node-geocoder')(geocoderProvider, httpAdapter, extra);

              module.exports = geocoder;
