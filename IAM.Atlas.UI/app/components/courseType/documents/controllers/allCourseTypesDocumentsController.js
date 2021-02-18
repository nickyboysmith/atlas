(function () {
    'use strict';

    angular
        .module('app')
        .controller('allCourseTypesDocumentsCtrl', allCourseTypesDocumentsCtrl);

    allCourseTypesDocumentsCtrl.$inject = ["$scope", "$filter", "$timeout", "CourseTypeDocumentService", "CourseTypeService", "UserService", "ModalService", "activeUserProfile"];

    function allCourseTypesDocumentsCtrl($scope, $filter, $timeout, CourseTypeDocumentService, CourseTypeService, UserService, ModalService, activeUserProfile) {

        $scope.documents = {};
        $scope.coursetypes = {};
        $scope.displayDocuments = {};
        $scope.selectedOrganisationId = {};
        $scope.userService = UserService;
        $scope.selectedDocumentId = -1;

        $scope.getCourseTypes = function (organisationId) {
            return CourseTypeService.getCourseTypes(organisationId)
                .then(
                    function (data) {
                        $scope.coursetypes = data;

                        if ($scope.coursetypes.length > 0) {
                            $scope.coursetypes = $filter('orderBy')($scope.coursetypes, 'Title');
                            $scope.selectedCourseTypeId = $scope.coursetypes[0].Id;
                            $scope.getDocuments($scope.selectedCourseTypeId)
                        }

                        $scope.displayDocuments = $scope.documents;

                    },
                    function (data) {

                    }
                );
        }

        $scope.getDocuments = function (courseTypeId) {
            return CourseTypeDocumentService.getAllCourseTypeDocumentsByCourseType(courseTypeId)
                .then(
                    function successCallback(response) {
                        $scope.documents = response.data;
                        $scope.displayDocuments = $scope.documents;
                        $scope.selectedCourseTypeId = courseTypeId;
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
                        $scope.getCourseTypes($scope.selectedOrganisationId);
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
                title: "Upload New All Course Type Document",
                cssClass: "uploadNewAllCourseTypeDocumentModal",
                filePath: "/app/components/courseType/documents/allCourseTypesDocumentUpload.html",
                controllerName: "allCourseTypesDocumentUploadCtrl",
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
                cssClass: "editAllCourseTypeDocumentModal",
                filePath: "/app/components/courseType/documents/editAllCourseTypesDocument.html",
                controllerName: "editAllCourseTypesDocumentCtrl",
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

            $scope.selectedExistingDocumentCourseTypeId = $scope.selectedCourseTypeId;

            ModalService.displayModal({
                scope: $scope,
                title: "Add Existing Document for all Course Types Administration",
                cssClass: "addExistingAllCourseTypesDocumentModal",
                filePath: "/app/components/courseType/documents/allCourseTypesDocumentsAddExisting.html",
                controllerName: "allCourseTypesDocumentsAddExistingCtrl"
            });
        }

        $scope.removeDocument = function() {
            if ($scope.selectedDocumentId > 0) {
                CourseTypeDocumentService.removeAllCourseTypesDocument($scope.selectedDocumentId)
                    .then(
                        function successCallback(response) {
                            if (response.data == false) {
                                $scope.errorMessage = 'An error occurred.';
                            }
                            $scope.getDocuments($scope.selectedCourseTypeId);
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = 'An error occurred: ' + response.data.Message;
                        });
            }
        }

        $scope.deleteDocument = function() { 
            if ($scope.selectedDocumentId > 0) {
                CourseTypeDocumentService.deleteAllCourseTypesDocument($scope.selectedDocumentId, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if(response.data == false) {
                                $scope.errorMessage = 'An error occurred.';
                            }
                            $scope.getDocuments($scope.selectedCourseTypeId);
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