(function () {

    'use strict';

    angular
        .module("app")
        .factory("PaymentManagementFactory", PaymentManagementFactory);


    function PaymentManagementFactory() {

        var paymentFactoryMethods = {
            getDisabledMessage: getDisabledMessage, 
            convertToInteger: convertToInteger
        };


        return paymentFactoryMethods;

        function getDisabledMessage(status) {

            if (typeof status === "object") {
                status = status.payment;
            }


            if (status === true) {
                return {
                    payment: status,
                    label: "Click the checkbox to Enable this payment type",
                    status: "Disabled"
                };
            }
            if (status === false) {
                return {
                    payment: status,
                    label:  "Click the checkbox to Disable this payment type",
                    status: "Enabled"
                };
            }
        }

        function convertToInteger(status) {
            if (status === true) {
                return 1;
            }
            if (status === false) {
                return 0;
            }
        }

    }

})();