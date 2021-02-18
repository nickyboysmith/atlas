(function () {
    'use strict';

    angular
        .module('app')
        .controller('editOrganisationDocumentCtrl', editOrganisationDocumentCtrl);

    editOrganisationDocumentCtrl.$inject = ["$scope", "$timeout", "DocumentService", "UserService", "activeUserProfile"];

    function editOrganisationDocumentCtrl($scope, $timeout, DocumentService, UserService, activeUserProfile) {

        $scope.document = {};

        $scope.saveDocument = function () {
            if ($scope.document) {
                DocumentService.updateTitleDescription($scope.document.Id, $scope.document.Title, $scope.document.Description, activeUserProfile.UserId)
                    .then(
                        function (data) {
                            if (data == true) {
                                $scope.$parent.refreshDocuments();
                                $scope.successMessage = "Document saved.";
                            }
                            else {
                                $scope.errorMessage = "An error occured, document may not have been saved.";
                            }
                        },
                        function (data) {
                            $scope.errorMessage = "An error occured, document may not have been saved.";
                        }
                    );
            }
        }

        $scope.loadDocument = function () {
            if ($scope.selectedDocumentId) {
                DocumentService.Get($scope.selectedDocumentId, activeUserProfile.UserId)
                    .then(
                        function (data) {
                            if (data) {
                                $scope.document = data;
                                if ($scope.document.Description == "undefined") {
                                    $scope.document.Description = "";
                                }
                            }
                        },
                        function (data) { }
                    );
            }
        }

        $scope.loadDocument();
    }
})();