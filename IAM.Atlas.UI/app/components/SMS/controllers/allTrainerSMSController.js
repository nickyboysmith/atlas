(function () {

    'use strict';

    angular
        .module("app")
        .controller("AllTrainerSMSCtrl", AllTrainerSMSCtrl);

    AllTrainerSMSCtrl.$inject = ["$scope", "$filter", "SMSService", "ModalService", "activeUserProfile"];

    function AllTrainerSMSCtrl($scope, $filter, SMSService, ModalService, activeUserProfile) {


        $scope.messageChunks = 0;

        /**
         * Instantiate the email object
         */
        $scope.SMS = {
            Content: "",
            OrganisationId: activeUserProfile.selectedOrganisation.Id,
            CourseId: $scope.$parent.courseId,
            RequestedByUserId: activeUserProfile.UserId,
            RecipientType: "Trainer"
        };

        $scope.SMSCounts = {
            Total: 0,
            WithPhoneNumber: 0
        };

        $scope.SMSData = {};

        $scope.calculateMessageChunk = function () {

            /* http://www.textanywhere.net/faq/is-there-a-maximum-sms-message-length */

            var maxLength = 918;
            var chunkSendingSize = 153;
            var lengthBeforeChunking = 160;
            var messageChunks = 0;

            if ($scope.SMS.Content.length > 0 && $scope.SMS.Content.length <= 160) {
                messageChunks = 1;
            }
            else if ($scope.SMS.Content.length > lengthBeforeChunking) {
                messageChunks = Math.ceil($scope.SMS.Content.length / chunkSendingSize);
            }

            $scope.messageChunks = messageChunks;
        }

        $scope.sendDisabled = function () {

            var wordMinCountForSend = 3;
            var messageMinLength = 10

            var wordCount = $scope.SMS.Content.split(' ').length;

            if (wordCount >= wordMinCountForSend && $scope.SMS.Content.length >= messageMinLength) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.GetAllTrainersOnCourse = function () {

            SMSService.GetAllTrainersOnCourse(activeUserProfile.selectedOrganisation.Id, $scope.$parent.courseId)
                .then(
                    function success(response) {

                        $scope.SMSData = response;

                        $scope.SMSCounts.Total = $scope.SMSData.length;

                        if ($scope.SMSData.length > 0) {

                            var WithoutPhoneNumber = $filter("filter")($scope.SMSData, {
                                PhoneNumer: null
                            }, true);

                            $scope.SMSCounts.WithPhoneNumber = $scope.SMSCounts.Total - WithoutPhoneNumber.length;
                        }

                    },
                    function failure(reason) {
                        console.log(reason);
                        $scope.errorMessage = reason.data.Message;
                    }
                );

        };

        $scope.sendSMS = function () {

            SMSService.SendAllTrainersOnCourse($scope.SMS)
                    .then(
                        function success(response) {
                            
                            $scope.statusMessage = 'SMS created successfully.';
                            $scope.errorMessage = '';
                        },
                        function failure(reason) {
                            console.log(reason);
                            $scope.errorMessage = reason.data.Message;
                        }
                    );

        };



        $scope.cancelSMS = function () {
            ModalService.closeCurrentModal("sendClientSMSModal");
        }

        $scope.GetAllTrainersOnCourse();

    }

})();