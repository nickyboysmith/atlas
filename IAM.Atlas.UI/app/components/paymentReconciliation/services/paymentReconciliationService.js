(function () {

    'use strict';

    angular
        .module("app")
        .service("PaymentReconciliationService", PaymentReconciliationService);


    PaymentReconciliationService.$inject = ["$http"];

    function PaymentReconciliationService($http) {

        var PaymentReconciliationService = this;

        PaymentReconciliationService.getPaymentReconciliationList = function (organisationId) {
            return $http.get(apiServer + "/PaymentReconciliation/GetPaymentReconciliationListByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        PaymentReconciliationService.getPaymentReconciliationData = function (reconciliationId) {
            return $http.get(apiServer + "/PaymentReconciliation/GetPaymentReconciliationData/" + reconciliationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        PaymentReconciliationService.SaveNewReconciliation = function (document) {
            return $http.post(apiServer + "/PaymentReconciliation/SaveNewReconciliation", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            )
            .then(function (response)
            { return response.data; },
            function (response, status)
            { return response.data; });
        }
    }
})();