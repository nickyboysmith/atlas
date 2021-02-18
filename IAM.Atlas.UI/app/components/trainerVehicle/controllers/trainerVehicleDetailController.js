(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('TrainerVehicleDetailCtrl', TrainerVehicleDetailCtrl);

    TrainerVehicleDetailCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'DateFactory', 'VehicleTypeService', 'VehicleCategoryService', 'TrainerVehicleService'];

    function TrainerVehicleDetailCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, DateFactory, VehicleTypeService, VehicleCategoryService, TrainerVehicleService) {

        $scope.trainerVehicleService = TrainerVehicleService;
        $scope.userService = UserService;

        $scope.userId = activeUserProfile.UserId;

        // Put the selectedTrainerVehicle from the Trainer About page on the scope
        if (angular.isDefined($scope.$parent.aboutTrainerVehicleDetail)) {
            $scope.selectedTrainerVehicleDetails = angular.copy($scope.$parent.aboutTrainerVehicleDetail);
        }

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


    }

})();