(function () {

    'use strict';

    angular
        .module("app.controllers")
        .controller("SignOutCtrl", SignOutCtrl);

    SignOutCtrl.$inject = ["$scope", "SignOutFactory", "SignOutService", "activeUserProfile"];

    function SignOutCtrl($scope, SignOutFactory, SignOutService, activeUserProfile) {

        /**
         * Log out the admin user
         * Redirect to the correct landing page
         */
        
        $scope.logAdminOut = function () {

            SignOutService.SignOut(activeUserProfile.UserId)
            .then(function (data) {

                SignOutFactory.admin();

            }, function (data) {
                
            });

        }

        /**
         * Log out the trainer user
         * Redirect to the correct landing page
         */
        $scope.logOutTrainer = function () {

            SignOutService.SignOut(activeUserProfile.UserId)
            .then(function (data) {

                SignOutFactory.trainer();

            }, function (data) {

            });


        };

        /**
         * Log out the client user
         * Redirect to the correct landing page
         */
        $scope.logOutClient = function () {

            SignOutService.SignOut(activeUserProfile.UserId)
            .then(function (data) {

                SignOutFactory.client();

            }, function (data) {

            });

        };

    }

})();