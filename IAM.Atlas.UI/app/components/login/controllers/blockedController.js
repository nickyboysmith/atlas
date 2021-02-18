(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('BlockedCtrl', BlockedCtrl);


    BlockedCtrl.$inject = ['$scope', '$location', '$window', '$http', 'systemStatus'];

    function BlockedCtrl($scope, $location, $window, $http, systemStatus) {

        $scope.systemStatus = {}

        $scope.systemStatus = systemStatus.data[0];

        // no systemBlockedColour in systemcontrol, set to red
        $scope.systemStatus.SystemColour = 'red'
    }
})();

