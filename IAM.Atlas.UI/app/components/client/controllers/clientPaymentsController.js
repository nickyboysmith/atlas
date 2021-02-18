(function () {
    'use strict';

    angular
        .module('app')
        .controller('ClientPaymentsCtrl', ClientPaymentsCtrl);


    ClientPaymentsCtrl.inject = ['$scope', '$location', '$window', '$http', '$filter', 'DateFactory', 'ModalService', 'ClientService', 'OrganisationSelfConfigurationService', 'RefundService', 'activeUserProfile'];

    function ClientPaymentsCtrl($scope, $location, $window, $http, $filter, DateFactory, ModalService, ClientService, OrganisationSelfConfigurationService, RefundService, activeUserProfile) {
        
        $scope.client = {};
        $scope.loading = false;
        $scope.recordedPayments = [];
        $scope.recordedPaymentsTemplate = [];
        $scope.selectedPaymentId = -1;
        $scope.validationMessage = '';
        $scope.selectedPaymentAmount = 0;

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

        $scope.loadPayments = function () {
            $scope.loading = true;
            ClientService.getPaymentsByClient($scope.clientId, activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.payments = response.data;
                        $scope.recordedPayments = $scope.payments;
                        $scope.recordedPaymentsTemplate = $scope.recordedPayments;
                        if ($scope.recordedPayments.length > 0) {
                            $scope.client.Name = $scope.recordedPayments[0].ClientName;
                        }
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = "An error occurred, please try again.";
                    }
                );
            $scope.loading = false;
        }

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
                    function successCallback(response) {
                        if (response.data == true) {
                            $scope.validationMessage = 'Refund Cancelled';
                            $scope.loadPayments();
                        }
                        else {
                            $scope.validationMessage = 'Refund not cancelled. Please try again.';
                        }
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = 'An error occurred.';
                    }
                );
        }

        if ($scope.payments) {  // the payments passed through from the client details
            $scope.loading = true;
            $scope.recordedPayments = $scope.payments;
            $scope.recordedPaymentsTemplate = $scope.recordedPayments;
            if ($scope.recordedPayments.length > 0) {
                $scope.client.Name = $scope.recordedPayments[0].ClientName;
            }
            $scope.loading = false;
        }
        else {  // passed from the client search
            $scope.loadPayments();
        }

    }
})();