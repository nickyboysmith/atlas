(function () {

    'use strict';

    angular
        .module("app")
        .factory("CourseAttendanceFactory", CourseAttendanceFactory);

    CourseAttendanceFactory.$inject = ["DateFactory"];

    function CourseAttendanceFactory(DateFactory) {

        /**
         * Take the array with ids as the index
         * And create a normal indexed array
         */
        function createNormalArray (object) {
            var normalArray = [];
            /**
             * Loop through the results to sort
             */
            angular.forEach(object, function (value, index) {
                normalArray.push(value);
            });
            return normalArray;
        }

        /**
         * Transform the data
         * To use the way I want it to be used
         */
        this.transformCourseDetail = function (courseDetails) {

            var courseTypes = [];
            var categories = [];
            var courses = [];

            /**
             * Loop through the results to sort the following
             * courseTypes, categories and courses
             */
            angular.forEach(courseDetails, function (value, index) {

                /**
                 * Sort the course types into an array
                 */
                if (courseTypes[value.CourseTypeId] === undefined) {
                    courseTypes[value.CourseTypeId] = {
                        Id: value.CourseTypeId,
                        Name: value.CourseType
                    }
                }

                /**
                 * Sort the course type categories into an array
                 */
                if (
                    categories[value.CourseTypeCategoryId] === undefined &&
                    value.CourseTypeCategoryId !== null
                    )
                {
                    categories[value.CourseTypeCategoryId] = {
                        Id: value.CourseTypeCategoryId,
                        Name: value.CourseTypeCategory
                    }
                }

                /**
                 * Convert dates into readable format
                 */
                var startDate = DateFactory.parseDate(value.StartDate);
                var formattedStartDate = DateFactory.formatDateddMonyyyyDashes(DateFactory.parseDate(value.StartDate));
                var formattedEndendDate = DateFactory.formatDateddMonyyyyDashes(DateFactory.parseDate(value.EndDate))

                /**
                 * Sort the course details into a readable format
                 */
                var courseDisplayName = value.CourseReference + " : " + formattedStartDate;

                /**
                 * Add the course data to the phone
                 */
                courses.push({
                    CourseId: value.CourseId,
                    CourseType: value.CourseType,
                    CourseTypeCategory: value.CourseTypeCategory,
                    CourseReference: value.CourseReference,
                    Venue: value.VenueName,
                    DisplayName: courseDisplayName,
                    Date: formattedStartDate + " to " + formattedEndendDate,
                    DORSNotes: value.DORSNotes,
                    MouseOverMessage: "Venue: " + value.VenueName + ", " + value.NumberOfBookedClients + " Attendees",
                    StartDate: startDate
                });


            });


            return {
                courseTypes: createNormalArray(courseTypes),
                categories: createNormalArray(categories),
                courses: courses
            }

        };

        return {
            transform: this.transformCourseDetail
        }

    }

})();