(function () {

    'use strict';

    angular
        .module("app")
        .factory("RecordPaymentFactory", RecordPaymentFactory);

    function RecordPaymentFactory() {

        /**
         * Loop through the client courses object
         * Then add all the payment due amounts
         */
        this.getTotalOutstandingAmount = function (clientCourses) {
            var amount = 0;

            if (clientCourses.length === 0) {
                return 0;
            }

            /**
             * Loop through to get the total amount
             */
            angular.forEach(clientCourses, function (value, index) {
                if (value.PaymentAmount !== null || value.PaymentAmount !== undefined) {
                    amount += value.PaymentAmount;
                }
            });

            return amount.toFixed(2);
        };

        /**
         * Update the display name 
         * Merged with the course names if any were selected
         */
        this.mergeCourseNames = function (selectedCourses) {

            var courseList = "";

            if (selectedCourses.length === 0) {
                return courseList;
            }

            /**
             * Loop through to get the courses
             */
            angular.forEach(selectedCourses, function (value, index) {
                courseList += value.CourseType;
                if (index !== (selectedCourses.length - 1)) {
                    courseList += ", ";
                }
            });

            return "(" + courseList + ")";

        };

        return {
            mergeName: this.mergeCourseNames,
            getOutstandingAmount: this.getTotalOutstandingAmount
        };

    };


})();