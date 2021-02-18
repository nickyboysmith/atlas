(function () {

    'use strict';

    angular
        .module("app")
        .service("AreaManagementService", AreaManagementService);


    AreaManagementService.$inject = ["$http"];

    function AreaManagementService($http) {

        var management = this;

        /**
         * Call the web api return a boolean 
         * If user is in the 
         * System administrator user table
         */

        //management.checkSystemAdminUser = function (userID) {
        //    return $http.get(apiServer + "/systemadmin/" + userID)
        //        .then(function (data) { })
        //        .error(function (data, status) { });
        //};

        /**
         * Get areas associated with the 
         * selected organisation
         */
        management.getAreas = function (organistionId) {
            return $http.get(apiServer + "/area/" + organistionId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get organisations associated with logged in user
         * [OrganisationUser] Table
         */
        //management.getRelatedOrganisations = function (userID) {
        //    return $http.get(apiServer + "/area/related/" + userID)
        //        .then(function (data) { })
        //        .error(function (data, status) { });
        //};

        /**
         * Send The area object
         * To the WebAPI
         */
        management.saveArea = function (areaObject) {
            return $http.post(apiServer + "/area", areaObject)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }

})();