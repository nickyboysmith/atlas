(function () {

    'use strict';

    angular
        .module("app")
        .controller("FindRefundRequestCtrl", FindRefundRequestCtrl);

    FindRefundRequestCtrl.$inject = ["$scope", "$timeout", "$filter", "activeUserProfile", "ModalService", "RefundRequestService", "RefundService"];

    function FindRefundRequestCtrl($scope, $timeout, $filter, activeUserProfile, ModalService, RefundRequestService, RefundService) {

        $scope.refundRequestTypes = [];
        $scope.refundRequestType = "2";
        $scope.recordedRefundRequests = [];
        $scope.selectedRefundRequestId = -1;
        $scope.selectedRelatedPaymentAmount = 0;
        $scope.loading = false;
        $scope.selectedRefundRequest = {};
        
        $scope.refundRequestTypeString = function (refundRequestType) {
            var refundRequestTypeString = "new";
            if(refundRequestType == "2"){
                refundRequestTypeString = "all";
            }
            else if (refundRequestType == "3") {
                refundRequestTypeString = "cancelled";
            }
            else if (refundRequestType == "4") {
                refundRequestTypeString = "completed";
            }
            return refundRequestTypeString;
        }

        $scope.loadRefundRequests = function () {
            $scope.loading = true;
            RefundRequestService.findRefundRequests(activeUserProfile.selectedOrganisation.Id, $scope.refundRequestTypeString($scope.refundRequestType))
                .then(
                    function (data) {
                        $scope.refundRequests = data;

                        angular.forEach($scope.refundRequests, function (item, key) {
                            if(item.RequestCompleted == true) {
                                item.Status = 'Completed';
                            } else if (item.RequestCancelled == true) {
                                item.Status = 'Cancelled';
                            } else {
                                item.Status = '';
                            }
                        });

                        $scope.loading = false;
                    },
                    function (data) {
                        $scope.loading = false;
                    }
                );
        }

        $scope.refundRequestTypeChange = function (refundRequestType) {
            $scope.refundRequestType = refundRequestType;
            $scope.loadRefundRequests();
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

        $scope.selectRefundRequest = function (refundRequest) {
            $scope.validationMessage = '';
            $scope.selectedRefundRequest = refundRequest;
        }

        $scope.recordRefundSelectedPaymentModal = function () {
            $scope.refundPaymentId = $scope.selectedRefundRequest.RelatedPaymentId;
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

        $scope.cancelRefundRequestModal = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Cancel Refund Request",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/refundRequest/cancel.html",
                controllerName: "cancelRefundRequestCtrl",
                cssClass: "cancelRefundRequestModal"
            });
        }


        // initialise the page
        $scope.loadRefundRequests();
    };


})();