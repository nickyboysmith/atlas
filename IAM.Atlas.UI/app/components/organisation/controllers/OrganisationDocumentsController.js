(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('OrganisationDocumentsCtrl', OrganisationDocumentsCtrl);

    OrganisationDocumentsCtrl.$inject = ["$scope", "$window", "$filter", "activeUserProfile", "UserService", "DocumentService", "ModalService", "DocumentDownloadService"];

    function OrganisationDocumentsCtrl($scope, $window, $filter, activeUserProfile, UserService, DocumentService, ModalService, DocumentDownloadService) {

        $scope.selectedOrganisationId = {};
        $scope.selectedDocumentId = 0;
        $scope.userService = UserService;
        $scope.documents = {};
        $scope.displayDocuments = {};
        $scope.documentTypes = {};
        $scope.totalFileSize = "0 Mb";
        $scope.showDeletedDocuments = false;
        $scope.documentHoverId = 0;
        $scope.hoverMessageMargin = 0;
        $scope.hoverMessageHeight = 0;
        $scope.hoverMessageWidth = 0;
        $scope.showDeletedMsg = false;
        $scope.showMarkedForDeletionMsg = false;
                        
        //Get Organisations function
        $scope.getOrganisations = function (userId) {
            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                $scope.selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
                $scope.userService.checkSystemAdminUser(userId)
                    .then(function (data) {
                        $scope.isAdmin = data;
                        $scope.getDocumentTypes();
                    });
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getSelectedOrganisationId = function () {
            var selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
            return selectedOrganisationId;
        }

        $scope.getDocumentTypes = function () {
            DocumentService.GetDocumentTypes()
                .then(
                    function (data) {
                        $scope.documentTypes = data;
                        $scope.getDocuments($scope.selectedDocumentType, $scope.showDeletedDocuments, activeUserProfile.selectedOrganisation.Id, $scope.documentCategory);
                    },
                    function (data) { }
                );
        }

        $scope.getTotalFileSize = function(documents)
        {
            var fileSize = 0;
            var unit = " Mb";
            if (documents) {
                for (var i = 0; i < documents.length; i++)
                {
                    if (documents[i].FileSize && !documents[i].Deleted) {
                        fileSize += documents[i].FileSize;
                    }
                }
                // convert to Mb
                fileSize = fileSize / 1000;
            }
            if (fileSize > 1000) {
                // convert to Gb
                fileSize = (fileSize / 1000).toFixed(2);
                unit = " Gb";
            }
            $scope.totalFileSize = fileSize + unit;
        }

        $scope.getFileSize = function (fileSize) {
            var unit = " Kb";
            // convert to Mb
            fileSize = (fileSize / 1000).toFixed(2);

            if (fileSize > 10000) {
                // convert to Mb
                fileSize = (fileSize / 1000).toFixed(2);
                unit = " Mb";
            }

            fileSize = fileSize + unit;
            return fileSize;
        }

        $scope.getDocuments = function (documentType, showDeletedDocuments, organisationId, category) {
            $scope.showDeletedDocuments = showDeletedDocuments;
            if ($scope.selectedOrganisationId && documentType) {
                $scope.selectedDocumentType = documentType;
                $scope.selectedOrganisationId = "" + organisationId;
                DocumentService.GetOrganisationDocuments($scope.selectedOrganisationId, $scope.selectedDocumentType, $scope.showDeletedDocuments, category)
                    .then(
                        function (data) {
                            $scope.documents = data;
                            $scope.displayDocuments = $scope.documents;
                            $scope.getTotalFileSize($scope.documents);
                        },
                        function (data) {
                            $scope.errorMessage = "An error occurred whilst retrieving documents: " + data.Message;
                        }
                    );
            }
        }

        $scope.refreshDocuments = function () {
            $scope.getDocuments($scope.selectedDocumentType, $scope.showDeletedDocuments, activeUserProfile.selectedOrganisation.Id, $scope.documentCategory);
        }

        // initalise the drop down
        $scope.getSelectedDocumentType = function () {
            $scope.selectedDocumentType = "All";
        }
        // initalise the drop down
        $scope.getDefaultCategory = function () {
            $scope.documentCategory = "All";
        }

        $scope.getCategory = function (document) {
            var category = "";
            var oneBefore = false;
            if(document.TrainerCategory){
                category = "Trainer"
                oneBefore = true;
            }
            if(document.ClientCategory){
                if (oneBefore) {
                    category += ", ";
                }
                category += "Client"
                oneBefore = true;
            }
            if (document.CourseCategory) {
                if (oneBefore) {
                    category += ", ";
                }
                category += "Course"
            }
            return category;
        }

        $scope.documentHover = function (document) {
            $scope.documentHoverId = document.Id;
            $scope.showDeletedMsg = document.Deleted;
            if ($scope.showDeletedMsg == true) {
                $scope.showMarkedForDeletionMsg = false;
            }
            else {
                $scope.showMarkedForDeletionMsg = document.MarkedForDeletion;
            }

            var hoverRow = $("#organisationDocument" + document.Id)
            var position = hoverRow.position();

            var deletedMsg = angular.element("#hoverDeletedMsg");
            var markedForDeletionMsg = angular.element("#hoverMarkedForDeletionMsg");

            deletedMsg.css('height', hoverRow.height() + "px");
            deletedMsg.css('width', hoverRow.width() + "px");
            deletedMsg.css('top', position.top + "px");

            markedForDeletionMsg.css('height', hoverRow.height() + "px");
            markedForDeletionMsg.css('width', hoverRow.width() + "px");
            markedForDeletionMsg.css('top', position.top + "px");

            //deletedMsg.style.height = hoverRow.height() + "px";
            //deletedMsg.style.width = hoverRow.width() + "px";
            //deletedMsg.style.margin = position.top + "px";

            

            //markedForDeletionMsg.style.height = hoverRow.height() + "px";
            //markedForDeletionMsg.style.width = hoverRow.width() + "px";
            //markedForDeletionMsg.style.margin = position.top + "px";

            //$scope.hoverMessageMargin = position.top + "px";
            //$scope.hoverMessageWidth = hoverRow.width() + "px";
            //$scope.hoverMessageHeight = hoverRow.height() + "px";
        }

        $scope.selectDocument = function (documentId) {
            $scope.selectedDocumentId = documentId;
        }

        $scope.editDocument = function (documentId) {
            $scope.selectedDocumentId = documentId;
            ModalService.displayModal({
                scope: $scope,
                title: "Document Details",
                cssClass: "editOrganisationDocumentModal",
                filePath: "/app/components/organisation/editOrganisationDocument.html",
                controllerName: "editOrganisationDocumentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.deleteDocument = function (documentId) {
            DocumentService.Delete(documentId, activeUserProfile.UserId)
                            .then(
                                function (data) {
                                    if (data == true) {
                                        $scope.refreshDocuments();
                                        $scope.statusMessage = "Document marked for deletion.";
                                    }
                                    else {
                                        $scope.errorMessage = "Document couldn't be deleted.";
                                    }
                                },
                                function (data) {
                                    $scope.errorMessage = "An error occurred: " + data.Message;
                                }
                            );
        }

        $scope.downloadDocument = function (documentId) {
            var documentToDownload = $filter("filter")($scope.documents, { Id: documentId })[0];
            if (documentToDownload) {
                DocumentDownloadService.downloadDocument(documentId,
                    activeUserProfile.UserId,
                    activeUserProfile.selectedOrganisation.Id,
                    activeUserProfile.selectedOrganisation.Id,
                    "organisation",
                    documentToDownload.Title,
                    documentToDownload.Type);
            }
        }




        $scope.uploadLetterTemplate = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Letter Template Maintenance",
                cssClass: "letterTemplatesModal",
                filePath: "/app/components/letters/templates.html",
                controllerName: "letterTemplatesCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.uploadAllTrainers = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Documents for All Trainers",
                cssClass: "allTrainerDocumentsModal",
                filePath: "/app/components/trainer/documents/allTrainers.html",
                controllerName: "allTrainersDocumentsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.uploadAllCourses = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Documents for All Courses",
                cssClass: "allCourseDocumentsModal",
                filePath: "/app/components/course/documents/allCourses.html",
                controllerName: "allCoursesDocumentsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.uploadAllCourseTypes = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Documents for All Course Types",
                cssClass: "allCourseTypeDocumentsModal",
                filePath: "/app/components/coursetype/documents/allCourseTypes.html",
                controllerName: "allCourseTypesDocumentsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }




        $scope.getOrganisations(activeUserProfile.UserId);
    }


})();