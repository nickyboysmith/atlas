(function () {

    'use strict';

    angular
        .module("app")
        .factory("TrainerBookingsFactory", TrainerBookingsFactory);

    function TrainerBookingsFactory() {

        /**
         * Create days of the week 
         * Based on the JS getDay index
         */
        var daysOfWeek = {
            0: "Sunday",
            1: "Monday",
            2: "Tuesday",
            3: "Wednesday",
            4: "Thursday",
            5: "Friday",
            6: "Saturday"
        };

        /**
         * Create months of the year 
         * Based on the JS getMonth index
         */
        var monthsOfYear = {
            0:  "Jan",
            1:  "Feb",
            2:  "Mar",
            3:  "Apr",
            4:  "May",
            5:  "Jun",
            6:  "Jul",
            7:  "Aug",
            8:  "Sep",
            9:  "Oct",
            10: "Nov",
            11: "Dec",
        };

        /**
         * Create the object to list 
         * 7 days of the week
         * 3 months
         * 2 years 
         */
        this.createCustomDayFactory = function () {

            var dateOrderObject = {};
            var dayInMilliseconds = 86400000;
            var currentDay = new Date();
            var monthCount = 7;
            var yearCount = 10;

            /**
             * Create the day order
             * Start at the current day and increment at 1
             * Until the we hit 7 days
             */
            for (var count = 0; count < 7; count++)
            {
                var followingDay = new Date(currentDay.getTime() + (dayInMilliseconds * count)); // + 1 day in ms
                /**
                 * Create the object
                 */
                dateOrderObject[count] = {
                    date: followingDay.toLocaleDateString(),
                    name: daysOfWeek[followingDay.getDay()],
                    type: "day"
                };
            }

            /**
             * Increment the month by 3
             * Start with the current month we are in
             */
            for (var count = 0; count < 3; count++)
            {
                var followingMonth = currentDay.setMonth(currentDay.getMonth() + count); // + 1 month 

                dateOrderObject[(count + monthCount)] = {
                    name: monthsOfYear[currentDay.getMonth()],
                    date: new Date(
                        currentDay.getFullYear(),
                        currentDay.getMonth(),
                        1).toLocaleDateString(),
                    type: "month"
                };

                // Reset the current day
                currentDay = new Date();

            }

            /**
             * Increment the year by 2
             * Start with the current year 
             */
            for (var count = 0; count < 2; count++)
            {
                var followingYear = currentDay.setYear(currentDay.getFullYear() + count); // + 1 year

                dateOrderObject[(count + yearCount)] = {
                    name: currentDay.getFullYear(),
                    date: new Date(
                        currentDay.getFullYear(),
                        0,
                        1).toLocaleDateString(),
                    type: "year"
                };
            }

            console.log(dateOrderObject);

            return dateOrderObject;
        };

        /**
         * Create the last 
         * 3 years 
         */
        this.previousThreeYearsFactory = function () {

            var dateOrderObject = {};
            var dayInMilliseconds = 86400000;
            var currentDay = new Date();
            var monthCount = 7;
            var yearCount = 10;
            
            /**
             * Get the last three years
             * Start with the current year 
             */
            for (var count = 1; count < 4; count++) {
                var followingYear = currentDay.setYear(currentDay.getFullYear() - 1);   // - 1 year from our "currentDay" 
                                                                                        //(which is being used to keep track of how far we went back)

                dateOrderObject[(count - 1)] = {
                    name: currentDay.getFullYear(),
                    date: new Date(
                        currentDay.getFullYear(),
                        0,
                        1).toLocaleDateString(),
                    type: "year"
                };
            }

            console.log(dateOrderObject);

            return dateOrderObject;
        };

        return {
            customDayCreation: this.createCustomDayFactory,
            previousThreeYears: this.previousThreeYearsFactory
        };

    };


})();