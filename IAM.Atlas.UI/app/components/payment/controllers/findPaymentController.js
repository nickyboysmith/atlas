(function () {

    'use strict';

    angular
        .module("app")
        .controller("FindPaymentCtrl", FindPaymentCtrl);

    FindPaymentCtrl.$inject = ["$scope", "$timeout", "$filter", "activeUserProfile", "ModalService", "PaymentService", "RefundService", "DateFactory"];

    function FindPaymentCtrl($scope, $timeout, $filter, activeUserProfile, ModalService, PaymentService, RefundService, DateFactory) {

        $scope.paymentTypes = [];
        $scope.paymentMethods = [];
        $scope.selectedPaymentTypeId = "-1";
        $scope.selectedPaymentMethodId = "-1";
        $scope.paymentPeriods = [   { Name: "Today's Payments" },
                                    { Name: "Yesterday's Payments" },
                                    { Name: "This Week's Payments" },
                                    { Name: "This Month's Payments" },
                                    { Name: "The Previous Month's Payments" },
                                    { Name: "Payments Two Months Ago" },
                                    { Name: "This Year's Payments" },
                                    { Name: "The Previous Year's Payments" }];
        $scope.paymentOrRefund = "1";
        $scope.recordedPayments = [];
        $scope.recordedPaymentsTemplate = [];
        $scope.selectedPaymentPeriod = "-1";
        $scope.selectedPaymentId = -1;
        $scope.selectedPaymentAmount = 0;
        $scope.loading = false;
        $scope.selectedPaymentPeriod = "Today's Payments";
        
        $scope.loadPaymentTypes = function () {
            PaymentService.getPaymentTypes(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function (data) {
                        $scope.paymentTypes = data;
                    },
                    function (data) {

                    }
                );
        }

        $scope.loadPaymentMethods = function () {
            PaymentService.getPaymentMethods(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function (data) {
                        $scope.paymentMethods = data;
                    },
                    function (data) {

                    }
                );
        }

        $scope.showDisabled = function (paymentType) {
            var paymentTypeDisabled = paymentType.Name;
            if(paymentType.Disabled){
                paymentTypeDisabled = paymentTypeDisabled + " (disabled)";
            }
            return paymentTypeDisabled;
        }

        $scope.initSelectedPaymentTypeId = function () {
            $scope.selectedPaymentTypeId = "-1";
        }

        $scope.initSelectedPaymentMethodTypeId = function () {
            $scope.selectedPaymentMethodId = "-1";
        }

        //$scope.initSelectedPaymentPeriod = function () {
        //    $scope.selectedPaymentPeriod = selectedPaymentPeriod;
        //}

        $scope.formatDate = function (date) {
            var formattedDate = DateFactory.formatDateSlashes(DateFactory.parseDate(date));
            return formattedDate;
        }

        $scope.paymentOrRefundString = function (paymentOrRefund) {
            var paymentOrRefundString = "all";
            if(paymentOrRefund == "2"){
                paymentOrRefundString = "payment";
            }
            else if (paymentOrRefund == "3") {
                paymentOrRefundString = "refund";
            }
            return paymentOrRefundString;
        }

        $scope.loadPayments = function () {
            $scope.loading = true;
            PaymentService.findPayments(activeUserProfile.selectedOrganisation.Id, $scope.selectedPaymentTypeId, $scope.selectedPaymentMethodId, $scope.selectedPaymentPeriod, $scope.paymentOrRefundString($scope.paymentOrRefund))
                .then(
                    function (data) {
                        $scope.recordedPayments = data;
                        $scope.recordedPaymentsTemplate = $scope.recordedPayments;
                        $scope.loading = false;
                    },
                    function (data) {
                        $scope.loading = false;
                    }
                );
        }

        $scope.typeChange = function (typeId) {
            $scope.selectedPaymentTypeId = typeId;
            $scope.loadPayments();
        }

        $scope.methodChange = function (methodId) {
            $scope.selectedPaymentMethodId = methodId;
            $scope.loadPayments();
        }

        $scope.paymentPeriodChange = function (period) {
            $scope.selectedPaymentPeriod = period;
            $scope.loadPayments();
        }

        $scope.paymentOrRefundChange = function (paymentOrRefund) {
            $scope.paymentOrRefund = paymentOrRefund;
            $scope.loadPayments();
        }

        $scope.openPaymentModal = function (paymentId) {

            $scope.paymentId = parseInt(paymentId);
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.userId = activeUserProfile.UserId;

            ModalService.displayModal({
                scope: $scope,
                title: "Payment Detail",
                cssClass: "paymentViewModal",
                filePath: "/app/components/payment/view.html",
                controllerName: "ViewPaymentCtrl"
            });
        }

        $scope.openCourseModal = function (courseId) {

            $scope.courseId = parseInt(courseId);
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.userId = activeUserProfile.UserId;

            ModalService.displayModal({
                scope: $scope,
                title: "View Course",
                cssClass: "courseViewModal",
                filePath: "/app/components/course/edit.html",
                controllerName: "editCourseCtrl"
            });
        }

        $scope.openClientModal = function (clientId) {
            /**
             * Create Modal Buttons Object
             */
            var modalDetails = {
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            };

            $scope.clientId = clientId;
            modalDetails = angular.extend(modalDetails, {
                scope: $scope,
                title: "Client Details",
                cssClass: "clientDetailModal",
                filePath: "/app/components/client/cd_view.html",
                controllerName: "clientDetailsCtrl",
            });

            /**
             * Fire the modal
             */
            ModalService.displayModal(modalDetails);
        };

        $scope.selectPayment = function (paymentId, paymentAmount) {
            $scope.validationMessage = '';
            if ($scope.selectedPaymentId == paymentId) {
                $scope.selectedPaymentId = -1;
                $scope.selectedPaymentAmount = 0;
            }
            else {
                $scope.selectedPaymentId = paymentId;
                $scope.selectedPaymentAmount = paymentAmount;
            }
        }

        $scope.cancelRefundPayment = function () {
            RefundService.cancelRefund($scope.selectedPaymentId, activeUserProfile.UserId)
                .then(
                    function (data) {
                        if (data == true) {
                            $scope.validationMessage = 'Refund Cancelled';
                            $scope.loadPayments();
                        }
                        else {
                            $scope.validationMessage = 'Refund not cancelled. Please try again.';
                        }
                    },
                    function (data) {
                        $scope.validationMessage = 'An error occurred.';
                    }
                );
        }

        $scope.refundSelectedPayment = function () {
            $scope.refundPaymentId = $scope.selectedPaymentId;
            ModalService.displayModal({
                scope: $scope,
                title: "Record Payment Refund",
                cssClass: "refundPaymentModal",
                filePath: "/app/components/payment/refund.html",
                controllerName: "RefundPaymentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        $scope.requestRefundForSelectedPayment = function () {
            $scope.refundPaymentId = $scope.selectedPaymentId;
            ModalService.displayModal({
                scope: $scope,
                title: "Request Refund Payment ",
                cssClass: "requestRefundPaymentModal",
                filePath: "/app/components/payment/requestRefund.html",
                controllerName: "RequestRefundPaymentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        // initialise the page
        $scope.loadPaymentTypes();
        $scope.loadPaymentMethods();
        $scope.loadPayments();
    };


})();