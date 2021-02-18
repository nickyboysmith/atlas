(function () {

    'use strict';

    angular
        .module("app")
        .service("DorsConnectionService", DorsConnectionService);

    DorsConnectionService.$inject = ["$http"];

    function DorsConnectionService($http) {

        var dorsConnectionService = this;

        /**
         * 
         */
        dorsConnectionService.GetAvailableForDefaultRotation = function (userId) {
            return $http.get(apiServer + "/dorsconnection/GetAvailableForDefaultRotation/" + userId);
        };

        /**
         * 
         */
        dorsConnectionService.SelectForDefaultRotation = function (DORSConnectionId, userId) {
            return $http.get(apiServer + "/dorsconnection/SelectForDefaultRotation/" + DORSConnectionId + "/" + userId);
        };

        /**
         * 
         */
        dorsConnectionService.DeselectFromDefaultRotation = function (DORSConnectionId, userId) {
            return $http.get(apiServer + "/dorsconnection/DeselectFromDefaultRotation/" + DORSConnectionId + "/" + userId);
        };

        /**
        * 
        */
        dorsConnectionService.GetSelectedForDefaultRotation = function (userId) {
            return $http.get(apiServer + "/dorsconnection/GetSelectedForDefaultRotation/" + userId);
        };

    }

})();