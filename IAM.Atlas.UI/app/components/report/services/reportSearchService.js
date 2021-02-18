(function () {

    'use strict';

    angular
        .module("app")
        .service("reportSearchService", reportSearchService);

    reportSearchService.$inject = ["$http"];

    function reportSearchService($http) {

        var reportService = this; 

        /**
         * Get the related Report Categories
         */
        reportService.getRelatedReportCategories = function (organisationID) {
            return $http.get(apiServer + "/reportcategory/related/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the reports belonging to a specific user
         */
        reportService.getReportsByUser = function (UserId) {
            return $http.get(apiServer + "/report/search/getreportsbyuser/" + UserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the reports belonging to a specific organisation
         */
        reportService.getReportsByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/report/search/getreportsbyorganisation/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the reports belonging to a specific category
         */
        reportService.getReportsByCategory = function (CategoryId) {
            return $http.get(apiServer + "/report/search/getreportsbycategory/" + CategoryId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };


    }
})();