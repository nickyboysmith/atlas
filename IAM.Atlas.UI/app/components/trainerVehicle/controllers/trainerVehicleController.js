(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('TrainerVehicleCtrl', TrainerVehicleCtrl);

    TrainerVehicleCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'DateFactory', 'VehicleTypeService', 'VehicleCategoryService', 'TrainerVehicleService'];

    function TrainerVehicleCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, DateFactory, VehicleTypeService, VehicleCategoryService, TrainerVehicleService) {

        $scope.trainerVehicleService = TrainerVehicleService;
        $scope.vehicleTypeService = VehicleTypeService;
        $scope.vehicleCategoryService = VehicleCategoryService;
        $scope.userService = UserService;
        
        $scope.userId = activeUserProfile.UserId;
 
        $scope.selectedTrainerVehicle = {
            selectedOrganisationId: null,
            selectedTrainerId: null,
            selectedVehicleTypeId: null,
            selectedVehicleCategoryId: null
        };

        $scope.selectedTrainerVehicleDetailId = "";

        $scope.trainers = {};
        $scope.vehicleTypes = {};
        $scope.vehicleCategories = {};

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        // refresh dropdowns with selected Organisation data
        $scope.getTrainerVehicleDropdownDataByOrganisation = function (organisationId) {

            $scope.selectedTrainerVehicle.selectedOrganisationId = organisationId;

            $scope.getTrainersByOrganisation(organisationId);
            $scope.getVehicleTypesByOrganisation(organisationId);
            $scope.getVehicleCategoriesByOrganisation(organisationId);

            $scope.getTrainerVehicleDetailsByOrganisation();

        }

        // set selected values on the scope
        $scope.setSelectedTrainerId = function (TrainerId) {
            $scope.selectedTrainerVehicle.selectedTrainerId = TrainerId;
            $scope.getTrainerVehicleDetailsByOrganisation();
        }
        
        $scope.setSelectedVehicleTypeId = function (VehicleTypeId) {
            $scope.selectedTrainerVehicle.selectedVehicleTypeId = VehicleTypeId;
            $scope.getTrainerVehicleDetailsByOrganisation();
        }
    
        $scope.setSelectedVehicleCategoryId = function (VehicleCategoryId) {
            $scope.selectedTrainerVehicle.selectedVehicleCategoryId = VehicleCategoryId;
            $scope.getTrainerVehicleDetailsByOrganisation();
        }

        $scope.setSelectedTrainerVehicleDetails = function (trainerVehicleDetails) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedTrainerVehicleDetails = angular.copy(trainerVehicleDetails);
            $scope.selectedTrainerVehicleDetailId = trainerVehicleDetails.TrainerVehicleId;
        }


        //Get Trainers
        $scope.getTrainersByOrganisation = function (organisationId) {

            $scope.trainers = {};

            $scope.trainerVehicleService.getTrainersByOrganisation(organisationId)
                .then(
                    function (response) {
                       
                        $scope.trainers = response.data;

                        $scope.ALLItem = {
                            Id: null,
                            DisplayName: "*ALL*",
                            LicenceNumber: "*ALL*"
                        };

                        $scope.trainers.unshift($scope.ALLItem);

                        if ($scope.trainers.length > 0) {
                            $scope.selectedTrainerVehicle.selectedTrainerId = $scope.trainers[0].Id;
                        }
                    },
                    function (response) {   
                    }
                );
        }

        //Get Vehicle Types
        $scope.getVehicleTypesByOrganisation = function (organisationId) {

            $scope.vehicleTypes = {};

            $scope.vehicleTypeService.getVehicleTypes(organisationId)
                .then(
                    function (response) {
                       
                        $scope.vehicleTypes = response.data;

                        $scope.ALLItem = {
                            Id: null,
                            Name: "*ALL*"
                        };

                        $scope.vehicleTypes.unshift($scope.ALLItem);

                        if ($scope.vehicleTypes.length > 0) {
                            $scope.selectedTrainerVehicle.selectedVehicleTypeId = $scope.vehicleTypes[0].Id;
                        }
                    },
                    function (response) {
                       
                    }
                );
        }

        //Get Vehicle Categories
        $scope.getVehicleCategoriesByOrganisation = function (organisationId) {

            $scope.vehicleCategories = {};

            $scope.vehicleCategoryService.getVehicleCategories(organisationId)
                .then(
                    function (response) {

                        $scope.vehicleCategories = response.data;

                        $scope.ALLItem = {
                            Id: null,
                            Name: "*ALL*"
                        };

                        $scope.vehicleCategories.unshift($scope.ALLItem);

                        if ($scope.vehicleCategories.length > 0) {
                            $scope.selectedTrainerVehicle.selectedVehicleCategoryId = $scope.vehicleCategories[0].Id;
                        }
                    },
                    function (response) {
                       
                    }
                );
        }

        //Get Vehicle Trainer Details
        $scope.getTrainerVehicleDetailsByOrganisation = function () {

            $scope.trainerVehicleDetails = {};

            $scope.trainerVehicleService.getTrainerVehicleDetailsByOrganisation($scope.selectedTrainerVehicle)
                .then(
                    function (response) {

                        $scope.trainerVehicleDetails = response.data;

                        if ($scope.trainerVehicleDetails.length > 0) {
                            $scope.selectedTrainerVehicleDetails = $scope.trainerVehicleDetails[0];
                            $scope.selectedTrainerVehicleDetailId = $scope.trainerVehicleDetails[0].TrainerVehicleId;
                            //$scope.selectedTrainerVehicle.selectedTrainerId = $scope.trainerVehicleDetails[0].TrainerId;
                        }
                        else {
                            $scope.selectedTrainerVehicleDetails = {};
                        }
                    },
                    function (response) {

                    }
                );

        }


        $scope.getTrainerVehicleNotesById = function (OrganisationId, TrainerVehicleId) {
            $scope.trainerVehicleService.getTrainerVehicleNotesById(OrganisationId, TrainerVehicleId)
                    .then(
                        function (response) {
                            $scope.selectedTrainerVehicleDetails.TrainerVehicleNotes = response.data[0].Notes;
                        },
                        function (response) {
                        }
                    );
        }

        $scope.isTrainerSelected = function () {

                if ($scope.selectedTrainerVehicle.selectedTrainerId == null) {
                    return true;
                }
                else {
                    return false;
            }
        }
        
        $scope.isTrainerVehicleSelected = function () {

            if (angular.isDefined($scope.selectedTrainerVehicleDetails)) {

                if (angular.equals({}, $scope.selectedTrainerVehicleDetails)) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }

        }

        /**
       * Open the Add Trainer Vehicle Modal
       */
        $scope.openAddTrainerVehicleModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add New/Additional Trainer Vehicle",
                closable: true,
                filePath: "/app/components/TrainerVehicle/add.html",
                controllerName: "AddTrainerVehicleCtrl",
                cssClass: "AddTrainerVehicleModal",
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
        * Open the Edit Trainer Vehicle Modal
        */
        $scope.openEditTrainerVehicleModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Edit Trainer Vehicle",
                closable: true,
                filePath: "/app/components/TrainerVehicle/edit.html",
                controllerName: "EditTrainerVehicleCtrl",
                cssClass: "EditTrainerVehicleModal",
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
        * Open the add note modal
        */
        $scope.openAddNoteModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Note",
                closable: true,
                filePath: "/app/components/TrainerVehicle/addNote.html",
                controllerName: "AddTrainerVehicleNoteCtrl",
                cssClass: "AddTrainerVehicleNoteModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.selectedTrainerVehicle.selectedOrganisationId = $scope.organisationId;

        $scope.getOrganisations($scope.userId);
        $scope.getTrainersByOrganisation($scope.organisationId);
        $scope.getVehicleTypesByOrganisation($scope.organisationId);
        $scope.getVehicleCategoriesByOrganisation($scope.organisationId);
        $scope.getTrainerVehicleDetailsByOrganisation();

    }

})();