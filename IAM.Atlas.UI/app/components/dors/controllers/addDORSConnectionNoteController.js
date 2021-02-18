(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddDORSConnectionNoteCtrl", AddDORSConnectionNoteCtrl);

    AddDORSConnectionNoteCtrl.$inject = ["$scope", "NoteTypeService", "DorsConnectionDetailsService", "ModalService", "activeUserProfile"];

    function AddDORSConnectionNoteCtrl($scope, NoteTypeService, DorsConnectionDetailsService, ModalService, activeUserProfile) {

        console.log($scope);

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        /**
         * Create the note types object
         */
        $scope.noteTypes = [];

        /**
         * Load the not types
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
         * Create the note object
         */
        $scope.note = {
            organisationId: activeUserProfile.selectedOrganisation.Id,
            userId: activeUserProfile.UserId
        };

        /**
         * Save the 
         */
        $scope.saveTheNote = function () {

            $scope.note.type = $scope.note.type.Id;

            DorsConnectionDetailsService.saveConnectionNote($scope.note)
                .then(
                    function (response) {
                        if (response === "success") {

                            $scope.showSuccessFader = true;
                           
                            $scope.$parent.getConnectionNotes();
                            ModalService.closeCurrentModal("addDORSConnectionNoteModal");
                        }
                    },
                    function (response) {

                        $scope.showErrorFader = true;
                    }
                );


        };

    }



})();