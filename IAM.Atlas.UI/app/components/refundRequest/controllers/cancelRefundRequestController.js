(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('cancelRefundRequestCtrl', cancelRefundRequestCtrl);

    cancelRefundRequestCtrl.$inject = ["$scope", "RefundService", "ModalService", 'activeUserProfile'];

    function cancelRefundRequestCtrl($scope, RefundService, ModalService, activeUserProfile) {

        $scope.refundRequest = {
            Id: $scope.selectedRefundRequest. RefundRequestId,
            payee: $scope.$parent.selectedRefundRequest.RefundRequestPaymentName,
            paymentAmount: $scope.selectedRefundRequest.RelatedPaymentAmount
        };

        $scope.cancelRefundRequest = function ($event) {
            $event.currentTarget.disabled = true;
            RefundService.cancelRefundRequest($scope.refundRequest.Id, activeUserProfile.UserId)
            .then(
                    function (data) {
                        $scope.$parent.loadRefundRequests();
                        $scope.close();
                    },
                    function (data) {
                        $scope.validationMessage = data.ExceptionMessage;
                        $event.currentTarget.disabled = false;
                    }
                );
        }

        $scope.close = function () {
            ModalService.closeCurrentModal("cancelRefundRequestModal");
        }
    }
})();