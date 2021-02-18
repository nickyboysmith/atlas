(function () {

    'use strict';

    angular
        .module('app')
        .service('dorsControlSettingsService', dorsControlSettingsService);


    dorsControlSettingsService.$inject = ["$http"];

    function dorsControlSettingsService($http) {

        var dorsControlSettingsService = this;

        /**
         * Get the dorsControl
         */
        dorsControlSettingsService.Get = function () {
            return $http.get(apiServer + "/DORSControl/Get")
        };

        /**
        * updates the dorsControl
        */
        dorsControlSettingsService.Save = function (dorsControlSettings) {
            return $http.post(apiServer + "/DORSControl/Save", dorsControlSettings)
        };

    }



})();