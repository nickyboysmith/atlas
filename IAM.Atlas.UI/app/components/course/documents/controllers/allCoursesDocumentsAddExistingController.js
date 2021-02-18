(function () {
    'use strict';

    angular
        .module('app')
        .controller('allCoursesDocumentsAddExistingCtrl', allCoursesDocumentsAddExistingCtrl);

    allCoursesDocumentsAddExistingCtrl.$inject = ["$scope", "$timeout", "CourseDocumentService", "UserService", "ModalService", "activeUserProfile"];

    function allCoursesDocumentsAddExistingCtrl($scope, $timeout, CourseDocumentService, UserService, ModalService, activeUserProfile) {

        $scope.documents = {};
        $scope.displayDocuments = {};
        $scope.selectedOrganisationId = {};
        $scope.userService = UserService;
        $scope.selectedDocumentId = -1;

        $scope.getExistingDocuments = function (organisationId) {
            if(organisationId){
                return CourseDocumentService.getNonAllCourseDocumentsByOrganisation(organisationId)
                .then(
                    function successCallback(response) {
                        $scope.documents = response.data;
                        $scope.displayDocuments = $scope.documents;
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = "Error loading document list: " + response.data.Message;
                    }
                );
            }
        }

        $scope.selectDocument = function (documentId) {
            $scope.selectedExistingDocumentId = documentId;
            $scope.successMessage = "";
        }

        $scope.selectExistingDocument = function () {
            CourseDocumentService.AddExistingDocumentToAllCourses($scope.selectedExistingDocumentId, activeUserProfile.UserId, $scope.selectedExistingDocumentOrganisationId)
                .then(
                    function successCallback(response) {
                        if(response.data == false){
                            $scope.errorMessage = "An error occurred, document may not be added to All Courses.";
                        }
                        $scope.getExistingDocuments($scope.selectedExistingDocumentOrganisationId);
                        $scope.$parent.getDocuments($scope.selectedExistingDocumentOrganisationId);
                        $scope.successMessage = "Document added to all Courses successfully.";
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = "An error occurred: " + response.data.Message;
                    }
                );
        }

        $scope.getExistingDocuments($scope.selectedExistingDocumentOrganisationId);
    }
})();