(function () {

    'use strict';

    angular
        .module("app")
        .controller("SendEmailCtrl", SendEmailCtrl);

    SendEmailCtrl.$inject = ["$scope", "SendEmailService", "ModalService", "activeUserProfile"];

    function SendEmailCtrl($scope, SendEmailService, ModalService, activeUserProfile) {

        /**
         * Instantiate the email object
         */
        $scope.email = {
            clientId: 0,
            name: "",
            address: "",
            recipientType: "Client",
            content: "",
            subject: ""
        };

        $scope.selectedEmailTemplate = {};
        $scope.defaultEmailTemplatePresent = false;

        //Now called elsewhere, parent object has 'DocumentTitle', so 
        // ensuring Title is set for later on.
        if ($scope.$parent.allSelectedDocuments[0].DocumentTitle) {
            for (var i = 0; i < $scope.$parent.allSelectedDocuments.length; i++) {
                $scope.$parent.allSelectedDocuments[i].Title = $scope.$parent.allSelectedDocuments[i].DocumentTitle;
            }
        }

        if ($scope.$parent.allSelectedDocuments) {
            $scope.textAreaRows = $scope.$parent.allSelectedDocuments.length + 1;
        }
        else {
            $scope.textAreaRows = 2;
        }

        if ($scope.sendEmailFromClientsMenu) {
            $scope.email.address = $scope.sendEmailFromClientsMenu.clientEmailAddress;
            $scope.email.clientId = $scope.sendEmailFromClientsMenu.clientId;
            $scope.email.name = $scope.sendEmailFromClientsMenu.clientName;
            $scope.sendEmailFromClientsMenu = undefined;
        }
        else {
            /**
             * Check if parents exist
             */
            if ($scope.$parent.clientEmailAddress) {
                $scope.email.address = $scope.$parent.clientEmailAddress;
            }

            /**
             * 
             */
            if ($scope.$parent.clientEmailId) {
                $scope.email.clientId = $scope.$parent.clientEmailId;
            }

            /**
             * 
             */
            if ($scope.$parent.clientEmailName) {
                $scope.email.name = $scope.$parent.clientEmailName;
            }

            /**
             * 
             */
            if ($scope.$parent.recipientType) {
                $scope.email.recipientType = $scope.$parent.recipientType;
            }

            /**
             * 
             */
            if ($scope.$parent.emailContent) {
                $scope.email.content = $scope.$parent.emailContent;
            }

            /**
             * 
             */
            if ($scope.$parent.allSelectedDocuments) {
                if ($scope.$parent.allSelectedDocuments.length == 1) {
                    //if ($scope.$parent.allSelectedDocuments[0].Title) {
                        $scope.email.subject = $scope.$parent.allSelectedDocuments[0].Title;
                    //}
                    //else {
                    //    $scope.email.subject = $scope.$parent.allSelectedDocuments[0].DocumentTitle;
                    //}

                }
                else {
                    $scope.email.subject = "Your documents from Atlas system";
                }
            }
            else if ($scope.documentForAttachment) {
                $scope.email.subject = $scope.$parent.documentForAttachment.Title;
            }
            else if ($scope.$parent.documents) {
                $scope.email.subject = $scope.$parent.documents[0].Title;
            }
            else if ($scope.$parent.emailSubject) {
                $scope.email.subject = $scope.$parent.emailSubject;
            }


            /**
            * 
            */

            if ($scope.$parent.allSelectedDocuments) {
                if ($scope.$parent.allSelectedDocuments.length <= 9) {
                    var documentId = 2;
                    for (var i = 0; i < $scope.$parent.allSelectedDocuments.length; i++) {
                        if (i == 0) {
                            $scope.email['documentId'] = $scope.$parent.allSelectedDocuments[i].Id;
                        } else {
                            $scope.email['documentId' + documentId] = $scope.$parent.allSelectedDocuments[i].Id;
                            documentId++;
                        }

                    }
                }
            }
            else if ($scope.documentForAttachment) {
                $scope.email.documentId = $scope.$parent.documentForAttachment.DocumentId;
            }
            else if ($scope.$parent.documents) {
                $scope.email.documentId = $scope.$parent.documents[0].Id;
            }


            /**
             * 
             */
            if ($scope.$parent.allSelectedDocuments) {
                var title = "";

                for (var i = 0; i < $scope.$parent.allSelectedDocuments.length; i++) {
                    if (i < $scope.$parent.allSelectedDocuments.length - 1) {
                        title = title + $scope.$parent.allSelectedDocuments[i].Title + '\r';
                    }
                    else {
                        title = title + $scope.$parent.allSelectedDocuments[i].Title;
                    }
                }
                $scope.email.attachmentTitle = title;
            }
            else if ($scope.documentForAttachment) {
                $scope.email.attachmentTitle = $scope.$parent.documentForAttachment.Title;
            }
            else if ($scope.$parent.documents) {
                $scope.email.attachmentTitle = $scope.$parent.documents[0].Title;
            }
            else {
                $scope.email.attachmentTitle = "";
            }

        }

        /**
         * Call the web service to schedule the email
         */
        $scope.sendTheEmail = function () {

            $scope.email.errorMessage = "";

            angular.extend($scope.email, {
                "organisationId": activeUserProfile.selectedOrganisation.Id,
                "userId": activeUserProfile.UserId,
            });


            SendEmailService.send($scope.email)
            .then(
                function (response) {
                    ModalService.closeCurrentModal("sendClientEmailModal");
                },
                function (reason) {
                    $scope.email.errorMessage = reason.data;
                }
            );

        };

        /**
         * Call the web service to schedule the email
         */
        $scope.previewTheEmail = function () {

            $scope.email.errorMessage = "";

            ModalService.displayModal({
                scope: $scope,
                title: "Preview Client Email",
                closable: true,
                filePath: "/app/components/email/preview.html",
                controllerName: "PreviewEmailCtrl",
                cssClass: "PreviewEmailModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
            //angular.extend($scope.email, {
            //    "organisationId": activeUserProfile.selectedOrganisation.Id,
            //    "userId": activeUserProfile.UserId,
            //});


            //SendEmailService.send($scope.email)
            //.then(
            //    function (response) {
            //        ModalService.closeCurrentModal("sendClientEmailModal");
            //    },
            //    function (reason) {
            //        $scope.email.errorMessage = reason.data;
            //    }
            //);

        };


        $scope.getEmailTemplates = function () {
            SendEmailService.getClientEmailTemplates(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function (response) {
                        $scope.emailTemplates = response.data;
                        if ($scope.emailTemplates[0].DefaultSelectedEmailTemplate == true) {
                            $scope.defaultEmailTemplatePresent = true;
                            $scope.selectedEmailTemplate = $scope.emailTemplates[0];
                            $scope.email.content = $scope.emailTemplates[0].Content;
                        }
                    },
                    function (response) {
                        $scope.email.errorMessage = "Unable to retrieve email templates";
                    });
        };

        $scope.changeEmailContent = function (selectedEmailTemplate) {
            if (selectedEmailTemplate != undefined && selectedEmailTemplate != null) {
                $scope.email.content = selectedEmailTemplate.Content;
                $scope.email.letterTemplateId = selectedEmailTemplate.Id;
                if (selectedEmailTemplate.EmailSubject && selectedEmailTemplate.EmailSubject.length > 0 && selectedEmailTemplate.EmailSubject != '') {
                    $scope.email.subject = selectedEmailTemplate.EmailSubject;
                }
            }
            else {
                $scope.email.content = "";
                $scope.email.letterTemplateId = null;
            }
        }


        $scope.getEmailTemplates();

    }

})();