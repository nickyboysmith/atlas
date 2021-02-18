(function () {

    'use strict';

    angular
    .module("app")
    .service("OrganisationContactService", OrganisationContactService);

    OrganisationContactService.$inject = ["$http"];

    function OrganisationContactService($http) {

        var contactService = this;

        contactService.getOrganisationContacts = function (organisationId) {
            return $http.get(apiServer + "/Organisation/GetContacts/" + organisationId);
        };

        contactService.getOrganisationContent = function (organisationName) {
            return $http.get(apiServer + "/Organisation/GetOrganisationContent/" + organisationName);
        };


        /**
        * Get the systemControl
        */
        contactService.GetClientRegistrationSystemControlData = function () {
            return $http.get(apiServer + "/systemControl/GetClientRegistrationSystemControlData")
        };


    }

})()