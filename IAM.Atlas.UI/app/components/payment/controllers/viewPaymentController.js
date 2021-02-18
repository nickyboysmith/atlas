(function () {

    'use strict';

    angular
        .module("app")
        .controller("ViewPaymentCtrl", ViewPaymentCtrl);

    ViewPaymentCtrl.$inject = ["$scope", "$timeout", "activeUserProfile", "ModalService", "PaymentService", "DateFactory"];

    function ViewPaymentCtrl($scope, $timeout, activeUserProfile, ModalService, PaymentService, DateFactory) {


        /**
         * Instantiate payment detail object
         */
        $scope.paymentDetail = {};
        $scope.showCourseSection = true;
        $scope.showDateCreated = false;
        $scope.paymentNotes = [];

        $scope.getNotes = function () {
            if ($scope.paymentId) {
                PaymentService.getNotes($scope.paymentId)
                    .then(
                        function (data) {
                            $scope.paymentNotes = data;
                        },
                        function (data) {

                        }
                    );
            }
        }

        $scope.getPayment = function () {
            if ($scope.paymentId) {
                PaymentService.get($scope.paymentId)
                .then(
                    function (data) {
                        if (data) {
                            $scope.showCourseSection = true;
                            $scope.paymentDetail = data;
                            if (!$scope.paymentDetail.ClientName || $scope.paymentDetail.ClientName == "") {
                                $scope.paymentDetail.ClientName = "*Unallocated Payment*";
                                if (!$scope.paymentDetail.CourseReference) {
                                    $scope.showCourseSection = false;
                                }
                            }
                            //else {
                            //    if (!$scope.paymentDetail.PaymentName || $scope.paymentDetail.PaymentName == "") {
                            //        $scope.paymentDetail.ClientName = "*Unallocated Payment*";
                            //        if (!$scope.paymentDetail.CourseReference) {
                            //            $scope.showCourseSection = false;
                            //        }
                            //    }
                            //}
                            var formattedTransactionDate = $scope.formatDate($scope.paymentDetail.TransactionDate);
                            var formattedDateCreated = $scope.formatDate($scope.paymentDetail.DateCreated);
                            if (formattedTransactionDate != formattedDateCreated) {
                                $scope.showDateCreated = true;
                            }
                        }
                        else {

                        }
                    },
                    function (data) {

                    }
                );
            }
        }

        $scope.clientButtonClicked = function () {
            if ($scope.paymentDetail.ClientName && $scope.paymentDetail.ClientName != "*Unallocated Payment*") {
                // view client details
                $scope.openClientModal($scope.paymentDetail.ClientId);
            }
            else {      // assign a client to this payment
                $scope.assignClient();
            }
        }

        /**
        * Assign a client
        * To the current payment about to be recorded
        */
        $scope.assignClient = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Assign Client",
                    cssClass: "recordPaymentAssignClientModal",
                    filePath: "/app/components/client/findSingle.html",
                    controllerName: "FindSingleClientCtrl",
                        buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                            action : function (dialogItself) {
                                dialogItself.close();
                            }
                        }
            });
        };

            /**
          * Assign a client
          * To the current payment about to be recorded
          */
        $scope.AddPaymentNote = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Add Payment Note",
                    cssClass: "addPaymentNoteModal",
                    filePath: "/app/components/payment/addNote.html",
                    controllerName: "addPaymentNoteCtrl",
                            buttons: {
                            label: 'Close',
                            cssClass: 'closeModalButton',
                                action : function (dialogItself) {
                                        dialogItself.close();
            }
        }
        });
        };

            /**
             * Update the payment 
             * With the client object
             * 
             * Check to see where we should assign the client to [client/course]
             */
        $scope.updateAssignedClient = function (assignedClient) {

            var courseId = -1;
            if (assignedClient.courses.length > 0) {
                courseId = assignedClient.courses[0].CourseId;
            }

            PaymentService.AddClientAndCourseToPayment(assignedClient.clientId, $scope.paymentId, courseId, activeUserProfile.UserId)
                .then(
                    function (data) {
                        $scope.statusMessage = "Client added to Payment successfully.";
                        $scope.getPayment();
                    },
                    function (data) {

                    }
                );
        };

        $scope.formatDate = function (date) {
            var formattedDate = DateFactory.formatDateSlashes(DateFactory.parseDate(date));
            return formattedDate;
        }

        /**
         * Initialise the page
         */
        $scope.getPayment();
        $scope.getNotes();
    };


})();