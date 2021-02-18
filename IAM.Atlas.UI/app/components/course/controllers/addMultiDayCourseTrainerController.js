(function () {

    'use strict';

    angular
        .module('app')
        .controller("AddMultiDayCourseTrainerCtrl", AddMultiDayCourseTrainerCtrl);

    AddMultiDayCourseTrainerCtrl.$inject = ["$scope", "$filter", "CourseTrainerFactory", "CourseTrainerService", "CourseService", "activeUserProfile"];

    function AddMultiDayCourseTrainerCtrl($scope, $filter, CourseTrainerFactory, CourseTrainerService, CourseService, activeUserProfile) {


        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        /**
         * Get the userId from the Active User Profile
         */
        $scope.userId = activeUserProfile.UserId;

        /**
         * Set the Course Id
         */
        $scope.course = $scope.$parent.course;

        /**
        * Set the Session Initial States
        */
        $scope.practicalSession = {
            AM: false,
            PM: false,
            EVE: false,
            Number: $scope.$parent.course.sessionNumber
        };

        $scope.theorySession = {
            AM: false,
            PM: false,
            EVE: false,
            Number: $scope.$parent.course.sessionNumber
        };

        $scope.getSessionNumberBasedOnFlags = function (AM, PM, EVE) {

            if (AM == true && PM == true && EVE == false) {
                return 4; // AM and PM
            }
            else if (AM == false && PM == true && EVE == true) {
                return 5; // PM and EVE
            }
            else if (AM == true && PM == false && EVE == false) {
                return 1; // AM
            }
            else if (AM == false && PM == true && EVE == false) {
                return 2; // PM
            }
            else if (AM == false && PM == false && EVE == true) {
                return 3; // EVE
            }
            else {
                return 0;
            }
        };

        $scope.setSession = function () {
            if ($scope.$parent.course.sessionNumber == 4) {
                $scope.practicalSession.AM = true;
                $scope.practicalSession.PM = true;
                $scope.practicalSession.EVE = false;

                $scope.theorySession.AM = true;
                $scope.theorySession.PM = true;
                $scope.theorySession.EVE = false;

            }
            else if ($scope.$parent.course.sessionNumber == 5) {
                $scope.practicalSession.AM = false;
                $scope.practicalSession.PM = true;
                $scope.practicalSession.EVE = true;

                $scope.theorySession.AM = false;
                $scope.theorySession.PM = true;
                $scope.theorySession.EVE = true;
            }
        };

        /**
         * Set the Session State
         */
        $scope.setSession();

        /**
         * Set the Address and Post Code
         */
        if ($scope.$parent.course.venueLocations) {
            if ($scope.$parent.course.venueLocations.length > 0) {
                $scope.course.venueTitle = $scope.$parent.course.venueLocations[0].Title;
                $scope.course.venueAddress = $scope.$parent.course.venueLocations[0].Address;

                if (!$scope.$parent.course.venueLocations[0].PostCode == false) {
                    $scope.course.venuePostCode = $scope.$parent.course.venueLocations[0].PostCode;
                }
            }
        }

        if (!$scope.$parent.course.courseDateStart == false) {
            $scope.$parent.course.courseDateStartDate = new Date($scope.$parent.course.courseDateStart)
        }

        if (!$scope.$parent.course.courseDateEnd == false) {
            $scope.$parent.course.courseDateEndDate = new Date($scope.$parent.course.courseDateEnd)
        }

        /**
         * Selected Trainers
         */
        $scope.selectedTrainers = [];

        /**
         * Available Trainers
         */
        $scope.availableTrainers = [];

        /**
         * Find the index of the course Type ID
         */
        var courseTypeIndex = CourseTrainerFactory.find($scope.course.courseTypeOptions, $scope.course.courseTypeId);

        /**
         * Set the course type Category
         * and the course type Name as properties on the scope
         */
        if ($scope.course.courseTypeOptions) {
            $scope.courseType = $scope.course.courseTypeOptions[courseTypeIndex]["Title"];
            $scope.courseTypeCategory = $scope.course.courseTypeOptions[courseTypeIndex]["Code"];
        }
        else {
            $scope.courseType = $scope.course.courseType;
            $scope.courseTypeCategory = $scope.course.courseTypeCategory;
        }

        /*
         *  see if coursetype contains the max trainer quotas, if so adjust 
         *
         */
        if ($scope.course.courseType) {
            if ($scope.course.courseType.MaxTheoryTrainers) {
                $scope.course.MaxTheoryTrainers = $scope.course.courseType.MaxTheoryTrainers;
            }
            if ($scope.course.courseType.MaxPracticalTrainers) {
                $scope.course.MaxPracticalTrainers = $scope.course.courseType.MaxPracticalTrainers;
            }
        }

        /*
         *  if sessionNumber is not null get the session detail from the session service
         * 
         */
        if ($scope.course.SessionNumber) {
            CourseService.getTrainingSessions()
                .then(function (data) {
                    $scope.course.courseTrainingSessions = data;
                    var courseSessions = $filter('filter')($scope.course.courseTrainingSessions, { SessionNumber: $scope.course.SessionNumber });
                    if (courseSessions.length > 0) {
                        $scope.course.courseAssociatedSession = courseSessions[0].SessionTitle;
                    }
                }, function (data) {
                    console.log("Can't get the training sessions");
                });
        }


        /**
         * 
         */
        $scope.getSelected = function (updateParent) {

            //CourseTrainerService.getSelectedTrainers($scope.course.courseId, activeUserProfile.selectedOrganisation.Id)
            //    .then(function (response) {
            //        $scope.selectedTrainersForPractical = $filter('filter')(angular.copy(response), { TrainerBookedForPractical: true });
            //        $scope.selectedTrainersForTheory = $filter('filter')(angular.copy(response), { TrainerBookedForTheory: true });

            //        /**
            //         * Pass the data back to the parent scope
            //         */
            //        if (updateParent == true) {
            //            $scope.$parent.course.courseTrainersAndInterpreters = $scope.getCourseAllocatedTrainersAndInterpreters();
            //        }
            //    }, function() {
            //        console.log("Can't get the selected trainers");
            //    });



            CourseTrainerService.getSelectedPracticalTrainers($scope.course.courseId, activeUserProfile.selectedOrganisation.Id)
                .then(function (response) {
                    $scope.selectedTrainersForPractical = response;
                    /**
                     * Pass the data back to the parent scope
                     */
                    if (updateParent == true) {
                        $scope.$parent.course.courseTrainersAndInterpreters = $scope.getCourseAllocatedTrainersAndInterpreters();
                    }
                }, function () {
                    console.log("Can't get the selected trainers");
                });

            CourseTrainerService.getSelectedTheoryTrainers($scope.course.courseId, activeUserProfile.selectedOrganisation.Id)
                .then(function (response) {
                    $scope.selectedTrainersForTheory = response;
                    /**
                     * Pass the data back to the parent scope
                     */
                    if (updateParent == true) {
                        $scope.$parent.course.courseTrainersAndInterpreters = $scope.getCourseAllocatedTrainersAndInterpreters();
                    }
                }, function () {
                    console.log("Can't get the selected trainers");
                });





        };

        /**
         * 
         */
        //$scope.getAvailable = function () {
        //    CourseTrainerService.getAvailableTrainers($scope.course.courseId, activeUserProfile.selectedOrganisation.Id)
        //        .then(function (response) {
        //            $scope.availableTrainersForPractical = $filter('filter')(angular.copy(response), { TrainerForPractical: true, TrainerBookedForPractical: false});
        //            $scope.availableTrainersForTheory = $filter('filter')(angular.copy(response), { TrainerForTheory: true, TrainerBookedForTheory: false });
        //        }, function() {
        //            console.log("Can't get the available trainers");
        //        });
        //};

        $scope.getAvailableTrainersBySession = function () {

            if ($scope.$parent.course.sessionNumber == 4 || $scope.$parent.course.sessionNumber == 5) {

                if ($scope.course.PracticalCourse == true) {

                    $scope.practicalSession.Number = $scope.getSessionNumberBasedOnFlags($scope.practicalSession.AM, $scope.practicalSession.PM, $scope.practicalSession.EVE);

                    if ($scope.practicalSession.Number == 0) {
                        // Nothing Selected, clear out the available
                        $scope.availableTrainersForPractical = [];
                        //$scope.availableTrainersForTheory = [];
                    }
                    else {

                        CourseTrainerService.getAvailableTrainersBySession($scope.course.courseId, activeUserProfile.selectedOrganisation.Id, $scope.practicalSession.Number)
                            .then(function (response) {
                                $scope.availableTrainersForPractical = $filter('filter')(angular.copy(response), { TrainerForPractical: true, TrainerBookedForPractical: false });
                                //$scope.availableTrainersForTheory = $filter('filter')(angular.copy(response), { TrainerForTheory: true, TrainerBookedForTheory: false });
                            }, function () {
                                console.log("Can't get the available trainers");
                            });
                    }

                }
                if ($scope.course.TheoryCourse == true) {

                    $scope.theorySession.Number = $scope.getSessionNumberBasedOnFlags($scope.theorySession.AM, $scope.theorySession.PM, $scope.theorySession.EVE);


                    if ($scope.theorySession.Number == 0) {
                        // Nothing Selected, clear out the available
                        //$scope.availableTrainersForPractical = [];
                        $scope.availableTrainersForTheory = [];
                    }



                    else {

                        CourseTrainerService.getAvailableTrainersBySession($scope.course.courseId, activeUserProfile.selectedOrganisation.Id, $scope.theorySession.Number)
                            .then(function (response) {
                                //$scope.availableTrainersForPractical = $filter('filter')(angular.copy(response), { TrainerForPractical: true, TrainerBookedForPractical: false });
                                $scope.availableTrainersForTheory = $filter('filter')(angular.copy(response), { TrainerForTheory: true, TrainerBookedForTheory: false });
                            }, function () {
                                console.log("Can't get the available trainers");
                            });
                    }
                }

            }
            else {

                CourseTrainerService.getAvailableTrainersBySession($scope.course.courseId, activeUserProfile.selectedOrganisation.Id, $scope.$parent.course.sessionNumber)
                    .then(function (response) {
                        $scope.availableTrainersForPractical = $filter('filter')(angular.copy(response), { TrainerForPractical: true, TrainerBookedForPractical: false });
                        $scope.availableTrainersForTheory = $filter('filter')(angular.copy(response), { TrainerForTheory: true, TrainerBookedForTheory: false });
                    }, function () {
                        console.log("Can't get the available trainers");
                    });
            }


        };

        /**
        * Get the Trainers and Interpreters
        */
        $scope.getCourseAllocatedTrainersAndInterpreters = function () {
            CourseService.getCourseAllocatedTrainersAndInterpreters($scope.course.courseId)
                .then(function (data) {
                    $scope.course.courseTrainersAndInterpreters = data;
                }, function (data) {
                    console.log("Can't get the training sessions");
                });
        }

        /**
         * call the methods
         * getSelected and the getAvailable
         * 
         */
        $scope.getSelected(false);
        //$scope.getAvailable();
        $scope.getAvailableTrainersBySession();


        /**
         * Handles the process once the user is dropped into the new 
         */

        $scope.dropInNewArea = function (from, to, type, AM, PM, EVE) {

            var trainer;

            switch (type) {
                case "availablePractical":
                    trainer = $scope.availablePractical;
                    break;
                case "selectedPractical":
                    trainer = $scope.selectedPractical;
                    break;
                case "availableTheory":
                    trainer = $scope.availableTheory;
                    break;
                case "selectedTheory":
                    trainer = $scope.selectedTheory;
                    break;
            }


            if (type == 'availablePractical') {
                trainer = $scope.availablePractical
            }

            /**
            * If there is no data associated 
            * With the trainer then do nothing further
            */
            if (trainer === null) {
                return false;
            }

            /**
             * Find the index on the object
             * By the trainer ID
             */
            var objectID = CourseTrainerFactory.find($scope[from], trainer.Id);

            /**
             * Check to see if the trainer ID 
             * Exists in the object that it's being moved to
             */
            var trainerExistsInObject = CourseTrainerFactory.find($scope[to], trainer.Id);

            /**
             * If the trainer doesnt exist in the object
             * Add the trainer to the new object
             * Remove the trainer from the old object
             */
            if (trainerExistsInObject === undefined) {
                /**
                 * Add to the new obj
                 */
                $scope[to].push({ Id: trainer.Id, Name: trainer.Name });

                /**
                 * Remove from the current object
                 */
                $scope[from].splice([objectID], 1);

                /**
                 * Call the updateAllocated Trainers method 
                 * Using the Course\TrainerService
                 */

                // Set the Session Number
                var allocatedSessionNumber = 0;
                if ($scope.$parent.course.sessionNumber == 4 || $scope.$parent.course.sessionNumber == 5) {

                    allocatedSessionNumber = $scope.getSessionNumberBasedOnFlags(AM, PM, EVE);
                }
                else {
                    allocatedSessionNumber = $scope.$parent.course.sessionNumber
                }

                CourseTrainerService.updateAllocatedTrainers({
                    "action": to,
                    "from": from,
                    "courseId": $scope.course.courseId,
                    "trainerId": trainer.Id,
                    "userId": $scope.userId,
                    "bookedSessionNumber": allocatedSessionNumber
                })
                    .then(function () {

                        /**
                         * Get the new selected and available lists
                         */
                        $scope.getSelected(true);
                        //$scope.getAvailable();
                        $scope.getAvailableTrainersBySession();

                        $scope.showSuccessFader = true;

                    }, function () {
                        $scope.showErrorFader = true;
                        console.log("Didn't update the user");
                    });

            }

        };

        $scope.setValue = function (trainer, type) {

            // Need to clear out all previous values
            $scope.availablePractical = null;
            $scope.selectedPractical = null;
            $scope.availableTheory = null;
            $scope.selectedTheory = null;

            for (var i = 0; i < $scope.selectedTrainersForPractical.length; i++) {
                if ($scope.selectedTrainersForPractical[i].Id != trainer.Id || type != "selectedPractical") {
                    $scope.selectedTrainersForPractical[i].isSelected = false;
                }
            }

            for (var i = 0; i < $scope.availableTrainersForPractical.length; i++) {
                if ($scope.availableTrainersForPractical[i].Id != trainer.Id || type != "availablePractical") {
                    $scope.availableTrainersForPractical[i].isSelected = false;
                }
            }

            for (var i = 0; i < $scope.selectedTrainersForTheory.length; i++) {
                if ($scope.selectedTrainersForTheory[i].Id != trainer.Id || type != "selectedTheory") {
                    $scope.selectedTrainersForTheory[i].isSelected = false;
                }
            }

            for (var i = 0; i < $scope.availableTrainersForTheory.length; i++) {
                if ($scope.availableTrainersForTheory[i].Id != trainer.Id || type != "availableTheory") {
                    $scope.availableTrainersForTheory[i].isSelected = false;
                }
            }

            trainer.isSelected ? trainer.isSelected = false : trainer.isSelected = true;

            if (trainer.isSelected == true) {
                switch (type) {
                    case "availablePractical":
                        $scope.availablePractical = trainer;
                        break;
                    case "selectedPractical":
                        $scope.selectedPractical = trainer;
                        break;
                    case "availableTheory":
                        $scope.availableTheory = trainer;
                        break;
                    case "selectedTheory":
                        $scope.selectedTheory = trainer;
                        break;
                }
            }

        };


    }

})();