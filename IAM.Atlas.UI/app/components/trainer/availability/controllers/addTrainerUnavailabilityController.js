(function () {

    'use strict';

    angular
        .module('app')
        .controller('AddTrainerUnavailabilityCtrl', AddTrainerUnavailabilityCtrl);

    AddTrainerUnavailabilityCtrl.$inject = ["$scope", "TrainerProfileService", "TrainerAvailabiltyService", "DateFactory"];

    function AddTrainerUnavailabilityCtrl($scope, TrainerProfileService, TrainerAvailabiltyService, DateFactory) {
        
        $scope.trainerAvailabiltyService = TrainerAvailabiltyService;

        $scope.UserId = 1;

        $scope.unavailability = {};
        $scope.unavailability.AllDay = true;
        $scope.unavailability.UpdatedByUserId = $scope.UserId;
        $scope.unavailability.TrainerId = $scope.trainerId;
        $scope.trainer = {};
        $scope.displayStartCalendar = false;
        $scope.displayEndCalendar = false;
        $scope.validationMessage = "";
        $scope.highlightEndDate = false;
        $scope.highlightEndTime = false;
        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.items = ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'];
        
        TrainerProfileService.getTrainerDetails($scope.trainerId)
                .then(function (data) {
                    if (data.length > 0) { // this function returns an array
                        $scope.trainer = data[0];
                    }
                });

        $scope.toggleStartCalendar = function () {
            $scope.displayStartCalendar = !$scope.displayStartCalendar;
        }

        $scope.toggleEndCalendar = function () {
            $scope.displayEndCalendar = !$scope.displayEndCalendar;
        }

        $scope.getToday = function () {
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

        $scope.saveUnavailability = function () {
            $scope.trainerAvailabiltyService.saveUnavailability($scope.unavailability)
                .success(function(data){
                    $scope.getTheUnavailableDays()
                        .then(function (data) {
                            // close the modal
                            $scope.showSuccessFader = true;
                            
                            $('button.close').last().trigger('click');
                        })
                });
        }
        $scope.unavailability.StartDate = $scope.getToday();
        $scope.unavailability.EndDate = $scope.getToday();
        $scope.unavailability.StartTime = "08:00";
        $scope.unavailability.EndTime = "08:00";
        
        $scope.timeChanged = function () {
            if ($scope.unavailability.EndTime < $scope.unavailability.StartTime) {
                $scope.unavailability.EndTime = $scope.unavailability.StartTime;
                $scope.highlightEndTime = true;
            }
            else {
                $scope.highlightEndTime = false;
            }
        }

        $scope.startDateSelected = function () {
            //var startDate = DateFactory.parseDateSlashes($scope.unavailability.StartDate);
            $scope.unavailability.EndDate = $scope.unavailability.StartDate;
            $scope.highlightEndDate = true;
        }

        $scope.endDateSelected = function () {
            var endDate = DateFactory.parseDateSlashes($scope.unavailability.EndDate);
            var startDate = DateFactory.parseDateSlashes($scope.unavailability.StartDate);
            if (startDate > endDate) {
                $scope.unavailability.EndDate = $scope.unavailability.StartDate;
                $scope.highlightEndDate = true;
            }
            else {
                $scope.highlightEndDate = false;
            }
        }

        $scope.parseDate = function (dateString) {
            return DateFactory.parseDateDashes(dateString);
        }

        $scope.formatDate = function (date) {
            return DateFactory.formatDateSlashes(date);
        }

        $scope.allDayChanged = function () {
            if (!$scope.unavailability.AllDay && $scope.unavailability.EndDate != $scope.unavailability.StartDate) {
                $scope.unavailability.EndDate = $scope.unavailability.StartDate;
                $scope.highlightEndDate = true;
            }
        }

        $scope.getHighlightCss = function (showCssClass) {
            return showCssClass ? "highlight" : "";
        }
    }
})();