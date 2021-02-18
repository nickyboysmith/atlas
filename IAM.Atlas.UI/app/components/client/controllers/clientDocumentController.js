(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientDocumentCtrl", ClientDocumentCtrl);

    ClientDocumentCtrl.$inject = ["$scope", "$filter", "ClientService", "ModalService", "activeUserProfile", "OrganisationSystemConfigurationService"];

    function ClientDocumentCtrl($scope, $filter, ClientService, ModalService, activeUserProfile, OrganisationSystemConfigurationService) {

        $scope.documentOrigin = "client";

        $scope.documentValidationMessage = "";
        /**
         * 
         */
        $scope.documents;
        $scope.isReferringAuthority = activeUserProfile.IsReferringAuthority;
        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;

        $scope.documentForAttachment = {};
        $scope.selectedDocumentCount = 0;
        $scope.allDocumentAttachments = {};

        /**
         * 
         */
        $scope.currentToolTip;

        /**
         * Set the client ID variable
         */
        $scope.clientID;
        $scope.setClientID = function (theClientID) {
            $scope.clientID = theClientID;
            $scope.getTheDocuments(theClientID);
        };

        /**
         * Get all the releated docs for client and selected org
         */
        $scope.getTheDocuments = function (clientID) {
            ClientService.getDocuments(
                clientID,
                activeUserProfile.selectedOrganisation.Id
            )
            .then(
                function (response) {
                    $scope.documents = $filter('filter')(response.data, { MarkedForDeletion: false });;
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        /**
         * Check to see if there is a description
         * If not then default to title
         */
        $scope.showToolTip = function (document) {
            var tooltip = "";
            if (document.Description) {
                tooltip = document.Description;
            } else {
                tooltip = document.Title;
            }
            $scope.currentToolTip = tooltip;
        };

        $scope.selectDocument = function (document) {
            $scope.selectedDocument = document;
            $scope.documentForAttachment.DocumentId = document.Id;
            $scope.documentForAttachment.Title = document.Title;
            document.isSelected ? document.isSelected = false : document.isSelected = true;
            $scope.selectedDocumentCount = 0;
            for (var i = 0; i < $scope.documents.length; i++) {
                if ($scope.documents[i].isSelected) {
                $scope.selectedDocumentCount++
                }
            }
        };


        /**
         * 
         */
        OrganisationSystemConfigurationService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
        .then(
            function (response) {
                $scope.maximumAllowedFileSize = response.data.MaximumIndividualFileSize;
            },
            function (response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
            }
        );

        /**
         * Add a new document
         */
        $scope.openAddDocumentModal = function () {
            $scope.addDocumentClientName = $scope.$parent.$parent.client.DisplayName;
            $scope.addDocumentOrganisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.addDocumentMaxSize = $scope.maximumAllowedFileSize;

            ModalService.displayModal({

                scope: $scope,
                title: "Add Client Document",
                cssClass: "addClientDocumentModal",
                filePath: "/app/components/client/addClientDocument.html",
                controllerName: "AddClientDocumentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };

        // Show email modal
        $scope.showEmailClientModal = function () {
            if ($scope.client.Emails.length === 0) {
                return false;
            }
            $scope.allSelectedDocuments = $filter('filter')($scope.documents, { isSelected: true });;
            $scope.clientEmailAddress = $scope.client.Emails[0].Address;
            $scope.clientEmailName = $scope.client.DisplayName;
            $scope.clientEmailId = $scope.client.Id;

            ModalService.displayModal({
                scope: $scope,
                title: "Send Client Email",
                cssClass: "sendClientEmailModal",
                filePath: "/app/components/email/view.html",
                controllerName: "SendEmailCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };

        /**
         * Download an existing document
         */
        $scope.openDownloadDocumentModal = function () {

            $scope.downloadDocumentObject = {};
            $scope.downloadDocumentObject.Id = $scope.selectedDocument.Id;
            $scope.downloadDocumentObject.typeLabel = "Client";        
            $scope.downloadDocumentObject.typeDescription = $scope.$parent.$parent.client.DisplayName + " (Id: " + $scope.$parent.$parent.client.Id + ")";
            $scope.downloadDocumentObject.typeName = $scope.selectedDocument.Type;
            $scope.downloadDocumentObject.documentSaveName = $scope.selectedDocument.Title;
            $scope.downloadDocumentObject.owningEntityId = $scope.$parent.$parent.client.Id;
            $scope.downloadDocumentObject.owningEntityPath = "client";

            ModalService.displayModal({

                scope: $scope,
                title: "Download Client Document",
                cssClass: "downloadDocumentModal",
                filePath: "/app/components/documents/download.html",
                controllerName: "DocumentDownloadCtrl"
            });

        };

        $scope.openDocumentTemplateModal = function () {

            $scope.createDocFromTemplateObject = {};
            $scope.createDocFromTemplateObject.typeLabel = "Client";
            $scope.createDocFromTemplateObject.clientNameId = $scope.$parent.$parent.client.DisplayName + " (Id: " + $scope.$parent.$parent.client.Id + ")";
            $scope.createDocFromTemplateObject.owningEntityId = $scope.$parent.$parent.client.Id;
            $scope.createDocFromTemplateObject.owningEntityPath = "client";

            ModalService.displayModal({

                scope: $scope,
                title: "Create Letter Document From Template",
                cssClass: "createDocFromLetterTemplateModal",
                filePath: "/app/components/letterTemplate/createDocFromLetterTemplate.html",
                controllerName: "CreateFromLetterTemplateCtrl"
            });

        };

        $scope.sendDocumentToPrintQueue = function () {
            $scope.documentValidationMessage = "";
            ClientService.sendDocToPrintQueue($scope.selectedDocument.Id, $scope.clientID, activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
                .then(function (response) {
                    if (response = true) {
                        $scope.documentValidationMessage = "Document added to the Print Queue";
                    }
                    else {
                        $scope.documentValidationMessage = "Unable to add document to the Print Queue";
                    }
                });
        }

        $scope.openDocInfoModal = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Document Information",
                cssClass: "documentInformationModal",
                filePath: "/app/components/documentInformation/manage.html",
                controllerName: "DocumentInformationCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        }
    }

})();