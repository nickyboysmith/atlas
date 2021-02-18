(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddTrainerVehicleNoteCtrl', AddTrainerVehicleNoteCtrl);

    AddTrainerVehicleNoteCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'NoteTypeService', 'TrainerVehicleService'];

    function AddTrainerVehicleNoteCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, NoteTypeService, TrainerVehicleService) {

        /**
        * Create the note types object
        */
        $scope.noteTypes = {};
        /**
         * Create the note object
         */

        $scope.note = {
            trainerVehicleId: $scope.$parent.selectedTrainerVehicleDetailId,
            organisationId: $scope.$parent.selectedTrainerVehicle.selectedOrganisationId,
            userId: activeUserProfile.UserId,
            text: "",
            type: ""
        };

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        /**
         * Get the NoteTypes
         */
        NoteTypeService.getNoteTypes()
            .then(
                function (response) {
                    $scope.noteTypes = response;
                    $scope.note.type = $scope.noteTypes[0];
                },
                function (response) {
                    console.log(response);
                }
            );

        /**
         * Save Note
         */
        $scope.save = function () {

            if ($scope.selectedNoteType) {

                TrainerVehicleService.saveNote($scope.note)
                .then(
                    function (response) {
                        
                        $scope.$parent.getTrainerVehicleNotesById($scope.$parent.selectedTrainerVehicle.selectedOrganisationId, $scope.$parent.selectedTrainerVehicleDetailId);

                        $('button.close').last().trigger('click');
                    },
                    function (reason) {
                        console.log(reason);
                    }
                )
            }
            else {

                $scope.selectNoteValidationMessage = "Please select a Note Type."
            }
        };

        $scope.selectNoteType = function (note) {
            $scope.selectedNoteType = note
            $scope.selectNoteValidationMessage = "";
        }

    }

})();