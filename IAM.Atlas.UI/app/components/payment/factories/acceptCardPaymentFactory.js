(function () {

    'use strict';

    angular
        .module("app")
        .factory("AcceptCardPaymentFactory", AcceptCardPaymentFactory);

    function AcceptCardPaymentFactory() {

        /**
         * Create a secret key
         * To use for Encryption
         */
        this.getSecretEncryptionKey = function (userId) {
            var theToken = sessionStorage.getItem("authToken");
            var currentDate = new Date().toLocaleTimeString();
            return {
                creationDate: currentDate,
                key: theToken + "_" + currentDate + "_" + userId
            }
        };

        /**
         * Hash the Card Details
         * 
         */
        this.createHashedCardDetails = function (cardObject, secretKey) {
            return 'ptok_' + CryptoJS.AES.encrypt(JSON.stringify(cardObject), secretKey);
        };

        return {
            getSecret: this.getSecretEncryptionKey,
            hashCard: this.createHashedCardDetails
        };

    }

})();