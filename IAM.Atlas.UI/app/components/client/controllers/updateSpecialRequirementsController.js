(function () {

    'use strict';

    angular
        .module("app")
        .controller("UpdateSpecialRequirementsCtrl", UpdateSpecialRequirementsCtrl);

    UpdateSpecialRequirementsCtrl.$inject = ["$scope", "ClientService", "$filter", "activeUserProfile", "CourseTrainerFactory", "ModalService"];

    function UpdateSpecialRequirementsCtrl($scope, ClientService, $filter, activeUserProfile, CourseTrainerFactory, ModalService) {

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
        $scope.clientId;
        $scope.clientName;

        /**
         * Set the client Id pon the scope
         */
        if ($scope.$parent.specialRequirementClientId) {
            $scope.clientId = $scope.$parent.specialRequirementClientId;
        }

        /**
         * Set client name on scope
         */
        if ($scope.$parent.specialRequirementClientName) {
            $scope.clientName = $scope.$parent.specialRequirementClientName;
        }

        /**
         * sET ORG
         */
        if ($scope.$parent.specialRequirementOrganisationId) {
            $scope.organisationId = $scope.$parent.specialRequirementOrganisationId;
        }


        /**
         * Get the list of special requirements 
         * That are the client has
         */
        $scope.getSelected = function () {

            ClientService.getSpecialRequirements(
                $scope.clientId, $scope.organisationId
            )
            .then(
                function (response) {
                    $scope.selected = response.data;
                    $scope.selected = $filter('orderBy')($scope.selected, 'Name');
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        /**
         * Gte the list of special requirements
         * For the organisation
         */
        $scope.getAvailable = function () {
            ClientService.getOrganisationSpecialRequirements(
                $scope.clientId, $scope.organisationId
            )
            .then(
                function (response) {
                    $scope.available = response.data;
                    $scope.available = $filter('filter')($scope.available, { 'Disabled': false });
                    $scope.available = $filter('orderBy')($scope.available, 'Name');

                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        /**
         * Call the methods to update the object
         */
        $scope.getAvailable();
        $scope.getSelected();

        /**
         * What happens
         * When an item is dragged and dropped
         * Into an area
         */
        $scope.processDataMove = function (option, event, from, to) {

            var newObject = {};
            var dataOptionObject = {
                clientId: $scope.clientId,
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
            if (to === "available" && from === "selected") {
                newObject = angular.extend(dataOptionObject, {
                    action: "remove",
                    clientSpecialRequirementId: option.ClientSpecialRequirementId
                });
            }

            /**
             * Dragging from the available to the selected
             */
            if (to === "selected" && from === "available") {
                newObject = angular.extend(dataOptionObject, {
                    action: "add",
                    specialRequirementId: option.Id,
                    userId: activeUserProfile.UserId
                });
            }


            /**
             * Call the update method 
             * To remove a client special requirement 
             * or add a client special requirement
             */
            ClientService.updateSpecialRequirements(newObject)
            .then(
                function (response) {
                    $scope.getAvailable();
                    $scope.getSelected();

                    /**
                     * Update the $parent special Requirements
                     * On the special Requirements modal
                     */
                    $scope.$parent.getClientSpecialRequirements(
                        $scope.clientId, $scope.organisationId
                    );
                },
                function (reason) {
                    console.log(reason);
                }
            );
        }

        /**
         * Open the modal to add a special requirement
         */
        $scope.openNewSpecialRequirementModal = function () {

            $scope.addRequirementOrganisation = $scope.organisationId;
            $scope.source = "Client";
            $scope.statusMessage = "";
            $scope.errorMessage = "";

            ModalService.displayModal({
                scope: $scope,
                title: "Client Additional Requirements",
                cssClass: "addSpecialRequirementModal",
                filePath: "/app/components/specialRequirements/add.html",
                controllerName: "AddSpecialRequirementCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }


    }

})();