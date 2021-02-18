
(function () {

    'use strict';

    angular
        .module("app")
        .service("PublicHolidayManagementService", PublicHolidayManagementService);

    PublicHolidayManagementService.$inject = ["$http"];

    function PublicHolidayManagementService($http) {

        var management = this;


        /**
        * Get public holidays 
        */
        management.getPublicHolidays = function (countryID) {
            return $http.get(apiServer + "/publicholiday/" + countryID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

        /**
         * Remove the public hoidays
         * 
         */
        management.removePublicHoliday = function (publicHolidayID) {
            return $http.post(apiServer + "/publicholiday/" +  publicHolidayID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Send The public hoidays Type object
         * To the WebAPI
         */
        management.savePublicHoliday = function (publicHolidayObject) {
            return $http.post(apiServer + "/publicholiday", publicHolidayObject)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };


    }

})();