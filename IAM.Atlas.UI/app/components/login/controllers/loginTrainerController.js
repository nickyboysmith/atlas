(function () {

    'use strict';

    angular
        .module("app")
        .controller("LoginTrainerCtrl", LoginTrainerCtrl);

    LoginTrainerCtrl.$inject = ['$scope', "$window", 'systemStatus', "AuthenticationService", "AtlasCookieFactory"];

    function LoginTrainerCtrl($scope, $window, systemStatus, AuthenticationService, AtlasCookieFactory) {


        $scope.systemStatus = "live";
        $scope.systemStatusMessage = "The system is accessible";

    }

})();