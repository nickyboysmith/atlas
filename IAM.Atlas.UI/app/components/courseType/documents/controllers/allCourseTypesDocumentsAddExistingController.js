(function () {
    'use strict';

    angular
        .module('app')
        .controller('allCourseTypesDocumentsAddExistingCtrl', allCourseTypesDocumentsAddExistingCtrl);

    allCourseTypesDocumentsAddExistingCtrl.$inject = ["$scope", "$timeout", "CourseTypeDocumentService", "UserService", "ModalService", "activeUserProfile"];

    function allCourseTypesDocumentsAddExistingCtrl($scope, $timeout, CourseTypeDocumentService, UserService, ModalService, activeUserProfile) {

        $scope.documents = {};
        $scope.displayDocuments = {};
        $scope.selectedCourseTypeId = {};
        $scope.userService = UserService;
        $scope.selectedDocumentId = -1;

        $scope.getExistingDocuments = function (courseTypeId) {
            if (courseTypeId) {
                return CourseTypeDocumentService.getNonAllCourseTypeDocumentsByCourseType(courseTypeId)
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
            CourseTypeDocumentService.AddExistingDocumentToAllCourseTypes($scope.selectedExistingDocumentId, activeUserProfile.UserId, $scope.selectedExistingDocumentCourseTypeId)
                .then(
                    function successCallback(response) {
                        if(response.data == false){
                            $scope.errorMessage = "An error occurred, document may not be added to All CourseTypes.";
                        }
                        $scope.getExistingDocuments($scope.selectedExistingDocumentCourseTypeId);
                        $scope.$parent.getDocuments($scope.selectedExistingDocumentCourseTypeId);
                        $scope.successMessage = "Document added to all CourseTypes successfully.";
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = "An error occurred: " + response.data.Message;
                    }
                );
        }

        $scope.getExistingDocuments($scope.selectedExistingDocumentCourseTypeId);
    }
})();