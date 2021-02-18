(function () {

    'use strict';

    angular
        .module("app")
        .service("DorsConnectionDetailsService", DorsConnectionDetailsService);

    DorsConnectionDetailsService.$inject = ["$http"];

    function DorsConnectionDetailsService($http) {

        var connection = this;

        /**
         * Gets the current connectiondetails for the organisation if they exist
         */
        connection.getConnectionDetails = function (organisationId) {
            return $http.get(apiServer + "/dorsconnection/" + organisationId)
                .then(
                    function success(response) {
                        return response.data;
                    },
                    function error(response) {
                        return response.data;
                    });

        };

        /**
         * Get all Dors connection notes that below to an org
         */
        connection.getNotes = function (organisationId) {
            return $http.get(apiServer + "/dorsconnectionnotes/" + organisationId)
                .then(
                    function success(response) {
                        return response.data;
                    },
                    function error(response) {
                        return response.data;
                    });
        };

        /**
         * Save the coonection details
         * This either creates a new row or updates the current
         */
        connection.saveConnectionDetails = function (connectionDetails) {
            return $http.post(apiServer + "/dorsconnection", connectionDetails);
        };

        /**
         * Save the notes
         */
        connection.saveConnectionNote = function (connectionNote) {
            return $http.post(apiServer + "/dorsconnectionnotes", connectionNote)
            .then(
                function success(response) {
                    return response.data;
                },
                function error(response) {
                    return response.data;
                });
        };

        /**
       * Get DORS Connections and Organisation Name
       */
        connection.getDORSConnectionsOrganisationName = function () {
            return $http.get(apiServer + "/dorsconnection/getallorganisationname")
        };

    }

})();