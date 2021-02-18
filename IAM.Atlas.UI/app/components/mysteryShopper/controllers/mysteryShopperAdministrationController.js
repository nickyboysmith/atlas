(function () {

    'use strict';

    angular
        .module("app")
        .controller("MysteryShopperAdministrationCtrl", MysteryShopperAdministrationCtrl);

    MysteryShopperAdministrationCtrl.$inject = ["$scope", "$filter", "MysteryShopperService", "UserService", "activeUserProfile", "ModalService", "CourseTrainerFactory"];

    function MysteryShopperAdministrationCtrl($scope, $filter, MysteryShopperService, UserService, activeUserProfile, ModalService, CourseTrainerFactory) {

        /**
         * Selected Special Requirements
         */
        $scope.selected = [];

        /**
         * Available Special Requirements
         */
        $scope.available = [];

        /**
         * 
         */
        $scope.organisationId;

        /**
         * Call the methods to update the object
         */

        //$scope.getAvailable();
        //$scope.getSelected();

        /**
         * What happens
         * When an item is dragged and dropped
         * Into an area
         */
        $scope.processDataMove = function (option, event, from, to) {

            var newObject = {};
            var dataOptionObject = {
                organisationId: $scope.organisationId
            };

            /**
             * Find the index on the object
             * By the option ID
             */
            var objectID = CourseTrainerFactory.find($scope[from], option.Id);

            /**
             * Check to see if the option ID 
             * Exists in the object that it's being moved to
             */
            var existsInObject = CourseTrainerFactory.find($scope[to], option.Id);

            /**
             * Dragging from bthe selected to the available
             */
            if (to === "mysteryShopperAdministrators" && from === "availableUsers") {
                newObject = angular.extend(dataOptionObject, {
                    action: "remove",
                    userId: option.Id,
                    addedByUserId: activeUserProfile.UserId
                });
            }

            /**
             * Dragging from the available to the selected
             */
            if (to === "availableUsers" && from === "mysteryShopperAdministrators") {
                newObject = angular.extend(dataOptionObject, {
                    action: "add",
                    userId: option.Id,
                    addedByUserId: activeUserProfile.UserId
                });
            }


            MysteryShopperService.updateMysteryShopperAdmin(newObject)
            .then(
                function (data) {

                    $scope.getMysteryShopperAdministrators();
                    $scope.getAvailableUsers();
                },
                function (data) {
                }
            );
        }

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            UserService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                UserService.checkSystemAdminUser(userID)
                .then(function (data) {
                    $scope.isAdmin = data;
                });
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;

                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        $scope.getMysteryShopperAdministrators = function () {

            MysteryShopperService.getMysteryShopperAdministrators($scope.organisationId)
            .then(
                function (data) {
                    $scope.mysteryShopperAdministrators = data;
                    $scope.mysteryShopperAdministrators = $filter('orderBy')($scope.mysteryShopperAdministrators, 'Name');
                },
                function (data) {
                    $scope.errorMessage = "Failed to get the list of Administrators";
                }
            );
        };

        $scope.getAvailableUsers = function () {
            MysteryShopperService.getAvailableUsers($scope.organisationId)
            .then(
                function (data) {
                    $scope.availableUsers = data;
                    $scope.availableUsers = $filter('orderBy')($scope.availableUsers, 'Name');
                },
                function (data) {
                    $scope.errorMessage = "Failed to get available users";
                }
            );
        };

        $scope.getUsersAndAdministrators = function (organisationId) {
            $scope.organisationId = organisationId;
            $scope.getMysteryShopperAdministrators();
            $scope.getAvailableUsers();
        }

        $scope.getMysteryShopperAdministrators();
        $scope.getAvailableUsers();
        $scope.getOrganisations(activeUserProfile.UserId);
    }

})();