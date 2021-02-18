(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddInterpreterNoteCtrl', AddInterpreterNoteCtrl);

    AddInterpreterNoteCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'NoteTypeService', 'InterpreterLanguageService'];

    function AddInterpreterNoteCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, NoteTypeService, InterpreterLanguageService) {

        /**
        * Create the note types object
        */
        $scope.noteTypes = {};
        /**
         * Create the note object
         */

        $scope.note = {
            interpreterId: $scope.selectedInterpreter,
            organisationId: activeUserProfile.selectedOrganisation.Id,
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

                InterpreterLanguageService.saveNote($scope.note)
                .then(
                    function (response) {

                        $scope.getInterpreterNotesById($scope.selectedInterpreter);

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