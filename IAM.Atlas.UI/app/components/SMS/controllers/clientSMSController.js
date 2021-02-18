(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientSMSCtrl", ClientSMSCtrl);

    ClientSMSCtrl.$inject = ["$scope", "SMSService", "ModalService", "activeUserProfile"];

    function ClientSMSCtrl($scope, SMSService, ModalService, activeUserProfile) {


        $scope.messageChunks = 0;

        /**
         * Instantiate the email object
         */
        $scope.SMS = {
            ClientId: 0,
            ClientName: "",
            PhoneNumber: "",
            Content: "",
            OrganisationId: activeUserProfile.selectedOrganisation.Id,
            RequestedByUserId: activeUserProfile.UserId,
            recipientType: "Client"
        };

        if ($scope.sendSMSFromClientsMenu) {
            $scope.SMS.ClientName = $scope.sendSMSFromClientsMenu.clientName;
            $scope.SMS.ClientId = $scope.sendSMSFromClientsMenu.clientId;
            $scope.SMS.PhoneNumber = $scope.sendSMSFromClientsMenu.clientPhoneNumber;
            $scope.sendSMSFromClientsMenu = undefined;
        }
        else {
            /**
             * Check if parents exist
             */
            if ($scope.$parent.client.DisplayName) {
                $scope.SMS.ClientName = $scope.$parent.client.DisplayName;
            }

            /**
             * 
             */
            if ($scope.$parent.clientId) {
                $scope.SMS.ClientId = $scope.$parent.clientId;
            }

            /**
             * 
             */
            if ($scope.$parent.SMSPhoneNumber) {
                $scope.SMS.PhoneNumber = $scope.$parent.SMSPhoneNumber;
            }

            /**
             * 
             */
            if ($scope.$parent.recipientType) {
                $scope.SMS.recipientType = $scope.$parent.recipientType;
            }

            /**
             * 
             */
            if ($scope.$parent.SMSContent) {
                $scope.SMS.Content = $scope.$parent.SMSContent;
            }

        }
        
        $scope.calculateMessageChunk = function () {

            /* http://www.textanywhere.net/faq/is-there-a-maximum-sms-message-length */

            var maxLength = 918;
            var chunkSendingSize = 153;
            var lengthBeforeChunking = 160;
            var messageChunks = 0;

            if ($scope.SMS.Content.length > 0 && $scope.SMS.Content.length <= 160)
            {
                messageChunks = 1;
            }
            else if ($scope.SMS.Content.length > lengthBeforeChunking)
            {
                messageChunks = Math.ceil($scope.SMS.Content.length / chunkSendingSize);
            }

            $scope.messageChunks = messageChunks;

        }

        $scope.sendDisabled = function () {

            var wordMinCountForSend = 3;
            var messageMinLength = 10

            var wordCount = $scope.SMS.Content.split(' ').length;

            if (wordCount >= wordMinCountForSend && $scope.SMS.Content.length >= messageMinLength ) {
                return false;
            }
            else {
                return true;
            }
        }

        /**
         * Call the web service to schedule the SMS
         */
        $scope.sendSMS = function () {
            //if ($scope.SMS.Content && $scope.SMS.Content.length >= 10 && $scope.SMS.Content.length <= 400)
            if ($scope.SMS.Content)
            {
                SMSService.Send($scope.SMS)
                            .then(
                                function success(response) {
                                    $scope.SMS.Sent = true;
                                    $scope.statusMessage = 'SMS created successfully.';
                                    $scope.errorMessage = '';
                                },
                                function failure(reason) {
                                    console.log(reason);
                                    $scope.errorMessage = reason.data.Message;
                                }
                            );
            }
            else
            {
                $scope.errorMessage = 'SMS must be between 10 and 400 characters.';
            }
        };

        $scope.cancelSMS = function () {
            ModalService.closeCurrentModal("sendClientSMSModal");
        }

    }



})();