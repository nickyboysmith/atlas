(function () {

    'use strict';

    angular
        .module("app")
        .factory("ReportManagementFactory", ReportManagementFactory);


    function ReportManagementFactory() {

        var reportFactoryMethods = {
            getDisabledMessage: getDisabledMessage, 
            convertToInteger: convertToInteger
        };


        return reportFactoryMethods;

        function getDisabledMessage(status) {
            
            if (typeof status === "object") {
                status = status.disabled;
            }


            if (status === false) {
                return {
                    disabled: status,
                    label: "Click the checkbox to Enable this report category",
                    status: "Disabled"
                };
            }
            if (status === true) {
                return {
                    disabled: status,
                    label:  "Click the checkbox to Disable this report category",
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