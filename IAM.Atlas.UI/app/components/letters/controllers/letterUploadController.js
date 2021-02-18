(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('letterUploadCtrl', letterUploadCtrl);

    letterUploadCtrl.$inject = ["$scope", "UserService", "activeUserProfile", "OrganisationService", "LetterService"];

    function letterUploadCtrl($scope, UserService, activeUserProfile, OrganisationService, LetterService) {

        $scope.theLabel = "Organisation";
        $scope.theLabelValue = "";
        $scope.theMaxSize = 1000;

        $scope.successMessage = '';
        $scope.errorMessage = '';

        /**
        * Create form data to send to the web api
        * ?? Put  in a factory
        */
        $scope.convertFormData = function (document, letterActionId, documentTemplateId) {
            var description = "";
            if (document.Description) {
                description = document.Description;
            }
            var formData = new FormData();
            formData.append("Name", document.Name);
            formData.append("Title", document.Title);
            formData.append("Description", description);
            formData.append("FileName", document.Name);
            formData.append("OriginalFileName", document.FileName);
            formData.append("file", document.File);
            formData.append("UserId", activeUserProfile.UserId);
            formData.append("OrganisationId", activeUserProfile.selectedOrganisation.Id);
            formData.append("LetterActionId", letterActionId);
            formData.append("DocumentTemplateId", documentTemplateId);
            formData.append("LetterCategoryId", $scope.$parent.selectedLetterTemplate.LetterCategoryId);
            return formData;
        };

        $scope.saveFile = function (document) {
            LetterService.uploadTemplateDocument($scope.convertFormData(document, $scope.letterActionId, $scope.documentTemplateId))
                            .then(
                                function (data) {
                                    if (data < 1) {
                                        $scope.errorMessage = 'Letter template upload failed.';
                                    }
                                    else if (data > 0) {
                                        $scope.successMessage = "Letter template uploaded successfully.";
                                        $scope.loadLetters($scope.selectedOrganisationId);
                                    }
                                    else
                                    {
                                        $scope.errorMessage = 'An error occurred: ' + data.ExceptionMessage;
                                    }

                                    if (angular.isDefined($scope.$parent.getLetterTemplateCategoriesByOrganisation)) {
                                        $scope.$parent.getLetterTemplateCategoriesByOrganisation($scope.$parent.selectedOrganisationId);
                                    }
                                },
                                function (data) {
                                    $scope.errorMessage = 'An error occurred: ' + data.ExceptionMessage;
                                }
                            );
        }

        OrganisationService.Get($scope.selectedOrganisationId)
                .then(
                    function (data) {
                        if (data) {
                            $scope.theLabelValue = data.Name;
                        }
                    },
                    function (data) { }
                );
        }

})();