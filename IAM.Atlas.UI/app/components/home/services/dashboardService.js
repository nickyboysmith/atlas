(function () {

    'use strict';

    angular
        .module("app")
        .service("DashboardService", DashboardService);

    DashboardService.$inject = ["$http"];

    function DashboardService($http) {

        var dashboard = this;

        /**
         * Get dashboard meters
         * For selected organisation and
         * Logged in UserId
         */
        dashboard.getDashboardMeterAccess = function (organisationId, userId) {
            return $http.get(apiServer + "/dashboard/getmeters/" + organisationId + "/" + userId);
        };

        /**
         * 
         */
        dashboard.getMeterData = function (meter, organisationId) {
            return $http.get(apiServer + "/dashboard/" + meter + "/" + organisationId);
        }

        /**
         * Send data tot eh web api to get hover information
         */
        dashboard.getHoverInformation = function (hoverObject) {
            var endPoint = apiServer + "/dashboard/getInformation";
            return $http.post(endPoint, hoverObject);
        };


    }

})();