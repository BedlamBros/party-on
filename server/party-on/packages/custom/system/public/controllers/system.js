(function () {
  'use strict';

  /* jshint -W098 */
  angular
    .module('mean.system')
    .controller('SystemController', SystemController);

  SystemController.$inject = ['$scope', 'Global', 'System'];

  function SystemController($scope, Global, System) {
    $scope.global = Global;
    $scope.package = {
      name: 'system'
    };
  }
})();