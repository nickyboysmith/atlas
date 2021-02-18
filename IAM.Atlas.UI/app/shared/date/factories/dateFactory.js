(function () {

    'use strict';

    angular
        .module('app')
        .factory('DateFactory', DateFactory);
    
    function DateFactory() {
                
        // this function is used to enter a custom date format into the datepicker text field
        // http://myplanet.github.io/angular-date-picker/#usage
        this.parseDateDashes = function (s) {
            var tokens = /^(\d{2})-(\d{2})-(\d{4})$/.exec(s);

            return tokens && new Date(tokens[3], tokens[2] - 1, tokens[1]);
        };

        // this function is used to enter a custom date format into the datepicker text field
        // http://myplanet.github.io/angular-date-picker/#usage
        this.parseDateSlashes = function (s) {
            var tokens = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(s);

            return tokens && new Date(tokens[3], tokens[2] - 1, tokens[1]);
        };

        this.parseDate = function (s) {
            return new Date(Date.parse(s));
        };

        // this function is used to enter a custom date format into the datepicker text field
        //http://myplanet.github.io/angular-date-picker/#usage
        this.formatDateSlashes = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }

            return date && pad(date.getDate()) + '/' + pad(date.getMonth() + 1) + '/' + date.getFullYear();
        };

        this.getTimeString = function (datetime) {
            var hh = datetime.getHours();
            var mm = datetime.getMinutes();
            var padding = "";
            if (mm < 10) padding = "0";
            return hh + ":" + padding + mm;
        }

        this.getTimeStringSeconds = function (datetime) {
            var hh = datetime.getHours();
            var mm = datetime.getMinutes();
            var ss = datetime.getSeconds();
            var mmPadding = "";
            if (mm < 10) mmPadding = "0";
            var ssPadding = "";
            if (ss < 10) ssPadding = "0";
            return hh + ":" + mmPadding + mm + ":" + ssPadding + ss;
        }

        this.formatDateddMONyyyy = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }
            var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
            return date && pad(date.getDate()) + ' ' + months[date.getMonth()] + ' ' + date.getFullYear();
        };

        this.formatDateddMonyyyyDashes = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return date && pad(date.getDate()) + '-' + months[date.getMonth()] + '-' + date.getFullYear();
        };

        this.formatDateyyyyMondd = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return date && date.getFullYear() + ' ' + months[date.getMonth()] + ' ' + pad(date.getDate());
        };

        this.formatDateddMonyyyy = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return date && pad(date.getDate()) + ' ' + months[date.getMonth()] + ' ' + date.getFullYear();
        };

        this.getAYearFromTodaySlashesString = function () {
            var yearFromToday = new Date();
            var dd = yearFromToday.getDate();
            var mm = yearFromToday.getMonth() + 1; //January is 0!
            var yyyy = yearFromToday.getFullYear() + 1;

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            yearFromToday = dd + '/' + mm + '/' + yyyy;
            return yearFromToday;
        }

        this.getTodaySlashesString = function () {
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            today = dd + '/' + mm + '/' + yyyy;
            return today;
        }

        this.getTodayTimeSlashesString = function () {
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            today = dd + '/' + mm + '/' + yyyy;
            return today;
        }

        this.formatDateDashesyyyyMMddString = function (date) {
            var today = new Date();
            var dd = date.getDate();
            var mm = date.getMonth() + 1; //January is 0!
            var yyyy = date.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            date = yyyy + '-' + mm + '-' + dd;
            return date;
        }

        /**
         * Merge this and get slashes string
         * Takes two args date & separator
         */
        this.convertWEBAPIDateToUsableString = function (dateToConvert, separator) {
            var current = new Date(dateToConvert);

            var day = current.getDate();
            var month = current.getMonth() + 1; //January is 0!
            var year = current.getFullYear();

            if (day < 10) {
                day = '0' + day
            }

            if (month < 10) {
                month = '0' + month
            }

            return day + separator + month + separator + year;
        };

        /**
         * 
         */
        this.createCustomMonth = function () {
            var dateOrderObject = {};
            var dayInMilliseconds = 86400000;
            var currentDay = new Date();

            /**
             * Create months of the year 
             * Based on the JS getMonth index
             */
            var monthsOfYear = {
                0: "January",
                1: "Febuary",
                2: "March",
                3: "April",
                4: "May",
                5: "June",
                6: "July",
                7: "August",
                8: "September",
                9: "October",
                10: "November",
                11: "December",
            };

            /**
             * Increment the month by 3
             * Start with the current month we are in
             */
            for (var count = 0; count < 3; count++) {
                var followingMonth = currentDay.setMonth(currentDay.getMonth() + count); // + 1 month 
                var dayOfMonth = 0;

                /**
                 * Check to see which date we
                 * Should start from
                 */
                if (count === 0) {
                    dayOfMonth = currentDay.getDate();
                } else {
                    dayOfMonth = 1;
                }

                /**
                 * create the start date
                 * if we are in a current month the start dat will start from today
                 * 
                 */
                var startDate = new Date(
                    currentDay.getFullYear(),
                    currentDay.getMonth(),
                    dayOfMonth
                )
                .toLocaleDateString();

                /**
                 * Create the last day of the month
                 */
                var endDate = new Date(
                    currentDay.getFullYear(),
                    currentDay.getMonth() + 1,
                    0
                )
                .toLocaleDateString();

                /**
                 * Create object to use
                 * For date selection
                 */
                dateOrderObject[count] = {
                    label: monthsOfYear[currentDay.getMonth()] + " " + currentDay.getFullYear(),
                    date: {
                        is: "between",
                        startDate: startDate,
                        endDate: endDate,
                        index: count + 1
                    }
                };

                // Reset the current day
                currentDay = new Date();

            }

            return dateOrderObject;

        };

        this.formatDatedddmmyyyy = function (date) {

            var dateToFormat = date;

            function pad(n) {
                return n < 10 ? '0' + n : n;
            }

            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

            var day = dateToFormat.slice(0, 2);
            var month = dateToFormat.slice(3, 6);
            var year = dateToFormat.slice(7, 11);

            var monthNumber = months.indexOf(month) + 1;

            return year + pad(monthNumber) + day;
        };

        this.formatDateSlashesWithDayOfWeek = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }

            var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

            var day = days[date.getDay()];

            return day + ', ' + pad(date.getDate()) + '/' + pad(date.getMonth() + 1) + '/' + date.getFullYear();

        };

        return {
            parseDateDashes: this.parseDateDashes,
            parseDateSlashes: this.parseDateSlashes,
            formatDateSlashes: this.formatDateSlashes,
            formatDateddMONyyyy: this.formatDateddMONyyyy,
            parseDate: this.parseDate,
            convertWebApiDate: this.convertWEBAPIDateToUsableString,
            getTodaySlashesString: this.getTodaySlashesString,
            getTodayTimeSlashesString: this.getTodayTimeSlashesString,
            createNextMonth: this.createCustomMonth,
            getTimeString : this.getTimeString,
            getTimeStringSeconds: this.getTimeStringSeconds,
            formatDateddMonyyyyDashes: this.formatDateddMonyyyyDashes,
            formatDatedddmmyyyy: this.formatDatedddmmyyyy,
            formatDateDashesyyyyMMddString: this.formatDateDashesyyyyMMddString,
            formatDateSlashesWithDayOfWeek: this.formatDateSlashesWithDayOfWeek,
            formatDateyyyyMondd: this.formatDateyyyyMondd,
            formatDateddMonyyyy: this.formatDateddMonyyyy
        };
    }

})();