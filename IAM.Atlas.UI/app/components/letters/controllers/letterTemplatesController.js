(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('letterTemplatesCtrl', letterTemplatesCtrl);

    letterTemplatesCtrl.$inject = ["$scope", "$filter", "UserService", "activeUserProfile", "ModalService", "LetterService", "DateFactory", "DocumentDownloadService"];

    function letterTemplatesCtrl($scope, $filter, UserService, activeUserProfile, ModalService, LetterService, DateFactory, DocumentDownloadService) {

        $scope.selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
        
        $scope.letterTemplateCategories = {};
        $scope.validationMessage = '';

        $scope.clearLetterFields = function () {
            $scope.confirmationId = 0;
            $scope.confirmationDisabled = true;
            $scope.confirmationName = "";
            $scope.confirmationTitle = "";
            $scope.confirmationNotes = "";
            $scope.confirmationUpdated = "";

            $scope.interpreterId = 0;
            $scope.interpreterDisabled = true;
            $scope.interpreterName = "";
            $scope.interpreterTitle = "";
            $scope.interpreterNotes = "";
            $scope.interpreterUpdated = "";

            $scope.instalmentsId = 0;
            $scope.instalmentsDisabled = true;
            $scope.instalmentsName = "";
            $scope.instalmentsTitle = "";
            $scope.instalmentsNotes = "";
            $scope.instalmentsUpdated = "";

            $scope.blankId = 0;
            $scope.blankDisabled = true;
            $scope.blankName = "";
            $scope.blankTitle = "";
            $scope.blankNotes = "";
            $scope.blankUpdated = "";

            $scope.cancellationId = 0;
            $scope.cancellationDisabled = true;
            $scope.cancellationName = "";
            $scope.cancellationTitle = "";
            $scope.cancellationNotes = "";
            $scope.cancellationUpdated = "";
        }

        /**
         * Convert date
         */
        $scope.convertDateTime = function (theDate) {
            return DateFactory.convertDateTime(theDate);
        };

        //Get Organisations function
        $scope.getOrganisations = function (userId) {
            UserService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                $scope.selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
                UserService.checkSystemAdminUser(userId)
                    .then(function (data) {
                        $scope.isAdmin = data;
                        $scope.loadLetters($scope.selectedOrganisationId);
                    });
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getSelectedLetterTemplateDetails = function (letterCategoryId, letterCategoryCode) {
            $scope.selectedLetterTemplate = $filter("filter")($scope.letterTemplateCategories, { LetterCategoryId: letterCategoryId, LetterCategoryCode: letterCategoryCode });
            $scope.selectedLetterTemplate = $scope.selectedLetterTemplate[0];
        }

        //Get Categories
        $scope.getLetterTemplateCategoriesByOrganisation = function (organisationId) {
            LetterService.getLetterTemplateCategoriesByOrganisation(organisationId)
                .then(
                function (data) {
                    $scope.letterTemplateCategories = data;
                    $scope.getSelectedLetterTemplateDetails($scope.letterTemplateCategories[0].LetterCategoryId, $scope.letterTemplateCategories[0].LetterCategoryCode);

                }, function (data) {
                });
        }

        $scope.getSelectedOrganisationId = function () {
            var selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
            return selectedOrganisationId;
        }



        $scope.loadLetters = function (organisationId) {
            LetterService.getByOrganisation(organisationId)
                .then(
                    function (data) {
                        $scope.letterTemplates = data;
                        $scope.clearLetterFields();
                        for (var i = 0; i < $scope.letterTemplates.length; i++){
                            switch ($scope.letterTemplates[i].ActionName.toLowerCase()) {
                                case 'confirmation':
                                    $scope.confirmationId = $scope.letterTemplates[i].Id;
                                    $scope.confirmationDisabled = false;
                                    $scope.confirmationName = $scope.letterTemplates[i].FileName;
                                    $scope.confirmationTitle = $scope.letterTemplates[i].Title;
                                    $scope.confirmationNotes = $scope.letterTemplates[i].Notes;
                                    $scope.confirmationUpdated = $scope.letterTemplates[i].LastUpdated;
                                    break;
                                case 'interpreter':
                                    $scope.interpreterId = $scope.letterTemplates[i].Id;
                                    $scope.interpreterDisabled = false;
                                    $scope.interpreterName = $scope.letterTemplates[i].FileName;
                                    $scope.interpreterTitle = $scope.letterTemplates[i].Title;
                                    $scope.interpreterNotes = $scope.letterTemplates[i].Notes;
                                    $scope.interpreterUpdated = $scope.letterTemplates[i].LastUpdated;
                                    break;
                                case 'instalments':
                                    $scope.instalmentsId = $scope.letterTemplates[i].Id;
                                    $scope.instalmentsDisabled = false;
                                    $scope.instalmentsName = $scope.letterTemplates[i].FileName;
                                    $scope.instalmentsTitle = $scope.letterTemplates[i].Title;
                                    $scope.instalmentsNotes = $scope.letterTemplates[i].Notes;
                                    $scope.instalmentsUpdated = $scope.letterTemplates[i].LastUpdated;
                                    break;
                                case 'blank':
                                    $scope.blankId = $scope.letterTemplates[i].Id;
                                    $scope.blankDisabled = false;
                                    $scope.blankName = $scope.letterTemplates[i].FileName;
                                    $scope.blankTitle = $scope.letterTemplates[i].Title;
                                    $scope.blankNotes = $scope.letterTemplates[i].Notes;
                                    $scope.blankUpdated = $scope.letterTemplates[i].LastUpdated;
                                    break;
                                case 'cancellation':
                                    $scope.cancellationId = $scope.letterTemplates[i].Id;
                                    $scope.cancellationDisabled = false;
                                    $scope.cancellationName = $scope.letterTemplates[i].FileName;
                                    $scope.cancellationTitle = $scope.letterTemplates[i].Title;
                                    $scope.cancellationNotes = $scope.letterTemplates[i].Notes;
                                    $scope.cancellationUpdated = $scope.letterTemplates[i].LastUpdated;
                                    break;
                                default:
                                    break;
                            }
                        }
                    },
                    function (data) {

                    }
                );
        }

        $scope.save = function (templateId, title) {
            if (templateId > 0) {
                LetterService.saveTemplate(templateId, title)
                    .then(
                        function (data) {
                            if (data == false) {
                                $scope.validationMessage = 'Letter template save failed.';
                            }
                            else if (data == true){
                                $scope.validationMessage = "Letter template saved successfully.";
                            }
                        },
                        function (data) {
                            $scope.validationMessage = 'An error occurred: ' + data;
                        }
                    );
            }
        }


        //Load template details
    

        // TODO: remove hard coding
        $scope.getLetterActionId = function (letterActionName) {
            var letterActionId = -1;
            switch (letterActionName) {
                case 'confirmation':
                    letterActionId = 1;
                    break;
                case 'interpreter':
                    letterActionId = 2;
                    break;
                case 'instalments':
                    letterActionId = 3;
                    break;
                case 'blank':
                    letterActionId = 4;
                    break;
                case 'cancellation':
                    letterActionId = 5;
                    break;
                default:
                    letterActionId = 0;
                    break;
            }
            return letterActionId;
        }

        $scope.upload = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Upload New Templates Document",
                closable: true,
                filePath: "/app/components/letters/upload.html",
                controllerName: "letterUploadCtrl",
                cssClass: "LetterUploadModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.download = function (letterTemplateDocumentId) {
            if (letterTemplateDocumentId > 0) {
                return LetterService.downloadTemplate(activeUserProfile.UserId, letterTemplateDocumentId);
                //window.open(apiServer + '/letters/downloadTemplate/' + id + '/' + activeUserProfile.UserId, '_blank', '');
            }
        }

        $scope.clearLetterFields();
        $scope.getOrganisations(activeUserProfile.UserId);
        $scope.getLetterTemplateCategoriesByOrganisation($scope.selectedOrganisationId);

    }
})();