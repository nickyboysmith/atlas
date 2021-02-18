(function () {
    'use strict';

    angular
        .module('app')
        .controller('addTrainerDocumentCtrl', addTrainerDocumentCtrl);

    addTrainerDocumentCtrl.$inject = ["$scope", "$timeout", "TrainerDocumentService", "UserService", "ModalService", "activeUserProfile"];

    function addTrainerDocumentCtrl($scope, $timeout, TrainerDocumentService, UserService, ModalService, activeUserProfile) {

        $scope.theLabel = "Trainer";
        $scope.theLabelValue = $scope.$parent.trainer.DisplayName;
        $scope.theMaxSize = 1000;

        /**
         * Create form data to send to the web api
         * ?? Put  in a factory
         */
        $scope.covertFormData = function (document) {
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
            formData.append("TrainerId", $scope.trainerId);
            return formData;
        };

        /**
         * 
         */
        $scope.saveFile = function (document) {
            TrainerDocumentService.uploadTrainerDocument($scope.covertFormData(document))
            .then(
                function successCallback(response) {
                    $scope.$parent.getDocuments()
                        .then(
                            function successCallback(response) {
                                $scope.successMesssage = 'Document added successfully.';
                                ModalService.closeCurrentModal("addTrainerDocumentModal");
                            },
                            function errorCallback(response) {
                                $scope.errorMessage = reason.data.ExceptionMessage;
                            }
                        );
                },
                function errorCallback(reason) {
                    if (reason.data) {
                        $scope.errorMessage = reason.data.ExceptionMessage;
                    }
                }
            );
        };
    }
})();