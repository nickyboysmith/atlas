(function () {
    'use strict';

    angular
        .module('app')
        .controller('editAllCoursesDocumentCtrl', editAllCoursesDocumentCtrl);

    editAllCoursesDocumentCtrl.$inject = ["$scope", "$timeout", "CourseDocumentService", "UserService", "activeUserProfile"];

    function editAllCoursesDocumentCtrl($scope, $timeout, CourseDocumentService, UserService, activeUserProfile) {
        
        $scope.document = {};

        $scope.saveDocument = function () {
            if($scope.document){
                CourseDocumentService.updateTitleDescription($scope.document.Id, $scope.document.Title, $scope.document.Description, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if (response.data == true) {
                                $scope.$parent.getDocuments($scope.selectedOrganisationId);
                                $scope.successMessage = "Document saved.";
                            }
                            else {
                                $scope.errorMessage = "An error occured, document may not have been saved.";
                            }
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = "An error occured, document may not have been saved.";
                        }
                    );
            }
        }

        $scope.loadDocument = function () {
            if ($scope.selectedDocumentId) {
                CourseDocumentService.get($scope.selectedDocumentId, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if (response.data) {
                                $scope.document = response.data;
                            }
                        },
                        function errorCallback(response) { }
                    );
            }
        }

        $scope.loadDocument();
    }
})();