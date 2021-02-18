(function () {

    'use strict';

    angular
        .module("app")
        .controller("SystemFeatureInformationCtrl", SystemFeatureInformationCtrl);

    SystemFeatureInformationCtrl.$inject = ["$scope", "SystemFeatureService", "activeUserProfile", "ModalService"];

    function SystemFeatureInformationCtrl($scope, SystemFeatureService, activeUserProfile, ModalService)
    {


        /**
         * Initialize the system feature Id
         */
        $scope.systemFeatureId = 0;

        /**
         * Initialize the system feature title
         */
        $scope.systemFeatureTitle = "";

        /**
         * Initialize the system feature Description
         */
        $scope.systemFeatureDescription;

        /**
         * Initialize the show system feature notes
         */
        $scope.showSystemFeatureNotes = false;

        /**
         * Intitalize the notes array
         */
        $scope.systemFeatureNotes = [];

        /**
         * Check the systemFeatureId exists
         * If it does assign it
         */
        if ($scope.$parent.systemFeatureId !== undefined) {
            $scope.systemFeatureId = $scope.$parent.systemFeatureId;
        }

        /**
         * Check the systemFeatureId exists
         * If it does assign it
         */
        if ($scope.$parent.systemFeatureTitle !== undefined) {
            $scope.systemFeatureTitle = $scope.$parent.systemFeatureTitle;
        }

        /**
         * Get System information
         */
        $scope.getTheInformation = function (featureId, organisationId) {
            SystemFeatureService.getInformation(
                featureId,
                organisationId
            )
            .then(
                function (response) {
                    $scope.systemFeatureDescription = response.data.Description;
                    /**
                     * Check to see if there are any notes inthe object
                     */
                    if (response.data.Notes.length !== 0) {
                        $scope.systemFeatureNotes = response.data.Notes;
                        $scope.showSystemFeatureNotes = true;
                    }
                },
                function (reason) {
                    console.log(reason.data);
                }
            );
        };

        /**
         * 
         */
        $scope.getTheInformation(
            $scope.systemFeatureId,
            activeUserProfile.selectedOrganisation.Id
        );

        /**
         * Open the add note modal
         */
        $scope.openAddNoteModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: $scope.systemFeatureTitle,
                cssClass: "systemFeatureAddNoteModal",
                filePath: "/app/components/systemFeature/addNote.html",
                controllerName: "AddSystemFeatureNoteCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

    }

})();