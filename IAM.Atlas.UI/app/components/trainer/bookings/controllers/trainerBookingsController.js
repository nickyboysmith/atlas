(function () {

    'use strict';

    angular
        .module("app")
        .controller("TrainerBookingsCtrl", TrainerBookingsCtrl);

    TrainerBookingsCtrl.$inject = ["$scope", "TrainerBookingsFactory", "CourseTrainerFactory", "TrainerBookingsService", "CourseService", "DateFactory", "ModalService", "activeUserProfile"];

    function TrainerBookingsCtrl($scope, TrainerBookingsFactory, CourseTrainerFactory, TrainerBookingsService, CourseService,  DateFactory, ModalService, activeUserProfile) {

        $scope.bookingState = 'Current';
        $scope.timeTab = '';

        $scope.todaysDate = new Date().toLocaleString('en-GB', {
            weekday: "long",
            year: "numeric",
            month: "short",
            day: "2-digit"
        });

        /**
         * Instantiate the trainer bookings array
         */
        $scope.trainerBookings = [];

        /**
         * Instantiate the Selected Navigation object
         */
        $scope.selectedNavigation = {};
        /**
         * Instantiate the Selected Previous Year object
         */
        $scope.selectedPreviousYear = {};

        /**
         * Create the custom day object
         */
        $scope.custom = TrainerBookingsFactory.customDayCreation();
        $scope.previousThreeYears = TrainerBookingsFactory.previousThreeYears();

        /**
         * Select the current day as the first
         */
        $scope.selectedNavigation = $scope.custom[0];
        $scope.selectedPreviousYear = $scope.previousThreeYears[0];

        /**
         * Change the div based on what was selected
         */
        $scope.changeTheBlock = function (customObject) {
            $scope.selectedNavigation = customObject;
            /**
             * Add the trainer Id to the custom object
             */
            customObject["trainerId"] = activeUserProfile.TrainerId;
            customObject["organisationId"] = activeUserProfile.selectedOrganisation.Id;
            return $scope.getTheTrainerBookings(customObject);
        };

        $scope.changePreviousYear = function (previousYear) {
            $scope.selectedPreviousYear = previousYear;
            /**
             * Add the trainer Id to the custom object
             */
            previousYear["trainerId"] = activeUserProfile.TrainerId;
            previousYear["organisationId"] = activeUserProfile.selectedOrganisation.Id;
            return $scope.getTheTrainerBookings(previousYear);
        };

        /**
         * Convert a date to a readable string
         */
        $scope.convertDateForDisplay = function (date) {
            return DateFactory.convertWebApiDate(date, "/");
        };

        /**
         * Open the course note add modal.
         */
        $scope.openAddNoteModal = function (courseId) {

            /**
             * Add course Id
             * To the scope
             */
            $scope.courseId = courseId;

            /**
            *    Inform the modal that this is from the trainer site
            */
            $scope.trainerSite = true;

            /**
             * Open the modal
             */
            ModalService.displayModal({
                scope: $scope,
                title: "Add Course Note",
                closable: true,
                filePath: "/app/components/course/addNote.html",
                controllerName: "addCourseNoteCtrl",
                cssClass: "trainerBookingAddNoteModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            })

        };

        /**
         * Refresh the course notes
         * For the selected course
         */
        $scope.refreshCourseNotes = function (theCourseId) {
            CourseService.getCourseNotes(theCourseId)
            .then(
                function (response) {
                    /**
                        * Find the array key
                        * Based on the course Id
                        */
                    var arrayKey = CourseTrainerFactory.find($scope.trainerBookings, theCourseId);
                    $scope.trainerBookings[arrayKey].CourseNotes = response.data;
                },
                function (response) {
                    console.log("Failure! Handle error correctly");
                }
            );
        };


        /**
         * Method to call get the trainer bookings
         */
        $scope.getTheTrainerBookings = function (customDateObject) {
            $scope.processing = true;
            $scope.noResults = false;
            TrainerBookingsService.getBookings(customDateObject)
            .then(
                function (response) {
                    $scope.processing = false;
                    $scope.trainerBookings = response.data;
                    if ($scope.trainerBookings.length == 0) {
                        $scope.noResults = true;
                    }
                },
                function (response) {
                    $scope.processing = false;
                }
            );
            // return false so the page doesn't refresh
            return false;
        };

        $scope.selectBookingsState = function (state) {
            $scope.bookingState = state;
        }

        /**
        * Download the Course Register
        */
        $scope.downloadCourseRegister = function (CourseRegisterDocumentId) {
            if (CourseRegisterDocumentId != null) {
                return TrainerBookingsService.DownloadCourseRegister(activeUserProfile.UserId, CourseRegisterDocumentId);
            }
        }

        /**
         * Get todaysBookings
         * Merge Todays data with the trainerId
         * Then get the trainer bookings
         */
        $scope.todaysBookings = angular.extend($scope.custom[0], {
            trainerId: activeUserProfile.TrainerId,
            organisationId: activeUserProfile.selectedOrganisation.Id
        });
        $scope.getTheTrainerBookings($scope.todaysBookings);


    }

})();