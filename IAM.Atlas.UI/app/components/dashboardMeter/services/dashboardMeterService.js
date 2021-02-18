(function () {

    'use strict';

    angular
        .module('app')
        .service('DashboardMeterService', DashboardMeterService);


    DashboardMeterService.$inject = ["$http"];

    function DashboardMeterService($http) {

        var dashboardMeterService = this;

        /**
         * Get the dashboard meters
         */
        dashboardMeterService.Get = function () {
            return $http.get(apiServer + "/dashboardMeter/GetMeters")
        };

        /**
         * Get the dashboard meters
         */
        dashboardMeterService.GetMeterDetails = function (meterId) {
            return $http.get(apiServer + "/dashboardMeter/GetMeterDetails/" + meterId)
        };

        /**
         * Get the available organisations
         */
        dashboardMeterService.GetAvailableOrganisations = function (meterId) {
            return $http.get(apiServer + "/dashboardMeter/GetAvailableOrganisations/" + meterId)
        };

        /**
         * Get the exposed organisations
         */
        dashboardMeterService.GetExposedOrganisations = function (meterId) {
            return $http.get(apiServer + "/dashboardMeter/GetExposedOrganisations/" + meterId)
        };
        
        /**
        * updates the dashboard settings
        */
        dashboardMeterService.Save = function (dashboardMeterSettings) {
            return $http.post(apiServer + "/dashboardMeter/Save", dashboardMeterSettings)
        };

        /**
        * updates the dashboard exposure
        */
        dashboardMeterService.updateDashboardMeterExposure = function (dashboardMeterExposureUpdate) {
            return $http.post(apiServer + "/dashboardMeter/SaveExposureUpdate", dashboardMeterExposureUpdate)
        };

        
    }



})();