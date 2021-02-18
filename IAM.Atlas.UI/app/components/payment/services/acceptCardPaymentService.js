(function () {

    'use strict';

    angular
        .module("app")
        .service("AcceptCardPaymentService", AcceptCardPaymentService);

    AcceptCardPaymentService.$inject = ["$http"];

    function AcceptCardPaymentService($http) {


        var acceptCard = this;

        /**
         * Process telephone payments
         * Add the type to the request
         * 
         */
        acceptCard.processTelephonePayment = function (paymentDetail) {
            paymentDetail = angular.extend(paymentDetail, {type: "telephone"});
            return $http.post(apiServer + "/payment", paymentDetail)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };


        /**
         * For a quick search on the card supplier table
         */
        acceptCard.getCardSuppliers = function (searchContent) {
            return $http.get(apiServer + "/paymentcardsupplier/" + searchContent)
                .then(function (response) {
                    return response.data.map(function (item) {
                        return item;
                    });
                });
        };

        /**
         * Get the Payment Card Types
         */
        acceptCard.getPaymentCardTypes = function () {
            return $http.get(apiServer + "/paymentcardtype")
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }
        
        /**
         * Get the Payment Card Validation Types
         */
        acceptCard.getPaymentCardValidationTypes = function () {
            return $http.get(apiServer + "/PaymentCardValidationType")
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        }

    };

})();