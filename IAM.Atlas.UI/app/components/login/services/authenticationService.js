(function () {

    'use strict';

    angular
    .module("app")
    .service("AuthenticationService", AuthenticationService);

    AuthenticationService.$inject = ["$http"];

    function AuthenticationService($http) {

        var authenticate = this;

        /**
         * 
         */
        authenticate.loginOrganisationUser = function (loginDetails) {
            //var returnData = $http.post(apiServer + "/signin/" + loginDetails.path, loginDetails);
            return $http.post(apiServer + "/signin/" + loginDetails.path, loginDetails);
        };

        authenticate.checkUserLicence = function (licence) {
            //var returnData = $http.post(apiServer + "/signin/checkclientlicence/", licence)
            return $http.post(apiServer + "/signin/checkclientlicence/", licence);
        }

        authenticate.recordBookingAttempt = function (licenceNumber) {
            return $http.post(apiServer + "/signin/recordBookingAttempt/" + licenceNumber);
        }
    }

})()