(function () {
    'use strict';

    angular
        .module('app')
        .controller('allCoursesDocumentsCtrl', allCoursesDocumentsCtrl);

    allCoursesDocumentsCtrl.$inject = ["$scope", "$timeout", "CourseDocumentService", "UserService", "ModalService", "activeUserProfile"];

    function allCoursesDocumentsCtrl($scope, $timeout, CourseDocumentService, UserService, ModalService, activeUserProfile) {

        $scope.documents = {};
        $scope.displayDocuments = {};
        $scope.selectedOrganisationId = {};
        $scope.userService = UserService;
        $scope.selectedDocumentId = -1;

        $scope.getDocuments = function (organisationId) {
            return CourseDocumentService.getAllCourseDocumentsByOrganisation(organisationId)
                .then(
                    function successCallback(response) {
                        $scope.documents = response.data;
                        $scope.displayDocuments = $scope.documents;
                    },
                    function errorCallback(response) {
                    
                    }
                );
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {
            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                $scope.selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
                $scope.userService.checkSystemAdminUser(userId)
                    .then(function (data) {
                        $scope.isAdmin = data;
                        $scope.getDocuments($scope.selectedOrganisationId);
                    });
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getSelectedOrganisationId = function () {
            var selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
            return selectedOrganisationId;
        }

        $scope.addNew = function () {
            
            ModalService.displayModal({
                scope: $scope,
                title: "Upload New All Course Document",
                cssClass: "uploadNewAllCourseDocumentModal",
                filePath: "/app/components/course/documents/allCoursesDocumentUpload.html",
                controllerName: "allCoursesDocumentUploadCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.editDetails = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Document Details",
                cssClass: "editAllCourseDocumentModal",
                filePath: "/app/components/course/documents/editAllCoursesDocument.html",
                controllerName: "editAllCoursesDocumentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.addExistingDocument = function () {

            $scope.selectedExistingDocumentOrganisationId = $scope.selectedOrganisationId;

            ModalService.displayModal({
                scope: $scope,
                title: "Add Existing Document for all Courses Administration",
                cssClass: "addExistingAllCoursesDocumentModal",
                filePath: "/app/components/course/documents/allCoursesDocumentsAddExisting.html",
                controllerName: "allCoursesDocumentsAddExistingCtrl"
            });
        }

        $scope.removeDocument = function() {
            if ($scope.selectedDocumentId > 0) {
                CourseDocumentService.removeAllCoursesDocument($scope.selectedDocumentId)
                    .then(
                        function successCallback(response) {
                            if (response.data == false) {
                                $scope.errorMessage = 'An error occurred.';
                            }
                            $scope.getDocuments($scope.selectedOrganisationId);
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = 'An error occurred: ' + response.data.Message;
                        });
            }
        }

        $scope.deleteDocument = function() { 
            if ($scope.selectedDocumentId > 0) {
                CourseDocumentService.deleteAllCoursesDocument($scope.selectedDocumentId, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if(response.data == false) {
                                $scope.errorMessage = 'An error occurred.';
                            }
                            $scope.getDocuments($scope.selectedOrganisationId);
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = 'An error occurred: ' + response.data.Message
                        });
            }
        }

        $scope.selectDocument = function (documentId) {
            $scope.selectedDocumentId = documentId;
        }

        $scope.getOrganisations(activeUserProfile.UserId);
    }
})();