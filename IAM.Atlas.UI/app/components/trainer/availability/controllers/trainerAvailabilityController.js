(function () {

    angular
        .module("app")
        .controller("TrainerAvailabilityCtrl", TrainerAvailabilityCtrl);

    TrainerAvailabilityCtrl.$inject = ["$scope", "TrainerAvailabiltyService", "TrainerAvailabilityFactory", "TrainerProfileService", "ModalService", "activeUserProfile", "DateFactory"];

    function TrainerAvailabilityCtrl($scope, TrainerAvailabiltyService, TrainerAvailabilityFactory, TrainerProfileService, ModalService, activeUserProfile, DateFactory) {


        /**
         * Get user details 
         * from the active user profile 
         */
        $scope.trainerId = activeUserProfile.TrainerId;
        $scope.userId = activeUserProfile.UserId;
        $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;
        $scope.displayStartCalendar = false;
        $scope.displayEndCalendar = false;

        /**
         * Get the trainer settings 
         * from the active user profile 
         */
        if (activeUserProfile.TrainerSettings === undefined || activeUserProfile.TrainerSettings.length === 0) {
            $scope.profileEditing = false;
            $scope.courseTypeEditing = false;
        } else {
            $scope.profileEditing = activeUserProfile.TrainerSettings[0].ProfileEditing;
            $scope.courseTypeEditing = activeUserProfile.TrainerSettings[0].CourseTypeEditing;
        }

        
        /**
         * Default the show past dates to false
         */
        $scope.showUnavailablePastDates = false;

        /**
         * Default the show past courses to false
         */
        $scope.showPastCourses = false;

        /**
         * Create an array of available Days
         */
        $scope.availableDays = [];

        /**
         * Create an array of unavailable days
         */
        $scope.unavailableDates = [];

        $scope.years = [];
        $scope.months = [];

        /**
         * Create array of available course types
         */
        $scope.availableCourseTypes = [];

        /**
         * Create an array of available courses booked
         */
        $scope.availableCoursesBooked = [];

        /**
         * The trainer availability service
         */
        $scope.trainerAvailability = TrainerAvailabiltyService;

        /**
         * The trainer availability factory
         */
        $scope.availabilityFactory = TrainerAvailabilityFactory;

        /**
         * The selceted courtse type to remove
         */
        $scope.selectedTrainerCourseType;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        /**
         * Get the weekdays
         */
        $scope.getTheWeekDays = function () {
            $scope.trainerAvailability.getAvailableWeekDays($scope.trainerId)
            .then(function (response) {
                $scope.availableDays = $scope.availabilityFactory.weekDay(response);
            }, function (response) {
                $scope.availableDays = $scope.availabilityFactory.weekDay(response);
            });
        }

        $scope.setupYearsAndMonths = function () {
            var currentDate = new Date();
            var month = currentDate.getMonth() + 1;
            var year = currentDate.getFullYear();
            $scope.years.push(year);
            for (var j = 0; j < 14; j++) {
                var monthString = "" + month;
                if(month < 10){
                     monthString = "0" + month;
                }
                $scope.months.push(year + "-" + monthString)
                month = month + 1;
                if (month > 12) {
                    month = 1;
                    year = year +1;
                    $scope.years.push(year);
                }
            }
        }

        /**
         * Get the unavailable days
         */
        $scope.getTheUnavailableDays = function () {
            return $scope.trainerAvailability.getUnavailableDays(
                $scope.trainerId,
                +$scope.showUnavailablePastDates
            )
            .then(function (response) {
                $scope.unavailableDates = $scope.availabilityFactory.unAvailableDays(response);
            }, function (response) {
            });
        };

        /**
         * Get the available course types
         */
        $scope.getTheAvailableCourseTypes = function () {
            $scope.trainerAvailability.getCourseTypes($scope.trainerId, $scope.organisationId)
                .then(function (response) {
                    $scope.availableCourseTypes = response;
                }, function(response) {
                    $scope.availableCourseTypes = [];
                });
        };

        /**
         * Get the booked courses
         */
        $scope.getCoursesBooked = function () {
            $scope.trainerAvailability.getCoursesBooked(
                $scope.trainerId,
                +$scope.showPastCourses
            )
            .then(function (response) {
                $scope.availableCoursesBooked = $scope.availabilityFactory.booked(response);
            }, function (response) {
                $scope.availableCoursesBooked = [];
            })
        };

        /**
         * Get the trainer notes from the DB
         */
        TrainerProfileService.getTrainerNotes($scope.trainerId, $scope.userId)
            .then(function (response) {
                /**
                    * Set the notes property on the scope
                    */
                $scope.notes = response;
            }, function () {
                $scope.notes = [];
            });
        



        /**
         * List of available weekdays
         */
        $scope.getTheWeekDays();

        /**
         * List the unavailable days
         */
        $scope.getTheUnavailableDays();

        /**
         * List the available course types
         */
        $scope.getTheAvailableCourseTypes();

        /**
         * List all the course a trainer
         * Has been booked on
         */
        $scope.getCoursesBooked();

        $scope.setupYearsAndMonths();

        /**
         * One click to save to the web api
         * merge the available day data and 
         * the user data
         */
        $scope.changeAvailability = function (theAvailableDay) {

            $scope.trainerAvailability.saveWeekDays(
                angular.extend(
                    theAvailableDay, 
                    {
                        userId: $scope.userId,
                        trainerId: $scope.trainerId
                    })
                )
                .then(function (response) {

                    $scope.showSuccessFader = true;
                   
                    $scope.getTheWeekDays();
                }, function(response) {

                    
                    $scope.showErrorFader = true;

                    console.log(response);
                });
        };

        /**
         * Show the past dates on click
         */
        $scope.showPastDates = function () {
            $scope.getTheUnavailableDays();
        };

        /**
         * Show the past course on click
         */
        $scope.showThePastCourse = function () {
            $scope.getCoursesBooked();
        };

        $scope.addUnavailableDate = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Unavailability",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/trainer/availability/addTrainerUnavailability.html",
                controllerName: "AddTrainerUnavailabilityCtrl",
                cssClass: "addTrainerUnavailability"
            });
        }

        $scope.removeUnavailableDate = function(selectedUnavailableDateId){
            $scope.trainerAvailability.removeUnavailability(selectedUnavailableDateId, $scope.userId)
                .then(function (data) {
                    $scope.getTheUnavailableDays();
                });
        }

        $scope.selectUnavailableDate = function(unavailableDateId){
            if ($scope.selectedUnavailableDateId == unavailableDateId) {
                $scope.selectedUnavailableDateId = -1;
            }
            else {
                $scope.selectedUnavailableDateId = unavailableDateId;
            }
        }


        /**
         * add and update course types using the remove
         */
        $scope.addNewCourseTypes = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Edit Available Trainer Course Types",
                filePath: "/app/components/trainer/availability/updateTrainerCourseTypes.html",
                controllerName: "AvailableTrainerCourseTypesCtrl",
                cssClass: "updateTrainerCourseTypes"
            });
        };

        /**
         * Select the course
         */
        $scope.selectedCourseType = function () {

            /**
             * Check if a different property has been selected
             * if it has 
             * remove class from previous ID
             */
            if ($scope.selectedTrainerCourseType !== this.course.Id) {
                $("#courseType_" + $scope.selectedTrainerCourseType).removeClass("selectedUnavailable");
            }

            /**
             * Set the courseType Id on the scope
             */
            $scope.selectedTrainerCourseType = this.course.Id;

            /**
             * Set the class to highlight the list item
             */
            $("#courseType_" + $scope.selectedTrainerCourseType).addClass("selectedUnavailable");

        };

        /**
         * Remove the course type on click
         */
        $scope.removeTrainerCourseType = function () {

            if ($scope.selectedTrainerCourseType === undefined) {
                console.log("exit the process");
                return false;
            }

            /**
             * Remove the course type
             */
            TrainerAvailabiltyService.updateTrainerCourseTypes({
                action: "remove",
                trainerId: $scope.trainerId,
                trainerCourseTypeCategoryId: $scope.selectedTrainerCourseType,
                userId: $scope.userId
            })
            .then(function (response) {

                $scope.showSuccessFader = true;

                $scope.getTheAvailableCourseTypes();
            }, function (response) {

                $scope.showErrorFader = true;
            });



            /**
             * remove the claass
             */
            $("#courseType_" + $scope.selectedTrainerCourseType).removeClass("selectedUnavailable");


            /**
             * Empty the property
             */
            $scope.selectedTrainerCourseType = undefined;

        };

        $scope.toggleStartCalendar = function () {
            $scope.displayStartCalendar = !$scope.displayStartCalendar;
        }

        $scope.toggleEndCalendar = function () {
            $scope.displayEndCalendar = !$scope.displayEndCalendar;
        }

        $scope.startDateSelected = function () {
            if ($scope.availableBetweenStartDate > $scope.availableBetweenEndDate) {
                var startDate = DateFactory.parseDateSlashes($scope.availableBetweenStartDate);
                var newDate = new Date(startDate.getFullYear(), startDate.getMonth() +1, startDate.getDate());
                $scope.availableBetweenEndDate = DateFactory.formatDateSlashes(newDate);
            }
        }

        $scope.weekend = function(day){
            var isWeekend = false;
            if(day == 'Sunday' || day == 'Saturday'){
                isWeekend = true;
            }
            return isWeekend;
        }

        $scope.saveNote = function() {
            var s = "";
        }
    }

})();