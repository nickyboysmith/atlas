(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('EditTrainerVehicleCtrl', EditTrainerVehicleCtrl);

    EditTrainerVehicleCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'VehicleTypeService', 'VehicleCategoryService', 'TrainerVehicleService'];

    function EditTrainerVehicleCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, VehicleTypeService, VehicleCategoryService, TrainerVehicleService) {

        $scope.trainerVehicleService = TrainerVehicleService;
        $scope.vehicleTypeService = VehicleTypeService;
        $scope.vehicleCategoryService = VehicleCategoryService;
        $scope.userService = UserService;

        $scope.userId = activeUserProfile.UserId;

        $scope.vehicleTypes = {};
        $scope.vehicleCategories = {};

        $scope.editedTrainerVehicleDetails = {
            TrainerId: "",
            TrainerName: "",
            TrainerDateOfBirth: "",
            TrainerLicenceNumber: "",
            VehicleTypeId: "",
            TrainerVehicleNumberPlate: "",
            VehicleTypeName: "",
            TrainerVehicleDescription: "",
            UpdatedByUserId: $scope.userId,
            TrainerVehicleCategoryStringIds : "",
            VehicleCategoryIds: []
        };

        $scope.selectedTrainerVehicle = {
            selectedOrganisationId: null,
            selectedVehicleTypeId: null
        };


        // from Admin
        if (angular.isDefined($scope.$parent.selectedTrainerVehicle.selectedOrganisationId)) {

            $scope.selectedTrainerVehicle.selectedOrganisationId = $scope.$parent.selectedTrainerVehicle.selectedOrganisationId;
        } // from About and Detail
        else if (angular.isDefined($scope.$parent.selectedOrganisationId)) {
            $scope.selectedTrainerVehicle.selectedOrganisationId = $scope.$parent.selectedOrganisationId;
        }

        // from Admin
        if (angular.isDefined($scope.$parent.selectedTrainerVehicle.selectedTrainerId)) { // cant use
            $scope.editedTrainerVehicleDetails.TrainerId = $scope.$parent.selectedTrainerVehicle.selectedTrainerId;
        } // from About and Detail
        else if (angular.isDefined($scope.$parent.trainerId)) {
            $scope.editedTrainerVehicleDetails.TrainerId = $scope.$parent.trainerId;
        }

        // Details
        if (angular.isDefined($scope.$parent.selectedTrainerVehicleDetails)) {
            $scope.editedTrainerVehicleDetails.TrainerId = $scope.$parent.selectedTrainerVehicleDetails.TrainerId;
            $scope.editedTrainerVehicleDetails.TrainerName = $scope.$parent.selectedTrainerVehicleDetails.TrainerName;
            $scope.editedTrainerVehicleDetails.TrainerDateOfBirth = $scope.$parent.selectedTrainerVehicleDetails.TrainerDateOfBirth;
            $scope.editedTrainerVehicleDetails.TrainerLicenceNumber = $scope.$parent.selectedTrainerVehicleDetails.TrainerLicenceNumber;
            $scope.editedTrainerVehicleDetails.TrainerVehicleNumberPlate = $scope.$parent.selectedTrainerVehicleDetails.TrainerVehicleNumberPlate;
            $scope.editedTrainerVehicleDetails.TrainerVehicleDescription = $scope.$parent.selectedTrainerVehicleDetails.TrainerVehicleDescription;
            $scope.editedTrainerVehicleDetails.VehicleTypeId = $scope.$parent.selectedTrainerVehicleDetails.VehicleTypeId;
            $scope.editedTrainerVehicleDetails.VehicleTypeName = $scope.$parent.selectedTrainerVehicleDetails.VehicleTypeName;
            $scope.editedTrainerVehicleDetails.VehicleTypeDescription = $scope.$parent.selectedTrainerVehicleDetails.VehicleTypeDescription;
            $scope.editedTrainerVehicleDetails.TrainerVehicleCategoryStringIds = $scope.$parent.selectedTrainerVehicleDetails.TrainerVehicleCategoryIds;
            

        } // About
        else if (angular.isDefined($scope.$parent.aboutTrainerVehicleDetail)) {
            $scope.editedTrainerVehicleDetails.TrainerId = $scope.$parent.aboutTrainerVehicleDetail.TrainerId;
            $scope.editedTrainerVehicleDetails.TrainerName = $scope.$parent.aboutTrainerVehicleDetail.TrainerName;
            $scope.editedTrainerVehicleDetails.TrainerDateOfBirth = $scope.$parent.aboutTrainerVehicleDetail.TrainerDateOfBirth;
            $scope.editedTrainerVehicleDetails.TrainerLicenceNumber = $scope.$parent.aboutTrainerVehicleDetail.TrainerLicenceNumber;
            $scope.editedTrainerVehicleDetails.TrainerVehicleNumberPlate = $scope.$parent.aboutTrainerVehicleDetail.TrainerVehicleNumberPlate;
            $scope.editedTrainerVehicleDetails.TrainerVehicleDescription = $scope.$parent.aboutTrainerVehicleDetail.TrainerVehicleDescription;
            $scope.editedTrainerVehicleDetails.VehicleTypeId = $scope.$parent.aboutTrainerVehicleDetail.VehicleTypeId;
            $scope.editedTrainerVehicleDetails.VehicleTypeName = $scope.$parent.aboutTrainerVehicleDetail.VehicleTypeName;
            $scope.editedTrainerVehicleDetails.VehicleTypeDescription = $scope.$parent.aboutTrainerVehicleDetail.VehicleTypeDescription;
            $scope.editedTrainerVehicleDetails.TrainerVehicleCategoryStringIds = $scope.$parent.aboutTrainerVehicleDetail.TrainerVehicleCategoryIds;
        }

        //Get Vehicle Categories
        $scope.getVehicleCategoriesByOrganisation = function (organisationId) {

            $scope.vehicleCategories = {};

            $scope.vehicleCategoryService.getVehicleCategories(organisationId)
                .then(
                    function (response) {

                        $scope.vehicleCategories = response.data;

                        if ($scope.editedTrainerVehicleDetails.TrainerVehicleCategoryStringIds) {


                            var CategoryArray = $scope.editedTrainerVehicleDetails.TrainerVehicleCategoryStringIds.split(',');

                            angular.forEach($scope.vehicleCategories, function (value, key) {
                                for (var i = 0; i < CategoryArray.length; i++) {
                                    if (Number(CategoryArray[i].match(/\d+/)[0]) === value.Id) {
                                        value.isSelected = true;
                                        break;
                                    }
                                }
                            });
                        }
                    },
                    function (response) {

                    }
                );
        }

        //Remove Vehicle
        $scope.removeVehicle = function () {


            $scope.removedTrainerVehicleDetails = {
                TrainerId: $scope.editedTrainerVehicleDetails.TrainerId,
                VehicleTypeId: $scope.editedTrainerVehicleDetails.VehicleTypeId,
                RemovedByUserId: $scope.userId
            };

         
            $scope.trainerVehicleService.removeTrainerVehicle($scope.removedTrainerVehicleDetails)
                .then(
                    function (response) {

                        $scope.successMessage = response.data;
                        $scope.validationMessage = "";

                        if (angular.isDefined($scope.$parent.getTrainerVehicleDetailsByOrganisation)) {
                            $scope.$parent.getTrainerVehicleDetailsByOrganisation();
                        }
                        else if (angular.isDefined($scope.$parent.$parent.getTrainerVehicleDetailsByOrganisation)) {
                            $scope.$parent.$parent.getTrainerVehicleDetailsByOrganisation();
                        }


                    },
                    function (response) {

                        $scope.validationMessage = response.data
                        $scope.successMessage = "";
                    }
                );
        }
        


        //Save Trainer Vehicle
        $scope.save = function () {

            var vehicleCategoryIds = {
                categoryIds: []
            };

            //Filter out selected Vehicle Categories
            var selectedVehicleCategories = $filter("filter")($scope.vehicleCategories, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedVehicleCategories.forEach(function (arrayItem) {
                var x = arrayItem.Id
                vehicleCategoryIds.categoryIds.push(x);
            });

            $scope.editedTrainerVehicleDetails.VehicleCategoryIds = vehicleCategoryIds;

            $scope.trainerVehicleService.editTrainerVehicle($scope.editedTrainerVehicleDetails)
                .then(
                    function (response) {

                        $scope.successMessage = "Save Successful";
                        $scope.validationMessage = "";

                        if (angular.isDefined($scope.$parent.getTrainerVehicleDetailsByOrganisation)) {
                            $scope.$parent.getTrainerVehicleDetailsByOrganisation();
                        }
                        else if (angular.isDefined($scope.$parent.$parent.getTrainerVehicleDetailsByOrganisation)) {
                            $scope.$parent.$parent.getTrainerVehicleDetailsByOrganisation();
                        }
                    },
                    function (response) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }

        //Set Selected Vehicle Categories
        $scope.setSelectedCategories = function (VehicleCategory) {

            VehicleCategory.isSelected ? VehicleCategory.isSelected = false : VehicleCategory.isSelected = true;

        }

        $scope.getVehicleCategoriesByOrganisation($scope.selectedTrainerVehicle.selectedOrganisationId);
    }

})();