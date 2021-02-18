(function () {

    'use strict';

    angular
    .module("app")
    .service("ViewCourseOptionsService", ViewCourseOptionsService);

    ViewCourseOptionsService.$inject = ["$http"];

    function ViewCourseOptionsService($http) {

        var courseOptionsService = this;

        courseOptionsService.getOrganisationContacts = function (organisationId) {
            return $http.get(apiServer + "/Organisation/GetContacts/" + organisationId);
        };

        courseOptionsService.getOrganisationContent = function (organisationName) {
            return $http.get(apiServer + "/Organisation/GetOrganisationContent/" + organisationName);
        };
    }

})()