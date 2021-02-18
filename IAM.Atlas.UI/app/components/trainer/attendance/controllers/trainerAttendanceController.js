(function () {

    'use strict';

    angular
        .module("app")
        .controller("TrainerAttendanceCtrl", TrainerAttendanceCtrl);

    TrainerAttendanceCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "TrainerAttendanceService", "TrainerAttendanceFactory", "CourseService", "DateFactory", "ModalService"];

    function TrainerAttendanceCtrl($scope, $filter, activeUserProfile, TrainerAttendanceService, TrainerAttendanceFactory, CourseService, DateFactory, ModalService) {

        /**
         * Instantitate the show course date property
         */
        $scope.showCourseDate = false;

        /**
         * Show the course field
         */
        $scope.showCourseSelect = false;

        /**
         * Show the course date and time field
         */
        $scope.showDateTimeSelect = false;

        /**
         * Show the course date times property
         */
        $scope.showCourseDateTimes = false;

        /**
         * Show the course details property
         */
        $scope.showCourseDetails = false;

        /**
         * Instantiate the error message property
         */
        $scope.errorMessage = "";

        /**
         * Show the error container
         */
        $scope.showErrorContainer = false;

        /**
         * Instantiate the courseLIST & Options property on the scope
         */
        $scope.courseSelected = {};

        /**
         * Instantiate the courseOptions property on the scope
         */
        $scope.courseListOptions = {};

        /**
         * Instantiate the courseDateOptions property on the scope
         */
        $scope.courseDateOptions = {};

        /**
         * Show and hide the datepicker based on a click
         */
        $scope.showDatePicker = function () {
            if ($scope.showCourseDate) {
                $scope.showCourseDate = false;
                return false;
            }
            $scope.showCourseDate = true;
        }

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy');
        }

        /**
         * On selected 
         * The call web api and then show course field
         */
        $scope.getAttendanceForCourseDate = function () {

            /**
             * Hide possible open fields
             */
            $scope.showCourseSelect = false;
            $scope.showCourseDateTimes = false;
            $scope.showCourseDetails = false;
            $scope.showErrorContainer = false;

            /**
             * Close the show course date div
             */
            $scope.showCourseDate = false;

            /**
             * Call the web api
             */
            TrainerAttendanceService.getTrainerAttendance({
                trainerId: activeUserProfile.TrainerId,
                userId: activeUserProfile.UserId,
                organisationId: activeUserProfile.selectedOrganisation.Id,
                date: $scope.courseDate
            })
            .then(
                function (response) {

                    /**
                     * Show the course field
                     */
                    $scope.showCourseSelect = true;

                    /**
                     * On success
                     * Populate the course select box
                     */
                    $scope.courseListOptions = TrainerAttendanceFactory.transform(response.data);

                },
                function (reason) {
                    $scope.errorMessage = reason;
                    $scope.showErrorContainer = true;
                }
            );

        };

        /**
         * Select the course and populate the dropdown lists 
         */
        $scope.selectCourse = function () {


            $scope.showCourseDateTimes = false;
            $scope.showCourseDetails = false;
            $scope.showErrorContainer = false;

            var hasCourses = $scope.courseListOptions["courseList"].length;
            if (hasCourses !== 0 && $scope.courseSelected !== null) {
                /**
                 * Show the course field
                 */
                $scope.showCourseDateTimes = true;

                /**
                 * Populate times
                 */
                $scope.courseDateOptions = $scope.courseListOptions["courseList"][$scope.courseSelected.Id]["Courses"];
            }
            else if (hasCourses !== 0 && $scope.courseSelected === null) {
                $scope.errorMessage = "Please select a course";
                $scope.showErrorContainer = true;
            }
            else {
                $scope.errorMessage = "There are no courses";
                $scope.showErrorContainer = true;
            }

        };

        /**
         * 
         */
        $scope.showTrainerAttendanceData = function () {
            //console.log($event);
            $scope.showCourseDetails = false;
            $scope.showErrorContainer = false;
            if ($scope.courseDateSelected === null) {
                $scope.errorMessage = "Please select a course start time";
                $scope.showErrorContainer = true;
            }
            else {

                $scope.courseDetails = $scope.courseDateSelected[0];
                $scope.showCourseDetails = true;
                CourseService.getCourseNotes($scope.courseDetails.CourseId)
                .then(
                    function (response) {
                        $scope.courseNotes = response;
                    },
                    function (reason) {
                        $scope.errorMessage = reason;
                        $scope.showErrorContainer = true;
                    }
                );
            }

            /**
             * 
             */
        };

        /**
         * Convert a date to a readable string
         */
        $scope.convertDateForDisplay = function (date) {
            return DateFactory.convertWebApiDate(date, "/");
        };

        /**
         * Update the client object 
         * With the new checkbox value
         * Onto a copy of the object
         */
        $scope.updateClientList = function (index, inputValue) {
            if (inputValue === undefined) {
                inputValue = false;
            }
            $scope.courseDetails.ClientList[index].DidClientAttend = inputValue;
        };

        /**
         * Update the trainer object 
         * With the new checkbox value
         * Onto a copy of the object
         */
        $scope.updateTrainerList = function (index, inputValue) {
            if (inputValue === undefined) {
                inputValue = false;
            }
            $scope.courseDetails.TrainerList[index].IsTrainerAttending = inputValue;
        };

        /**
         * Save the current attendance list
         */
        $scope.saveAttendanceList = function () {

            var updatedCourseDetails = angular.extend($scope.courseDetails, {
                trainerId: activeUserProfile.TrainerId,
                userId: activeUserProfile.UserId,
                organisationId: activeUserProfile.selectedOrganisation.Id,
            });


            /**
             * Call the service
             */
            TrainerAttendanceService.saveTrainerAttendance(updatedCourseDetails)
            .then(
                function (response) {
                    $scope.courseSelectedCopyId = $scope.courseSelected.Id;
                    $scope.courseListOptions = $scope.rePopulateCourseListOptions(response.data);
                    var categoryIndex = TrainerAttendanceFactory.getCategoryIndex($scope.courseListOptions["categories"], $scope.courseSelectedCopyId);
                    $scope.courseSelected = $scope.courseListOptions["categories"][categoryIndex];
                    $scope.completedMessage = "Details have been updated"; // Remove once the message fader has been implemented.
                },
                function (reason) {
                    $scope.errorMessage = reason;
                    $scope.showErrorContainer = true;
                }
            );
        };

        /**
         * Get the attendance data
         */
        $scope.rePopulateCourseListOptions = function (attendance) {
            return TrainerAttendanceFactory.transform(attendance);
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
                    $scope.courseNotes = response.data;
                },
                function (response) {
                    console.log("Failure! Handle error correctly");
                }
            );
        };


    }

})();