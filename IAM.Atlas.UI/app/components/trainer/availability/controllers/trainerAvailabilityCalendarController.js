(function () {

    angular
        .module("app")
        .controller("TrainerAvailabilityCalendarCtrl", TrainerAvailabilityCalendarCtrl);

    TrainerAvailabilityCalendarCtrl.$inject = ["$scope", "TrainerAvailabiltyService", "TrainerAvailabilityFactory", "TrainerProfileService", "ModalService", "activeUserProfile", "DateFactory"];

    function TrainerAvailabilityCalendarCtrl($scope, TrainerAvailabiltyService, TrainerAvailabilityFactory, TrainerProfileService, ModalService, activeUserProfile, DateFactory) {

        $scope.calendarRows = [];
        $scope.trainerId;
        $scope.month;
        $scope.year;
        $scope.years = [];
        $scope.currentMonth;
        $scope.loading = false;
        $scope.displayingMonth;
        $scope.displayingYear;

        $scope.initialiseMonthYears = function () {
            var currentDate = new Date();
            var mm = currentDate.getMonth() + 1; //January is 0!
            $scope.currentMonth = mm;
            var yyyy = currentDate.getFullYear();
            $scope.month = "" + mm;
            $scope.year = "" + yyyy;
            $scope.years = [$scope.year, ("" + (yyyy + 1))];
            $scope.diplayingMonth = mm;
            $scope.displayingYear = yyyy;
        }

        $scope.loadCalendar = function () {
            if ($scope.trainerId && $scope.month && $scope.year) {
                $scope.loading = true;
                $scope.displayingMonth = $scope.month;
                $scope.displayingYear = $scope.year;
                $scope.calendarRows = [];
                TrainerAvailabiltyService.getAvailabilityByMonth($scope.trainerId, $scope.month, $scope.year)
                .then(
                    function successCallback(response) {
                        $scope.calendarRows = response.data;
                        $scope.loading = false;
                    },
                    function errorCallback(response) {

                    }
                );
            }
        }

        $scope.changedMonth = function (month) {
            $scope.month = month;
            $scope.loadCalendar();
        }

        $scope.changedYear = function (year) {
            $scope.year = year;
            $scope.loadCalendar();
        }

        $scope.formatDate = function (datetime) {
            return DateFactory.formatDateSlashes(DateFactory.parseDate(datetime));
        }

        $scope.previousMonth = function (datetime) {
            var previousMonth = false;
            var date = DateFactory.parseDate(datetime);
            var month = date.getMonth() + 1; //January is 0!
            if (month < $scope.month) {
                previousMonth = true;
            }
            return previousMonth;
        }

        $scope.displayMonthYear = function () {
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
            return monthsOfYear[parseInt($scope.displayingMonth - 1)] + " " + $scope.displayingYear;
        }

        $scope.nextMonth = function (datetime) {
            var nextMonth = false;
            var date = DateFactory.parseDate(datetime);
            var month = date.getMonth() + 1; //January is 0!
            if (month > $scope.month) {
                nextMonth = true;
            }
            return nextMonth;
        }

        $scope.ParseBool = function (bool) {
            var parsedBool = false;
            if (bool) {
                parsedBool = bool;
            }
            return parsedBool;
        }

        $scope.AvailabilityChanged = function (checked, date, sessionNumber) {
            TrainerAvailabiltyService.updateAvailability($scope.trainerId, checked, date, sessionNumber)
            .then(
                function successCallback(response) {
                    if (response.data) {
                        if (response.data == false) {
                            $scope.statusMessage = "Availability for " + date + ", Session " + sessionNumber + " not updated.";
                        }
                    }
                },
                function errorCallback(response) {

                }
            );
        }

        $scope.initialiseMonthYears();
        $scope.loadCalendar();
    }

})();