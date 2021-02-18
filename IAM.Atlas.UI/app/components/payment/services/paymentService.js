(function () {

    'use strict';

    angular
        .module("app")
        .service("PaymentService", PaymentService);


    PaymentService.$inject = ["$http"];

    function PaymentService($http) {

        var paymentService = this;

        paymentService.get = function (paymentId) {
            return $http.get(apiServer + "/payment/" + paymentId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * Get paymentTypes associated with the 
         * selected organisation
         */
        paymentService.getPaymentTypes = function (organisationId) {
            return $http.get(apiServer + "/paymenttype/related/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get payment methods 
         * Associated with an organisation
         */
        paymentService.getPaymentMethods = function (organistionId) {
            return $http.get(apiServer + "/ClientPayment/GetPaymentMethods/" + organistionId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Find recorded payments 
         * Associated with an organisation
         */
        paymentService.findPayments = function (organistionId, paymentType, paymentMethod, paymentPeriod, paymentOrRefund) {
            return $http.get(apiServer + "/PaymentSearch/find/" + organistionId + "/" + paymentType + "/" + paymentMethod + "/" + paymentPeriod + "/" + paymentOrRefund)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        paymentService.AddClientAndCourseToPayment = function (ClientId, PaymentId, CourseId, UserId) {
            return $http.get(apiServer + "/AddClientAndCourseToPayment/" + ClientId + "/" + PaymentId + "/" + CourseId + "/" + UserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        paymentService.getNotes = function (paymentId) {
            return $http.get(apiServer + "/PaymentNote/GetNotesByPayment/" + paymentId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }
    }

})();