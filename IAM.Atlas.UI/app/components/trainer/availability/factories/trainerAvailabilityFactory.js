(function () {

    'use strict';

    angular
        .module("app")
        .factory("TrainerAvailabilityFactory", TrainerAvailabilityFactory);

    TrainerAvailabilityFactory.$inject = ["CourseTrainerFactory"];

    function TrainerAvailabilityFactory(CourseTrainerFactory) {

        /**
         * 
         */
        function transformDate(dateToConvert) {
            var theDate = new Date(dateToConvert);
            var year = theDate.getFullYear();
            var month = theDate.getMonth() + 1;
            var day = theDate.getDate() + 1;
            var convertedDate = day + "/" + month + "/" + year;
            return convertedDate;
        }

        /**
         * 
         */
        function transformTime(time) {
            var theDate = new Date(time);
            var hours = theDate.getHours();
            var minutes = theDate.getMinutes();

            if (hours < 12) {
                hours = "0" + hours;
            }

            return hours + ":" + "00";
        }

        /**
         * merges the weekdays from the webapi
         * with the hardcoded values
         * to get the selected checkboxes
         */
        this.weekDayTransform = function (selectedWeekDays) {

            var weekdays = [
                { Id: 1, Day: "Monday", isChecked: false },
                { Id: 2, Day: "Tuesday", isChecked: false },
                { Id: 3, Day: "Wednesday", isChecked: false },
                { Id: 4, Day: "Thursday", isChecked: false },
                { Id: 5, Day: "Friday", isChecked: false },
                { Id: 6, Day: "Saturday", isChecked: false },
                { Id: 7, Day: "Sunday", isChecked: false }
            ];

            angular.forEach(selectedWeekDays, function (value, key) {
                var weekDaysObjectID = CourseTrainerFactory.find(weekdays, value.WeekDayNumber);
                weekdays[weekDaysObjectID]["isChecked"] = true;
                weekdays[weekDaysObjectID]["WebApiID"] = value.Id;
            });

            return weekdays;

        };

        /**
         * Transforms the data into a readable format
         */
        this.unavailableDaysTransform = function (unAvailableDays) {

            var transformedArray = [];

            angular.forEach(unAvailableDays, function (unavailableDay, index) {

                var dateObject = {};

                dateObject["Id"] = unavailableDay.Id;

                /**
                 * Check if the date is on the same day
                 */
                if (unavailableDay.StartDate === unavailableDay.EndDate) {
                    dateObject["Date"] = transformDate(unavailableDay.StartDate);
                }

                /**
                 * Check to see if the unavailable date
                 * is on multiple dates
                 */
                if (unavailableDay.StartDate !== unavailableDay.EndDate) {
                    dateObject["Date"] = 
                        transformDate(unavailableDay.StartDate)
                        + " - "
                        + transformDate(unavailableDay.EndDate);
                }


                /**
                 * If the times aren't both null
                 * then append to the date property
                 */
                if (unavailableDay.TimeStart !== null && unavailableDay.TimeEnd !== null) {
                    var mergedTime = transformTime(unavailableDay.TimeStart) + " till " + transformTime(unavailableDay.TimeEnd);
                    dateObject["Date"] = dateObject["Date"] + " - " + mergedTime;
                }

                transformedArray.push(dateObject);

            });

            return transformedArray;
        };

        /**
         * 
         */
        this.bookedCoursesTransform = function (bookedCourses) {

            var transformedArray = [];

            angular.forEach(bookedCourses, function (course, index) {

                var courseObject = {}

                courseObject["Id"] = course.Id;
                courseObject["CourseId"] = course.CourseId;
                courseObject["Type"] = course.CourseType;
                courseObject["Category"] = course.CourseCategory;

                /**
                 * Check if the date is on the same day
                 */
                if (course.StartDate === course.EndDate) {
                    courseObject["Date"] = transformDate(course.StartDate);
                }

                /**
                 * Check to see if the unavailable date
                 * is on multiple dates
                 */
                if (course.StartDate !== course.EndDate) {
                    courseObject["Date"] =
                        transformDate(course.StartDate)
                        + " - "
                        + transformDate(course.EndDate);
                }

                transformedArray.push(courseObject);

            });
            return transformedArray;
        };


        return {
            weekDay: this.weekDayTransform,
            unAvailableDays: this.unavailableDaysTransform,
            booked: this.bookedCoursesTransform
        };
    }



})();