(function () {

    'use strict';

    angular
        .module("app")
        .factory("CourseTypeFactory", CourseTypeFactory);


    function CourseTypeFactory() {

        var courseTypeFactoryMethods = {
            getDisabledMessage: getDisabledMessage,
            convertToInteger: convertToInteger
        };


        return courseTypeFactoryMethods;

        function getDisabledMessage(status) {

            if (typeof status === "object") {
                status = status.courseType;
            }


            if (status === true) {
                return {
                    courseType: status,
                    label: "Click the checkbox to Enable this course type",
                    status: "Disabled"
                };
            }
            if (status === false) {
                return {
                    courseType: status,
                    label: "Click the checkbox to Disable this course type",
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