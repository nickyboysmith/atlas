(function () {

    'use strict';

    angular
        .module("app")
        .factory("AreaManagementFactory", AreaManagementFactory);


    function AreaManagementFactory() {

        var areaFactoryMethods = {
            getDisabledMessage: getDisabledMessage,
            convertToInteger: convertToInteger
        };


        return areaFactoryMethods;

        function getDisabledMessage(status) {

            if (typeof status === "object") {
                status = status.area;
            }


            if (status === true) {
                return {
                    area: status,
                    label: "Click the checkbox to Enable this area",
                    status: "Disabled"
                };
            }
            if (status === false) {
                return {
                    area: status,
                    label: "Click the checkbox to Disable this area",
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