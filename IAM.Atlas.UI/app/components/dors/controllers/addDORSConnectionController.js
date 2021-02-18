(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddDORSConnectionCtrl", AddDORSConnectionCtrl);

    AddDORSConnectionCtrl.$inject = ["$scope", "activeUserProfile", "DORSConnectionCreationService", "DorsConnectionDetailsService", "ModalService"]

    function AddDORSConnectionCtrl($scope, activeUserProfile, DORSConnectionCreationService, DorsConnectionDetailsService, ModalService) {

        console.log("We up in here");

        /**
         * 
         */
        $scope.organisationList = [];

        /**
         * 
         */
        $scope.connection = {};

        /**
         * Call to get the list of organisations
         */
        $scope.getListOfOrganisations = function () {
            DORSConnectionCreationService.getOrganisationsWithout(activeUserProfile.UserId)
                .then(
                    function (successResponse) {
                        $scope.organisationList = successResponse;
                    },
                    function (errorResponse) {
                        console.log(errorResponse);
                        console.log("There has been an errro catch it and display it");
                    }
                );
        };

        /**
         * Call the organisations
         */
        $scope.getListOfOrganisations();


        /**
         * save the dors connection
         */
        $scope.saveConnection = function () {

            /**
             * Add to connection object
             */
            $scope.connection.Enabled = 1;
            $scope.connection.UserId = activeUserProfile.UserId;

            if ($scope.connection.OrganisationId) {
                $scope.connection.OrganisationId = $scope.connection.OrganisationId.Id;
            }

            /**
             * Call the service and maniplate the response 
             * Based on the Status codes
             */
            DorsConnectionDetailsService
                .saveConnectionDetails($scope.connection)
                .then(
                    function (response) {
                        $scope.$parent.getOrganisations();
                        ModalService.closeCurrentModal("addDORSConnectionModal");
                    },
                    function (response) {
                        console.log(response.data);
                    }
                );

        };


    }

})();