(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('EmailAllTrainersCtrl', EmailAllTrainersCtrl);

    EmailAllTrainersCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'DateFactory', 'activeUserProfile', 'EmailAllService', 'ModalService'];

    function EmailAllTrainersCtrl($scope, $location, $window, $http, $filter, DateFactory, activeUserProfile, EmailAllService, ModalService) {

        $scope.emailAllService = EmailAllService;
       
        $scope.trainerEmail = {
            AttachmentIds: []
        };

        $scope.trainersWithoutEmails = {};

        $scope.trainerEmail.RequestedByUserId = activeUserProfile.UserId;

        $scope.trainerEmail.SendAllTrainers = true;
        $scope.trainerEmail.SendAllClients = false;

        $scope.trainerEmail.SeparateEmails = true;
        $scope.trainerEmail.OneEmailWithHiddenAddresses = false;

        $scope.trainerEmail.StartDearNamed = true;
        $scope.trainerEmail.StartDearSirMadam = false;
        $scope.trainerEmail.StartToWhomItMayConcern = false;

        $scope.trainerEmail.SendASAP = true;
        $scope.trainerEmail.SendAfter = false;

        $scope.trainerEmail.CourseId = $scope.$parent.courseId;

        $scope.trainerEmail.SendAfterDate = $filter('date')(new Date(), 'dd MMM yyyy');
        $scope.trainerEmail.SendAfterDate = $filter('uppercase')($scope.trainerEmail.SendAfterDate);

        $scope.trainerEmail.SendAfterTime = $filter('date')(new Date(), 'hh:mm');

        $scope.emailTypeForAttachmentUpdate = "Trainer";

        $scope.toggleEmailChoice = function (emailChoice) {

            if (emailChoice == 'Separate') {
                $scope.trainerEmail.OneEmailWithHiddenAddresses = !$scope.trainerEmail.OneEmailWithHiddenAddresses;
            }
            else if (emailChoice == 'One') {
                $scope.trainerEmail.SeparateEmails = !$scope.trainerEmail.SeparateEmails;
            }
        }

        $scope.toggleEmailStart = function (emailStart) {

            if (emailStart == 'Named') {
                if ($scope.trainerEmail.StartDearNamed == true) {
                    $scope.trainerEmail.StartDearSirMadam = false;
                    $scope.trainerEmail.StartToWhomItMayConcern = false;
                }
                else {
                    $scope.trainerEmail.StartDearSirMadam = true;
                    $scope.trainerEmail.StartToWhomItMayConcern = false;
                }
            }
            else if (emailStart == 'SirMadam') {

                if ($scope.trainerEmail.StartDearSirMadam == true) {
                    $scope.trainerEmail.StartDearNamed = false;
                    $scope.trainerEmail.StartToWhomItMayConcern = false;
                }
                else {
                    $scope.trainerEmail.StartDearNamed = false;
                    $scope.trainerEmail.StartToWhomItMayConcern = true;
                }
            }
            else if (emailStart == 'ToWhomItMayConcern') {

                if ($scope.trainerEmail.StartToWhomItMayConcern == true) {
                    $scope.trainerEmail.StartDearSirMadam = false;
                    $scope.trainerEmail.StartDearNamed = false;
                }
                else {
                    $scope.trainerEmail.StartDearSirMadam = false;
                    $scope.trainerEmail.StartDearNamed = true;
                }
            }
        }

        $scope.toggleEmailSend = function (emailSend) {

            if (emailSend == 'SendASAP') {
                $scope.trainerEmail.SendAfter = !$scope.trainerEmail.SendAfter;
            }
            else if (emailSend == 'SendAfter') {
                $scope.trainerEmail.SendASAP = !$scope.trainerEmail.SendASAP;
            }
        }
        $scope.isValidEmail = function (emailaddess) {

            //ref
            //http://stackoverflow.com/questions/46155/validate-email-address-in-javascript

            var emailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

            var validEmail = emailFormat.test(emailaddess);

            return validEmail;
        }

        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }

        $scope.AttachDocument = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Attach Course Document",
                cssClass: "courseDocumentModal",
                filePath: "/app/components/course/attachCourseEmailAttachment.html",
                controllerName: "attachCourseEmailAttachmentCtrl"
            });
        }

        //Save all emails
        $scope.send = function () {

            if ($scope.trainerEmail.SendASAP == true) {
                $scope.trainerEmail.SendAfterDateTime = null;
            }
            else {
                var x = document.getElementById("trainerEmailSendAfterTime").value;

                var myTime;

                // Take last 2 characters - am or pm
                var suffix = x.slice(-2);
                if (suffix == "pm")
                {
                    // Find the first character ':' in the time string 
                    var pos = x.indexOf(':');
                    // take everything to the left, this is the hour
                    var hour = Number(x.slice(0, pos));
                    // take 2 chararacters to the right to give the minutes
                    var minutes = x.slice(pos + 1, pos + 3);
                    // add 12 to convert to 24 hours
                    hour = hour + 12;
                    myTime = hour + ":" + minutes;
                }
                else {
                    myTime = x.slice(0, x.length - 3);
                }
                
                var seconds = ":00";
                // add seconds
                myTime = myTime + seconds;

                var newDate = $scope.trainerEmail.SendAfterDate + " " + myTime;
                $scope.trainerEmail.SendAfterDateTime = $filter('date')(newDate, 'dd/mm/yyyy hh:mm:ss');
            }

            if ($scope.validateForm()) {

                $scope.emailAllService.RecordEmails($scope.trainerEmail)
                    .then(
                        function (response) {
                            console.log("Success");
                            console.log(response.data);
                            $scope.successMessage = "Email successfully added to the email queue.";
                            $scope.validationMessage = "";
                        },
                        function (response) {
                            console.log("Error");
                            console.log(response);
                            $scope.successMessage = "";
                            $scope.validationMessage = "An error occurred please try again.";
                        }
                    );
            }

        }

        $scope.timeChanged = function () {

        }


        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (angular.isDefined($scope.trainerEmail.CCEmailAddresses)) {
                if ($scope.trainerEmail.CCEmailAddresses.length > 0) {
                    if (!$scope.isValidEmail($scope.trainerEmail.CCEmailAddresses)) {
                        $scope.validationMessage = "Invalid Copy Email Address";
                    }
                }
            }

            if (angular.isDefined($scope.trainerEmail.BCCEmailAddresses)) {
                if ($scope.trainerEmail.BCCEmailAddresses.length > 0) {
                    if (!$scope.isValidEmail($scope.trainerEmail.BCCEmailAddresses)) {
                        $scope.validationMessage = "Invalid Blind Copy Address";
                    }
                }
            }
            if (angular.isDefined($scope.trainerEmail.Subject)) {
                if ($scope.trainerEmail.Subject.length < 4) {
                    $scope.validationMessage = "The Email Subject must be at least 4 characters in length";
                }
            }
            else {
                $scope.validationMessage = "Please enter the Subject description of the Email";
            }

            if (angular.isDefined($scope.trainerEmail.Content)) {
                if ($scope.trainerEmail.Content.length == 0) {
                    $scope.validationMessage = "Please enter some Email Content";
                }
            }
            else {
                $scope.validationMessage = "Please enter some Email Content";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.openTrainersWithoutEmailsModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Trainers Without Emails",
                cssClass: "trainersWithoutEmailsModal",
                filePath: "/app/components/course/trainersWithoutEmails.html",
                controllerName: "TrainersWithoutEmailsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                        }
                }
            });
        }

        EmailAllService.TrainersWithoutEmails($scope.trainerEmail.CourseId)
            .then(
                function successCallback(response) {
                    $scope.trainersWithoutEmails = response.data;
                },
                function errorCallback(response) {
                    $scope.validationMessage = "Unable to determine if there are Trainers without emails.";
                }
            );

    }
})();

