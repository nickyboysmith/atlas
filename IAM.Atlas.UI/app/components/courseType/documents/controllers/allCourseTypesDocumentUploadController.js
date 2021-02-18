(function () {
    'use strict';

    angular
        .module('app')
        .controller('allCourseTypesDocumentUploadCtrl', allCourseTypesDocumentUploadCtrl);

    allCourseTypesDocumentUploadCtrl.$inject = ["$scope", "$timeout", "CourseTypeDocumentService", "UserService", "ModalService", "OrganisationService", "activeUserProfile"];

    function allCourseTypesDocumentUploadCtrl($scope, $timeout, CourseTypeDocumentService, UserService, ModalService, OrganisationService, activeUserProfile) {

        $scope.theLabel = "Organisation";
        $scope.theLabelValue = "";
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
            formData.append("courseTypeId", document.courseTypeId);
            return formData;
        };

        /**
         * 
         */
        $scope.saveFile = function (document) {
            document.courseTypeId = $scope.$parent.selectedCourseTypeId;
            CourseTypeDocumentService.uploadAllCourseTypesDocument($scope.covertFormData(document))
            .then(
                function successCallback(response)
                {
                    $scope.$parent.getDocuments($scope.$parent.selectedCourseTypeId)
                        .then(
                            function successCallback(response) {
                                $scope.successMesssage = 'Document added successfully.';
                                ModalService.closeCurrentModal("uploadNewAllCourseTypeDocumentModal");
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

        OrganisationService.Get($scope.selectedOrganisationId)
            .then(
                function successCallback(response) {
                    if (response.data) {
                        $scope.theLabelValue = response.data.Name;
                    }
                },
                function errorCallback(response) { }
            );
    }
})();