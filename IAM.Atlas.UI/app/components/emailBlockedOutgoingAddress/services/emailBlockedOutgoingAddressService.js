(function () {

    'use strict';

    angular
        .module('app')
        .service('EmailBlockedOutgoingAddressService', EmailBlockedOutgoingAddressService);


    EmailBlockedOutgoingAddressService.$inject = ["$http"];

    function EmailBlockedOutgoingAddressService($http) {

        var emailBlockedOutgoingAddressService = this;

        /**
         * Get the blocked emails
         */
        emailBlockedOutgoingAddressService.GetByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/emailBlockedOutgoingAddress/GetByOrganisation/" + organisationId)
        };

        /**
        * deletes blocked emails
        */
        emailBlockedOutgoingAddressService.Delete = function (selectedEmails) {
            return $http.post(apiServer + "/emailBlockedOutgoingAddress/Delete", selectedEmails)
        };

    }



})();