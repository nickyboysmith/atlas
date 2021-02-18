(function () {

    'use strict';

    angular
        .module("app")
        .controller("RefundPaymentCtrl", RefundPaymentCtrl);

    RefundPaymentCtrl.$inject = ["$scope", "activeUserProfile", "ModalService", "PaymentService", "RefundService", "DateFactory"];

    function RefundPaymentCtrl($scope, activeUserProfile, ModalService, PaymentService, RefundService, DateFactory) {
        $scope.refund = {};
        $scope.payment = {};
        $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        $scope.refundMethods = [];
        $scope.refundTypes = [];
        $scope.previousRefundAmount = -1;
        $scope.displayCalendar = false;
        $scope.validationMessage = '';

        $scope.getRefund = function (paymentId) {
            RefundService.getPaymentRefundedAmount(paymentId)
                .then(
                    function (data) {
                        if(data != null){
                            $scope.previousRefundAmount = data;
                        }
                        else {
                            $scope.validationMessage = "Couldn't retrieve refund associated to this payment.";
                        }
                    },
                    function (data) {
                        $scope.validationMessage = "Couldn't retrieve refund associated to this payment.";
                    }
                );
        }

        $scope.loadPayment = function (paymentId) {
            PaymentService.get(paymentId)
                .then(
                    function (data) {
                        $scope.payment = data;

                        // prepopulate the refund with the payment data
                        $scope.refund.Amount = $scope.payment.PaymentAmount;
                        $scope.refund.Payee = $scope.payment.ClientName;
                        $scope.refund.PaymentDate = DateFactory.formatDateSlashes(new Date());
                        $scope.refund.Reference = $scope.payment.PaymentReference;

                        $scope.getRefund($scope.payment.PaymentId);
                    },
                    function (data) {

                    }
                );
        }

        $scope.formatDate = function (date) {
            var formattedDate = DateFactory.formatDateSlashes(DateFactory.parseDate(date));
            return formattedDate;
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

        $scope.getRefundMethodsAndTypes = function () {
            RefundService.getRefundMethods($scope.organisationId)
                .then(
                    function (data) {
                        $scope.refundMethods = data;
                        RefundService.getRefundTypes($scope.organisationId)
                            .then(
                                function (data) {
                                    $scope.refundTypes = data;
                                },
                                function (data) {
                                    $scope.validationMessage = "Error retrieving Refund Types.";
                                }
                            );
                    },
                    function (data) {
                        $scope.validationMessage = "Error retrieving Refund Methods.";
                    }
                );
        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.validForm = function () {
            var valid = true;
            if (!$scope.refund.RefundMethodId || $scope.refund.RefundMethodId == '') {
                $scope.validationMessage = "Please select a refund method.";
                valid = false;
            }
            else if (!$scope.refund.RefundTypeId || $scope.refund.RefundTypeId == '') {
                $scope.validationMessage = "Please select a refund type.";
                valid = false;
            }
            else if (!$scope.refund.Payee || $scope.refund.Payee == '') {
                $scope.validationMessage = "Please enter a name in the Payee field.";
                valid = false;
            }
            return valid;
        }

        $scope.saveRefund = function () {
            if ($scope.validForm()) {
                RefundService.saveRefund($scope.refund.PaymentDate,
                                        $scope.refund.Amount,
                                        $scope.refund.RefundMethodId,
                                        $scope.refund.RefundTypeId,
                                        activeUserProfile.UserId,
                                        $scope.refund.Reference,
                                        $scope.refund.Payee,
                                        activeUserProfile.selectedOrganisation.Id,
                                        $scope.payment.PaymentId,
                                        $scope.refund.Notes)
                    .then(
                        function (data) {
                            if (data == true) {
                                $scope.validationMessage = "Refund saved.";
                                $scope.loadPayment($scope.refundPaymentId);

                                if ($scope.loadPayments) {
                                    $scope.loadPayments();
                                }
                                else if ($scope.$parent.loadPayments) {
                                    $scope.$parent.loadPayments();
                                }
                                else if ($scope.$parent.loadRefundRequests) {
                                        $scope.$parent.loadRefundRequests();
                                }
                                // refresh client details if we came from the client details modal
                                if ($scope.clientId && $scope.loadClientDetails) {
                                    $scope.loadClientDetails($scope.clientId);
                                }
                            }
                            else {
                                $scope.validationMessage = "Refund not saved, please try again.";
                            }
                        },
                        function (data) {
                            $scope.validationMessage = "An error occurred, please try again.";
                        }
                    );
            }
        }

        if ($scope.refundPaymentId) {
            $scope.getRefundMethodsAndTypes($scope.organisationId);
            $scope.loadPayment($scope.refundPaymentId);
        }
    };


})();