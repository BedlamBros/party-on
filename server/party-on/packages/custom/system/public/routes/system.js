(function () {
  'use strict';

  angular
    .module('mean.system')
    .config(system);

  system.$inject = ['$stateProvider'];

  function system($stateProvider) {
    $stateProvider.state('system example page', {
      url: '/thedocket',
      templateUrl: 'system/views/thedocket/index.html'
    });
  }

})();
