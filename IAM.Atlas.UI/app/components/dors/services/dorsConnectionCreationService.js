(function () {

    'use strict';

    angular
        .module("app")
        .service("DORSConnectionCreationService", DORSConnectionCreationService);

    DORSConnectionCreationService.$inject = ["$http"]

    function DORSConnectionCreationService($http) {

        var connection = this;

        /**
         * Gets the current connectiondetails for the organisation if they exist
         */
        connection.getOrganisationsWithout = function (userId) {
            return $http.get(apiServer + "/dorsconnection/without/" + userId)
                .then(
                    function success(response) {
                        return response.data;
                    },
                    function error(response) {
                        return response.data;
                    });

        };

    }

})();