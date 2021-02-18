(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddTrainerVehicleCtrl', AddTrainerVehicleCtrl);

    AddTrainerVehicleCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'VehicleTypeService', 'VehicleCategoryService', 'TrainerVehicleService'];

    function AddTrainerVehicleCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, VehicleTypeService, VehicleCategoryService, TrainerVehicleService) {

        $scope.trainerVehicleService = TrainerVehicleService;
        $scope.vehicleTypeService = VehicleTypeService;
        $scope.vehicleCategoryService = VehicleCategoryService;
        $scope.userService = UserService;

        $scope.userId = activeUserProfile.UserId;

        $scope.trainerDetails = {};
        $scope.vehicleTypes = {};
        $scope.vehicleCategories = {};

        $scope.addedTrainerVehicleDetails = {
            TrainerId: "",
            VehicleTypeId: "",
            TrainerVehicleNumberPlate: "",
            TrainerVehicleDescription: "",
            AddedByUserId: $scope.userId,
            VehicleCategoryIds: []
        };
       
        $scope.selectedTrainerVehicle = {
            selectedOrganisationId: null,
            selectedTrainerId: null,
            selectedVehicleTypeId: null
        };


        // from Admin
        if (angular.isDefined($scope.$parent.selectedTrainerVehicle.selectedOrganisationId)) {

            $scope.selectedTrainerVehicle.selectedOrganisationId = $scope.$parent.selectedTrainerVehicle.selectedOrganisationId;
        } // from About and Detail
        else if (angular.isDefined($scope.$parent.selectedOrganisationId))
        {
            $scope.selectedTrainerVehicle.selectedOrganisationId = $scope.$parent.selectedOrganisationId;
        }

        // from Admin
        if (angular.isDefined($scope.$parent.selectedTrainerVehicle.selectedTrainerId))
        {
            $scope.selectedTrainerVehicle.selectedTrainerId = $scope.$parent.selectedTrainerVehicle.selectedTrainerId;
            //$scope.addedTrainerVehicleDetails.TrainerId = $scope.$parent.selectedTrainerVehicle.selectedTrainerId;
        } // from About and Detail
        else if (angular.isDefined($scope.$parent.trainerId))
        {
            $scope.selectedTrainerVehicle.selectedTrainerId = $scope.$parent.trainerId;
            //$scope.addedTrainerVehicleDetails.TrainerId = $scope.$parent.trainerId;
        }

        // Details
        //if (angular.isDefined($scope.$parent.selectedTrainerVehicleDetails)) {

        //    $scope.addedTrainerVehicleDetails.TrainerName = $scope.$parent.selectedTrainerVehicleDetails.TrainerName;
        //    $scope.addedTrainerVehicleDetails.TrainerDateOfBirth = $scope.$parent.selectedTrainerVehicleDetails.TrainerDateOfBirth;
        //    $scope.addedTrainerVehicleDetails.TrainerLicenceNumber = $scope.$parent.selectedTrainerVehicleDetails.TrainerLicenceNumber;
        //} // About
        //else if (angular.isDefined($scope.$parent.aboutTrainerVehicleDetail)) {

        //    $scope.addedTrainerVehicleDetails.TrainerName = $scope.$parent.aboutTrainerVehicleDetail.TrainerName;
        //    $scope.addedTrainerVehicleDetails.TrainerDateOfBirth = $scope.$parent.aboutTrainerVehicleDetail.TrainerDateOfBirth;
        //    $scope.addedTrainerVehicleDetails.TrainerLicenceNumber = $scope.$parent.aboutTrainerVehicleDetail.TrainerLicenceNumber;
        //}


        $scope.setSelectedVehicleTypeId = function (VehicleTypeId) {
            $scope.selectedTrainerVehicle.selectedVehicleTypeId = VehicleTypeId;

            $scope.successMessage = '';
            $scope.validationMessage = '';

        }

        //Get Trainer Details
        $scope.getTrainerByTrainerId = function (TrainerId) {

            $scope.trainerDetails = {};

            $scope.trainerVehicleService.getTrainerById(TrainerId)
                .then(
                    function (response) {

                        $scope.trainerDetails = response.data;

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

                    },
                    function (response) {

                    }
                );
        }

        //Save Trainer Vehicle
        $scope.save = function () {

            $scope.addedTrainerVehicleDetails.VehicleTypeId = $scope.selectedTrainerVehicle.selectedVehicleTypeId;
            $scope.addedTrainerVehicleDetails.TrainerId = $scope.selectedTrainerVehicle.selectedTrainerId;

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

            $scope.addedTrainerVehicleDetails.VehicleCategoryIds = vehicleCategoryIds;


            $scope.trainerVehicleService.addTrainerVehicle($scope.addedTrainerVehicleDetails)
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
        
        $scope.getTrainerByTrainerId($scope.selectedTrainerVehicle.selectedTrainerId);
        $scope.getVehicleTypesByOrganisation($scope.selectedTrainerVehicle.selectedOrganisationId);
        $scope.getVehicleCategoriesByOrganisation($scope.selectedTrainerVehicle.selectedOrganisationId);
    }

})();