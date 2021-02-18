(function () {

    'use strict';
    
    angular
        .module("app")
        .service("RecordPaymentService", RecordPaymentService);

    RecordPaymentService.$inject = ["$http"];

    function RecordPaymentService($http) {

        var recordPayment = this;

        /**
         * Send data to the web api
         * save the payment
         */
        recordPayment.save = function (paymentDetails) {
            return $http.post(apiServer + "/RecordPayment", paymentDetails)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };

    }

})();