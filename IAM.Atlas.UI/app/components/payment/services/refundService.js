(function () {

    'use strict';

    angular
        .module("app")
        .service("RefundService", RefundService);


    RefundService.$inject = ["$http"];

    function RefundService($http) {

        var refundService = this;

        refundService.getRefundMethods = function(organisationId)
        {
            return $http.get(apiServer + "/Refund/GetRefundMethods/" + organisationId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.getRefundTypes = function(organisationId)
        {
            return $http.get(apiServer + "/Refund/GetRefundTypes/" + organisationId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.getRefund = function(refundId)
        {
            return $http.get(apiServer + "/Refund/" + refundId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.getRefundsByPayment = function (paymentId) {
            return $http.get(apiServer + "/Refund/GetRefundsByPayment/" + paymentId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.getRefundsByClient = function (clientId) {
            return $http.get(apiServer + "/Refund/GetRefundsByClient/" + clientId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.getPaymentRefundedAmount = function (paymentId) {
            return $http.get(apiServer + "/Refund/getPaymentRefundedAmount/" + paymentId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.saveRefund = function (   TransactionDate, 
                                                Amount, 
                                                RefundMethodId, 
                                                RefundTypeId, 
                                                CreatedByUserId, 
                                                Reference, 
                                                PaymentName, 
                                                OrganisationId, 
                                                PaymentId, 
                                                Notes)
        {
            var refund = {};
            refund.TransactionDate = TransactionDate;
            refund.Amount = Amount;
            refund.RefundMethodId = RefundMethodId;
            refund.RefundTypeId = RefundTypeId;
            refund.CreatedByUserId = CreatedByUserId;
            refund.Reference = Reference;
            refund.PaymentName = PaymentName;
            refund.OrganisationId = OrganisationId;
            refund.PaymentId = PaymentId;
            refund.Notes = Notes;
            return $http.post(apiServer + "/Refund/", refund)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.saveRefundRequest = function (TransactionDate,
                                        Amount,
                                        RefundMethodId,
                                        RefundTypeId,
                                        CreatedByUserId,
                                        Reference,
                                        PaymentName,
                                        OrganisationId,
                                        PaymentId,
                                        ClientId,
                                        CourseId,
                                        Notes) {
            var refundRequest = {};
            refundRequest.TransactionDate = TransactionDate;
            refundRequest.Amount = Amount;
            refundRequest.RefundMethodId = RefundMethodId;
            refundRequest.RefundTypeId = RefundTypeId;
            refundRequest.CreatedByUserId = CreatedByUserId;
            refundRequest.Reference = Reference;
            refundRequest.PaymentName = PaymentName;
            refundRequest.OrganisationId = OrganisationId;
            refundRequest.PaymentId = PaymentId;
            refundRequest.Notes = Notes;
            refundRequest.ClientId = ClientId;
            refundRequest.CourseId = CourseId;
            return $http.post(apiServer + "/Refund/saveRefundRequest/", refundRequest)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.cancelRefund = function (paymentId, cancelledByUserId) {
            return $http.get(apiServer + "/Refund/Cancel/" + paymentId + "/" + cancelledByUserId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

        refundService.cancelRefundRequest = function (refundRequestId, cancelledByUserId) {
            return $http.get(apiServer + "/Refund/CancelRequest/" + refundRequestId + "/" + cancelledByUserId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }
    }

})();