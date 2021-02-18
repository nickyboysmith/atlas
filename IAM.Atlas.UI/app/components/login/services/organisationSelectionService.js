(function () {

    'use strict';

    angular
    .module("app")
    .service("OrganisationSelectionService", OrganisationSelectionService);

    OrganisationSelectionService.$inject = ["$http"];

    function OrganisationSelectionService($http) {

        var contactService = this;

        contactService.getDORSCourseOrganisations = function (dorsSchemeIdentifier) {
            return $http.get(apiServer + "/Organisation/GetDorsOrganisationContacts/" + dorsSchemeIdentifier);
        };

        contactService.getDorsOrganisationContactsWithAvailableCourses = function (dorsSchemeIdentifier) {
            return $http.get(apiServer + "/Organisation/GetDorsOrganisationContactsWithAvailableCourses/" + dorsSchemeIdentifier);
        };
        

        contactService.getOrganisationContent = function (organisationName) {
            return $http.get(apiServer + "/Organisation/GetOrganisationContent/" + organisationName);
        };
    }

})()