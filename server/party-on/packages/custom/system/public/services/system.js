(function () {
  'use strict';

  angular
    .module('mean.system')
    .factory('System', System);

  System.$inject = [];

  function System() {
    return {
      name: 'system'
    };
  }
})();
