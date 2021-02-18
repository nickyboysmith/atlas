(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller("VehicleTypeAdministrationCtrl", VehicleTypeAdministrationCtrl);

    VehicleTypeAdministrationCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'VehicleTypeService'];

    function VehicleTypeAdministrationCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, VehicleTypeService) {

        $scope.vehicleType = {
            VehicleTypeName: "",
            VehicleTypeDescription: "",
            VehicleTypeDisabled: false,
            VehicleTypeAutomatic: false,
            OrganisationId: $scope.$parent.organisationId,
            CreatedByUserId: $scope.$parent.userId
        };

        $scope.VehicleTypeService = VehicleTypeService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.vehicleTypes = [];
        $scope.selectedVehicleType = [];

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
        ;
        $scope.setSelectedVehicleType = function (vehicleType) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedVehicleType = vehicleType;
           // $scope.selectedTaskCategoryId = taskCategory.TaskCategoryId; ????
        }

        //Get Vehicle Types
        $scope.getVehicleTypes = function (organisationId) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.VehicleTypeService.getVehicleTypes(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.vehicleTypes = response.data;

                        if ($scope.vehicleTypes.length > 0) {
                            $scope.selectedVehicleType = $scope.vehicleTypes[0].Id;
                        }


                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }


        /**
         * Open the add Vehicle Type
         */
        $scope.add = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Vehicle Type",
                closable: true,
                filePath: "/app/components/vehicleType/add.html",
                controllerName: "AddVehicleTypeCtrl",
                cssClass: "addVehicleTypeModal",
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
         * save Vehicle Type
         */
        $scope.save = function () {

            if ($scope.validateVehicleType()) {

                $scope.selectedVehicleType.UpdatedByUserId = $scope.userId;

                $scope.VehicleTypeService.saveVehicleType($scope.selectedVehicleType)
                    .then(
                        function (response) {

                            $scope.successMessage = response.data;
                            $scope.validationMessage = "";
                        },
                        function (response) {

                            $scope.successMessage = "";
                            $scope.validationMessage = response.data;
                        }
                    );
            }
        }


        $scope.validateVehicleType = function () {

            $scope.validationMessage = '';

            if ($scope.selectedVehicleType.Name.length == 0) {
                $scope.validationMessage = "Please enter a Vehicle Type Name.";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getVehicleTypes($scope.organisationId);

    }

})();