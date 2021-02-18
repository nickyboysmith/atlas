(function () {

    'use strict';

    angular
        .module('app')
        .service('SystemControlService', SystemControlService);


    SystemControlService.$inject = ["$http"];

    function SystemControlService($http) {

        var systemControlService = this;

        /**
         * Get the systemControl
         */
        systemControlService.Get = function () {
            return $http.get(apiServer + "/systemControl/Get")
        };

        /**
         * Get the BrowserAndOS for use in the About Page
         */
        systemControlService.GetBrowserAndOS = function () {
            return $http.get(apiServer + "/systemControl/GetBrowserAndOS")
        };
        
        /**
        * updates the systemControl
        */
        systemControlService.Save = function (systemControlSettings) {
            return $http.post(apiServer + "/systemControl/Save", systemControlSettings)
        };

        /**
        * Get the systemControl
        */
        systemControlService.GetClientRegistrationSystemControlData = function () {
            return $http.get(apiServer + "/systemControl/GetClientRegistrationSystemControlData")
        };


    }



})();