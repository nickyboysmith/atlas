(function () {

    'use strict';

    angular
        .module("app")
        .controller("ToggleCtrl", ToggleCtrl);

    ToggleCtrl.$inject = ["$scope", "AtlasCookieFactory", "ToggleService", "ToggleFactory"];

    function ToggleCtrl($scope, AtlasCookieFactory, ToggleService, ToggleFactory) {


        var mainContainer = new TemplateManager();

        /**
         * Get the UserID from the active object
         * 
         */
        $scope.userID = 1;

        /**
         * Set the toggle positions
         */
        $scope.togglePositions = [
            {position: "moveLeft"},
            {position: "moveCenter"},
            {position: "moveRight" }
        ];

        $scope.toggleService = ToggleService;


        /**
         * 
         */
        $scope.checkContainerPositionOnLoad = function () {
            $scope.presetAlignment = AtlasCookieFactory.getCookie("containerAlignment");
            if ($scope.presetAlignment === false) {
                /**
                 * If a cookie doesnt exist
                 * Then check the DB to see if a 
                 * A preference is saved in the db
                 * @todo refactor as duplicate code
                 */
                $scope.toggleService.getUserPreference($scope.userID)
                    .then(function (response) {


                        /**
                         * If there are 0 items in the response
                         */
                        if (response.length === 0) {
                            $scope.newAlignment = $scope.togglePositions[1]["position"];
                        }

                        /**
                         * If the response has items
                         */
                        if (response.length !== 0) {
                            $scope.newAlignment = response[0]["AlignPreference"];
                        }

                        $scope.updatePosition(mainContainer, $scope.newAlignment);
                        $scope.save($scope.userID, $scope.newAlignment);


                    }, function () {
                        console.log("Print an error");
                    });
            }
        };


        /**
         * Call the on load function
         */
        // $scope.checkContainerPositionOnLoad();



        /**
         * Make the toggle work
         */
        $scope.toggleContainer = function () {



            /***
             * Get cookie
             */
            $scope.presetAlignment = AtlasCookieFactory.getCookie("containerAlignment");


            /**
             * new postion
             */
            $scope.newAlignment;

            /**
             * If a cookie doesnt exist
             * Center the div
             */
            if ($scope.presetAlignment === false) {

                /**
                 * If a cookie doesnt exist
                 * Then check the DB to see if a 
                 * A preference is saved in the db
                 */
                $scope.toggleService.getUserPreference($scope.userID)
                    .then(function (response) {


                        /**
                         * If there are 0 items in the response
                         */
                        if (response.length === 0) {
                            $scope.newAlignment = $scope.togglePositions[1]["position"];
                        }

                        /**
                         * If the response has items
                         */
                        if (response.length !== 0) {
                            $scope.newAlignment = response[0]["AlignPreference"];
                        }

                        $scope.updatePosition(mainContainer, $scope.newAlignment);
                        $scope.save($scope.userID, $scope.newAlignment);


                    }, function () {
                        console.log("Print an error");
                    });



            }


            /**
             * If the cookie exists get the next one in the group
             * @todo ( resolve || defer ) - Refactor
             */
            if ($scope.presetAlignment !== false) {
                $scope.newAlignment = ToggleFactory.getNextAlignment($scope.togglePositions, $scope.presetAlignment);
                $scope.updatePosition(mainContainer, $scope.newAlignment);
                $scope.save($scope.userID, $scope.newAlignment);

            }



            // ToggleService.saveUserPreference(userID, preference);


        };

        /**
         * Set cookie
         * Then move the container
         * @todo ( resolve || defer ) - Refactor
         */
        $scope.updatePosition = function (mainContainer, position) {
            /**
             * Create the cookie for the new alignment
             */
            AtlasCookieFactory.createCookie("containerAlignment", position);
            mainContainer.updateContainer(position);

        };

        /**
         * Save the stuff tot he web api+
         * @todo ( resolve || defer ) - Refactor
         */
        $scope.save = function (userID, preference) {

            $scope.toggleService.saveUserPreference(userID, preference)
                .then(function (response) {
                    console.log("Saved!");
                }, function(response) {
                    console.log("Not saved!");
                });
        };


    }


})();