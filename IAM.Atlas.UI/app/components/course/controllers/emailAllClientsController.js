(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('EmailAllClientsCtrl', EmailAllClientsCtrl);

    EmailAllClientsCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'DateFactory', 'activeUserProfile', 'EmailAllService', 'ModalService'];

    function EmailAllClientsCtrl($scope, $location, $window, $http, $filter, DateFactory, activeUserProfile, EmailAllService, ModalService) {

        $scope.emailAllService = EmailAllService;

        $scope.clientEmail = {
            AttachmentIds: []
        };

        $scope.clientsWithoutEmails = {};

        $scope.clientEmail.RequestedByUserId = activeUserProfile.UserId;

        $scope.clientEmail.SendAllTrainers = false;
        $scope.clientEmail.SendAllClients = true;

        $scope.clientEmail.SeparateEmails = true;
        $scope.clientEmail.OneEmailWithHiddenAddresses = false;

        $scope.clientEmail.StartDearNamed = true;
        $scope.clientEmail.StartDearSirMadam = false;
        $scope.clientEmail.StartToWhomItMayConcern = false;

        $scope.clientEmail.SendASAP = true;
        $scope.clientEmail.SendAfter = false;

        $scope.clientEmail.CourseId = $scope.$parent.courseId;
        
        $scope.clientEmail.SendAfterDate = $filter('date')(new Date(), 'dd MMM yyyy');
        $scope.clientEmail.SendAfterDate = $filter('uppercase')($scope.clientEmail.SendAfterDate);

        $scope.clientEmail.SendAfterTime = $filter('date')(new Date(), 'hh:mm');

        $scope.emailTypeForAttachmentUpdate = "Client";

        $scope.toggleEmailChoice = function (emailChoice) {
           
            if (emailChoice == 'Separate') {
                $scope.clientEmail.OneEmailWithHiddenAddresses = !$scope.clientEmail.OneEmailWithHiddenAddresses;
            }
            else if (emailChoice == 'One') {
                $scope.clientEmail.SeparateEmails = !$scope.clientEmail.SeparateEmails;

                if ($scope.clientEmail.OneEmailWithHiddenAddresses == true) {
                    $scope.clientEmail.StartDearNamed = false;
                }

            }
        }

        $scope.toggleEmailStart = function (emailStart) {

            if (emailStart == 'Named') {
                if ($scope.clientEmail.StartDearNamed == true) {
                    $scope.clientEmail.StartDearSirMadam = false;
                    $scope.clientEmail.StartToWhomItMayConcern = false;
                }
                else {
                    $scope.clientEmail.StartDearSirMadam = true;
                    $scope.clientEmail.StartToWhomItMayConcern = false;
                }
            }
            else if (emailStart == 'SirMadam') {

                if ($scope.clientEmail.StartDearSirMadam == true) {
                    $scope.clientEmail.StartDearNamed = false;
                    $scope.clientEmail.StartToWhomItMayConcern = false;
                }
                else {
                    $scope.clientEmail.StartDearNamed = false;
                    $scope.clientEmail.StartToWhomItMayConcern = true;
                }
            }
            else if (emailStart == 'ToWhomItMayConcern') {

                if ($scope.clientEmail.StartToWhomItMayConcern == true) {
                    $scope.clientEmail.StartDearSirMadam = false;
                    $scope.clientEmail.StartDearNamed = false;
                }
                else {
                    $scope.clientEmail.StartDearSirMadam = false;
                    $scope.clientEmail.StartDearNamed = true;
                }
            }
        }

        $scope.toggleEmailSend = function (emailSend) {

            if (emailSend == 'SendASAP') {
                $scope.clientEmail.SendAfter = !$scope.clientEmail.SendAfter;
            }
            else if (emailSend == 'SendAfter') {
                $scope.clientEmail.SendASAP = !$scope.clientEmail.SendASAP;
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

            if ($scope.clientEmail.SendASAP == true) {
                $scope.clientEmail.SendAfterDateTime = null;
            }
            else {
                var x = document.getElementById("clientEmailSendAfterTime").value;

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

                var newDate = $scope.clientEmail.SendAfterDate + " " + myTime;
                $scope.clientEmail.SendAfterDateTime = $filter('date')(newDate, 'dd/mm/yyyy hh:mm:ss');
            }

            if ($scope.validateForm()) {

                $scope.emailAllService.RecordEmails($scope.clientEmail)
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


            if (angular.isDefined($scope.clientEmail.CCEmailAddresses)) {
                if ($scope.clientEmail.CCEmailAddresses.length > 0) {
                    if (!$scope.isValidEmail($scope.clientEmail.CCEmailAddresses)) {
                        $scope.validationMessage = "Invalid Copy Email Address";
                    }
                }
            }

            if (angular.isDefined($scope.clientEmail.BCCEmailAddresses)) {
                if ($scope.clientEmail.BCCEmailAddresses.length > 0) {
                    if (!$scope.isValidEmail($scope.clientEmail.BCCEmailAddresses)) {
                        $scope.validationMessage = "Invalid Blind Copy Address";
                    }
                }
            }

            if (angular.isDefined($scope.clientEmail.Subject)) {
                if ($scope.clientEmail.Subject.length < 4) {
                    $scope.validationMessage = "The Email Subject must be at least 4 characters in length";
                }
            }
            else {
                $scope.validationMessage = "Please enter the Subject description of the Email";
            }

            if (angular.isDefined($scope.clientEmail.Content)) {
                if ($scope.clientEmail.Content.length == 0) {
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

        $scope.openClientsWithoutEmailsModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Clients Without Emails",
                cssClass: "clientsWithoutEmailsModal",
                filePath: "/app/components/course/clientsWithoutEmails.html",
                controllerName: "ClientsWithoutEmailsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        EmailAllService.ClientsWithoutEmails($scope.clientEmail.CourseId)
            .then(
                function successCallback(response) {
                    $scope.clientsWithoutEmails = response.data;
                },
                function errorCallback(response) {
                    $scope.validationMessage = "Unable to determine if there are Clients without emails.";
                }
            );
    }
})();

