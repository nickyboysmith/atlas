(function () {

    'use strict';

    angular
        .module("app")
        .service("ReportCategoryService", ReportCategoryService);


    ReportCategoryService.$inject = ["$http"];

    function ReportCategoryService($http) {

        var management = this;

        /**
         * Get report Categories associated with the 
         * selected organisation
         */
        management.getReportCategories = function (organistionId)
        {
            return $http.get(apiServer + "/reportcategory/related/" + organistionId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get organisations associated with logged in user
         * [OrganisationUser] Table
         */
        management.getRelatedOrganisations = function (userID)
        {
            return $http.get(apiServer + "/reportcategory/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Send The report Category object
         * To the WebAPI
         */
        management.saveReportCategory = function (reportCategoryObject)
        {
            return $http.post(apiServer + "/reportcategory", reportCategoryObject)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }

})();