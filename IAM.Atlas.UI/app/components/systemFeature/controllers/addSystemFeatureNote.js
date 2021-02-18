(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddSystemFeatureNoteCtrl", AddSystemFeatureNoteCtrl);

    AddSystemFeatureNoteCtrl.$inject = ["$scope", "activeUserProfile", "NoteTypeService", "SystemFeatureService", "ModalService"];

    function AddSystemFeatureNoteCtrl($scope, activeUserProfile, NoteTypeService, SystemFeatureService, ModalService) {

        /**
         * Create the note object
         */
        $scope.note = {
            organisationId: activeUserProfile.selectedOrganisation.Id,
            userId: activeUserProfile.UserId,
            shareInformation: false,
            systemFeatureId: $scope.$parent.systemFeatureId
        };

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
         * Send note data to the web api
         */
        $scope.save = function () {
            SystemFeatureService.saveNote($scope.note)
            .then(
                function (response) {
                    $scope.$parent.getTheInformation(
                        $scope.$parent.systemFeatureId,
                        activeUserProfile.selectedOrganisation.Id
                    );
                    ModalService.closeCurrentModal("systemFeatureAddNoteModal");
                },
                function (reason) {
                    console.log(reason);
                }
            )
        };


    }

})();