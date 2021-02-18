(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller("VehicleCategoryAdminCtrl", VehicleCategoryAdminCtrl);

    VehicleCategoryAdminCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'VehicleCategoryService'];

    function VehicleCategoryAdminCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, VehicleCategoryService) {

        $scope.vehicleCategory = {
            VehicleCategoryName: "",
            VehicleCategoryDisabled: false,
            VehicleCategoryDescription: "",
            OrganisationId: $scope.$parent.organisationId,
            AddedByUserId: $scope.$parent.userId
        };

        $scope.VehicleCategoryService = VehicleCategoryService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.vehicleCategories = [];
        $scope.selectedVehicleCategory = [];

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
        $scope.setSelectedVehicleCategory = function (vehicleCategory) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedVehicleCategory = vehicleCategory;
            $scope.selectedVehicleCategoryId = vehicleCategory.Id;
        }

        //Get Vehicle Categories
        $scope.getVehicleCategories = function (organisationId) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.VehicleCategoryService.getVehicleCategories(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.vehicleCategories = response.data;

                        if ($scope.vehicleCategories.length > 0) {
                            $scope.selectedVehicleCategory = $scope.vehicleCategories[0];
                            $scope.selectedVehicleCategoryId = $scope.vehicleCategories[0].Id;
                        }


                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }


        /**
         * Open the Add Vehicle Category modal
         */
        $scope.add = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Vehicle Category",
                closable: true,
                filePath: "/app/components/vehicleCategory/add.html",
                controllerName: "AddVehicleCategoryCtrl",
                cssClass: "addVehicleCategoryModal",
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
         * Save Vehicle Category
         */
        $scope.save = function () {

            if ($scope.validateVehicleCategory()) {

                $scope.selectedVehicleCategory.UpdatedByUserId = $scope.userId;

                $scope.VehicleCategoryService.saveVehicleCategory($scope.selectedVehicleCategory)
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


        $scope.validateVehicleCategory = function () {

            $scope.validationMessage = '';

            if ($scope.selectedVehicleCategory.Name.length == 0) {
                $scope.validationMessage = "Please enter a Vehicle Category Name.";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getVehicleCategories($scope.organisationId);

    }

})();