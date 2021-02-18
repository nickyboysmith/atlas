(function () {

    'use strict';

    angular
        .module('app')
        .service('BlockedIPService', BlockedIPService);


    BlockedIPService.$inject = ["$http"];

    function BlockedIPService($http) {

        var blockedIPService = this;

        /**
         * Get the blocked IPs
         */
        blockedIPService.getBlockedIPs = function () {
            return $http.get(apiServer + "/blockedIP/Get")
        };

        /**
        * Unblocks Selected IPs
        */
        blockedIPService.Unblock = function (selectedIPs) {
            return $http.post(apiServer + "/blockedIP/Unblock", selectedIPs)
        };

    }

})();