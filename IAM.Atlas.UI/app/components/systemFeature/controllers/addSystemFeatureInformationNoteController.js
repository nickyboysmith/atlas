


(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddSystemFeatureInformationNoteCtrl', AddViewSystemFeatureInformationNoteCtrl);

    AddViewSystemFeatureInformationNoteCtrl.$inject = ["$scope", "$window", "SystemFeatureService"];

    function AddViewSystemFeatureInformationNoteCtrl($scope, $window, SystemFeatureService) {

        var systemFeatureService = SystemFeatureService;

        $scope.noteTypes = {};
        $scope.selectedNoteType = "-1";

        $scope.featureTitle = $scope.$parent.$parent.SystemFeaturePageName;
        $scope.noteContent = "";
        $scope.isShareInformation = false;

        $scope.featureNote = {
            Description: "",
            ShareInformation: false
        };

        $scope.getNoteTypes = function () {

            systemFeatureService.GetNoteTypes()

            .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.noteTypes = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        $scope.selectNoteType = function (selectedNoteType) {

            $scope.selectedNoteType = selectedNoteType;

        }

       
        $scope.save = function () {

            if ($scope.validateForm()) {

                var saveNote = {
                    noteTypeId: $scope.selectedNoteType,
                    systemFeatureItemId: $scope.$parent.descriptionNotes.Id,
                    addedByUserId: $scope.$parent.userId,
                    organisationId: $scope.$parent.organisationId,
                    noteContent: $scope.featureNote.Description,
                    shareInformation: $scope.featureNote.ShareInformation
                };

                systemFeatureService.SaveNote(saveNote) 
                    .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);

                                $scope.successMessage = "Save Successful";
                                $scope.validationMessage = "";

                                // refresh the feature groups
                                $scope.$parent.getDescriptionNotes();

                            },
                            function (response) {
                                console.log("Error");
                                console.log(response);
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            }
                        );
            }
        }

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (angular.isUndefined($scope.featureNote.Description)) {
                $scope.validationMessage = "Please enter a System Feature Note. ";
            }
            else if ($scope.featureNote.Description.length == 0) {
                $scope.validationMessage = "Please enter a System Feature Note. ";
            }

            if ($scope.selectedNoteType == -1) {
                $scope.validationMessage = $scope.validationMessage + "Please select the type of Note to save.";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getNoteTypes();
    }

})();
