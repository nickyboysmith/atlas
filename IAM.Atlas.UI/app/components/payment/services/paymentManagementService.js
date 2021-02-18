(function () {

    'use strict';

    angular
        .module("app")
        .service("PaymentManagementService", PaymentManagementService);


    PaymentManagementService.$inject = ["$http"];

    function PaymentManagementService($http) {

        var management = this;

        /**
         * Call the web api return a boolean 
         * If user is in the 
         * System administrator user table
         */
        management.checkSystemAdminUser = function (userID)
        {
            return $http.get(apiServer + "/systemadmin/" + userID)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };

        /**
         * Get paymentTypes associated with the 
         * selected organisation
         */
        management.getPaymentTypes = function (organistionId)
        {
            return $http.get(apiServer + "/paymenttype/getPaymentTypesByOrganisation/" + organistionId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };

        /**
         * Get payment methods 
         * Associated with an organisation
         */
        management.getPaymentMethods = function (organistionId) {
            return $http.get(apiServer + "/ClientPayment/GetPaymentMethods/" + organistionId)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };

        /**
         * Get organisations associated with logged in user
         * [OrganisationUser] Table
         */
        management.getRelatedOrganisations = function (userID)
        {
            return $http.get(apiServer + "/paymenttype/" + userID)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };

        /**
         * Send The payment Type object
         * To the WebAPI
         */
        management.savePaymentType = function (paymentTypeObject)
        {
            return $http.post(apiServer + "/paymenttype", paymentTypeObject)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };
    }

})();