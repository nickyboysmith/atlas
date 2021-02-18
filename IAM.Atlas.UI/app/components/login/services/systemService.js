(function () {

    angular
        .module("app")
        .service("SystemService", SystemService);


    SystemService.$inject = ["$http"];


    function SystemService($http) {

        var system = this;

        /**
         * Go to the WEBApi
         * To check the user hasn't been blocked
         */
        system.checkBlockedUserIP = function () {
            return $http.get(apiServer + "/systemauthentication/blockcheck");
        };

        /**
         * Go to the DB
         * & Check the system status
         */
        system.checkSystemStatus = function () {
            return $http.get(apiServer + "/systemauthentication/statuscheck");
        };

    }



})();