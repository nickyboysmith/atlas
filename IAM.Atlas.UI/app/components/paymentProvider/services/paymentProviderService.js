(function () {

    'use strict';

    angular
        .module('app')
        .service('PaymentProviderService', PaymentProviderService);

    PaymentProviderService.$inject = ["$http"];

    function PaymentProviderService($http) {

        var paymentProviderService = this;

   
        /**
       * get the Payment Providers
       */
        paymentProviderService.getPaymentProviders = function () {
            return $http.get(apiServer + "/paymentprovider/getPaymentProviders/")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the Payment Providers Details By OrganisationId
         */
        paymentProviderService.getPaymentProvidersByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/paymentprovider/getPaymentProvidersByOrganisation/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the Payment Providers Details By PaymentProviderId
         */
        paymentProviderService.getPaymentProviderDetailsByPaymentProviderId = function (PaymentProviderId) {
            return $http.get(apiServer + "/paymentprovider/getPaymentProviderDetailsByPaymentProviderId/" + PaymentProviderId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
       * creates or updates the Payment Providers
       */
        paymentProviderService.savePaymentProvider = function (paymentProvider) {
            return $http.post(apiServer + "/paymentProvider/savePaymentProvider", paymentProvider)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }
})();