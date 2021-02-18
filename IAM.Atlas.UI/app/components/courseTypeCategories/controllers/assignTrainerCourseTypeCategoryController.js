(function () {

    'use strict';

    angular
        .module("app")
        .controller("AssignTrainerCourseTypeCategoriesCtrl", AssignTrainerCourseTypeCategoriesCtrl);

    AssignTrainerCourseTypeCategoriesCtrl.$inject = ["$scope", "activeUserProfile", "trainerSearchService", "UserService", "TrainerAvailabiltyService", "ModalOptionsFactory", "ModalService"];

    function AssignTrainerCourseTypeCategoriesCtrl($scope, activeUserProfile, trainerSearchService, UserService, TrainerAvailabiltyService, ModalOptionsFactory, ModalService) {


        /**
         * If userAdmin
         */
        $scope.isAdmin;

        /**
         * Instantiate the scope property
         * Default the showOrganisationDropdown to false
         */
        $scope.showOrganisationDropdown = false;

        /**
         * Instantiate the scope property
         * Default the showTrainerList to false
         */
        $scope.showTrainerList = false;

        /**
         * Instantiate an empty array of objetcs
         * For the trainer collection to copy the trainer List Array
         */
        $scope.trainerCollection = [];

        /**
         * Instatiate slectedOrganisation scope on the property
         * Create id property on the Id to use for users who arent sysadmins
         * 
         */ 
        $scope.selectedOrganisation = {
            id: ""
        };

        /**
         * Check user 
         */
        UserService.getOrganisationIds(activeUserProfile.UserId)
        // UserService.getOrganisationIds(2) // Test org that isnt a sys admin
            .then(
                function (response) {

                    if (response.length == 0) {
                        console.log("Do that");
                    } else if (response.length == 1) {
                        $scope.selectedOrganisation.id = response[0].id;
                        $scope.getTrainerList($scope.selectedOrganisation.id);
                    } else {
                        $scope.showOrganisationDropdown = true;
                        $scope.organisationList = response;
                    }

                },
                function (reason) {
                    console.log(response);
                }
            );


        /**
         * Get the trainer list 
         * Then assign to the property trainerList
         */
        $scope.getTrainerList = function (organisationId) {
            trainerSearchService.GetTrainersByOrganisation(organisationId)
            .then(
                function (response) {
                    if (response.length > 0) {
                        /**
                         * Put the trainer list in a scope property
                         */
                        $scope.trainerList = response;

                        /**
                         * Fill the trainerCollection with the trainerList
                         */
                        angular.forEach($scope.trainerList, function (trainer, index) {
                            $scope.trainerCollection.push(trainer);
                        });
                        $scope.showTrainerList = true;
                    }
                },
                function (reason) {
                    console.log("Handle error");
                    console.log(reason);
                }
            );
        };

        /**
         * Get the trainer list
         * For the selected organisation
         */
        $scope.getTrainerForTheOrganisation = function (organisation) {
            /**
             * Set the organisation on the scope property selectedOrganisation
             */
            $scope.selectedOrganisation = organisation;
            $scope.getTrainerList(organisation.id);
        };

        /**
         * Get the available course types 
         * For the selected trainer
         */
        $scope.selectTheTrainer = function (trainer) {

            console.log(trainer);
            console.log("Call the service");
            /**
             * Assign the tainer variable
             * To the 'selectedTrainer' property on the scope
             */
            $scope.selectedTrainer = trainer;

            /**
             * Extend the modal!
             */
            ModalOptionsFactory.extend({
                mainModalID: "#assignTrainerCourseTypeCategories",
                firstColumn: "#assignTrainerFirstModalColumn",
                secondColumn: "#additionalAssignTrainerContainer",
                classToRemove: "col-md-12",
                classToAdd: "col-md-5",
                cssProperties: {
                    width: "750px"
                }
            });
 
            $scope.getTheAvailableCourseTypes();
        };

        /**
         * Open the Modal to update the course types
         */
        $scope.openAssignCourseTypesModal = function () {

            // Put a diff trainer If on scope
            $scope.replaceTrainerId = $scope.selectedTrainer.Id;
            $scope.replaceOrganisationId = $scope.selectedOrganisation.id;

            ModalService.displayModal({
                scope: $scope,
                title: "Update " + $scope.selectedTrainer.DisplayName + "'s Course Types",
                cssClass: "updateTrainerCourseTypeCategoriesModal",
                filePath: "/app/components/courseTypeCategories/updateTrainer.html",
                controllerName: "AvailableTrainerCourseTypesCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        /**
         * 
         */
        $scope.getTheAvailableCourseTypes = function () {
            TrainerAvailabiltyService.getCourseTypes($scope.selectedTrainer.Id, $scope.selectedOrganisation.id)
            .then(
                function (response) {
                    $scope.trainerSelectedCourseTypes = response;
                },
                function (reason) {
                }
            );
        };



    }


})();