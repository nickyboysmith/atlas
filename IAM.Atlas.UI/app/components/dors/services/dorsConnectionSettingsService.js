(function () {

    'use strict';

    angular
        .module("app")
        .service("DorsConnectionSettingsService", DorsConnectionSettingsService);

    DorsConnectionSettingsService.$inject = ["$http"];

    function DorsConnectionSettingsService($http) {

        var connection = this;

        /**
         * Save the notes
         */
        connection.getAllOrganisations = function (userId) {
            return $http.get(apiServer + "/dorsconnection/getall/" + userId)
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