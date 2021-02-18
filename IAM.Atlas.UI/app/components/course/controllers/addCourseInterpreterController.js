(function () {

    'use strict';

    angular
        .module('app')
        .controller("AddCourseInterpreterCtrl", AddCourseInterpreterCtrl);

    AddCourseInterpreterCtrl.$inject = ["$scope", "$filter", "CourseInterpreterFactory", "CourseInterpreterService", "CourseService", "activeUserProfile"];

    function AddCourseInterpreterCtrl($scope, $filter, CourseInterpreterFactory, CourseInterpreterService, CourseService, activeUserProfile) {


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
            $scope.$parent.course.courseDateStartDate = $scope.$parent.course.courseDateStart
        }

        if (!$scope.$parent.course.courseDateEnd == false) {
            $scope.$parent.course.courseDateEndDate = $scope.$parent.course.courseDateEnd
        }

        /**
         * Selected Interpreters
         */
        $scope.selectedInterpreters = [];

        /**
         * Available Interpreters
         */
        $scope.availableInterpreters = [];

        /**
         * Find the index of the course Type ID
         */
        var courseTypeIndex = CourseInterpreterFactory.find($scope.course.courseTypeOptions, $scope.course.courseTypeId);

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
            CourseInterpreterService.getSelectedInterpreters($scope.course.courseId, activeUserProfile.selectedOrganisation.Id)
                .then(function (response) {
                    $scope.selectedInterpretersForPractical = $filter('filter')(angular.copy(response), { InterpreterBookedForPractical: true });
                    $scope.selectedInterpretersForTheory = $filter('filter')(angular.copy(response), { InterpreterBookedForTheory: true });

                    /**
                     * Pass the data back to the parent scope
                     */
                    if (updateParent == true) {
                        $scope.$parent.course.coursTrainersAndInterpreters = $scope.getCourseAllocatedTrainersAndInterpreters();
                    }
                }, function() {
                    console.log("Can't get the selected Interpreters");
                });
        };

        /**
         * 
         */
        $scope.getAvailable = function () {
            CourseInterpreterService.getAvailableInterpreters($scope.course.courseId, activeUserProfile.selectedOrganisation.Id)
                .then(function (response) {
                    //$scope.availableInterpretersForPractical = $filter('filter')(angular.copy(response), { InterpreterBookedForPractical: false });
                    //$scope.availableInterpretersForTheory = $filter('filter')(angular.copy(response), { InterpreterBookedForTheory: false });
                    $scope.availableInterpretersForPractical = $filter('filter')(angular.copy(response));
                    $scope.availableInterpretersForTheory = $filter('filter')(angular.copy(response));
                }, function() {
                    console.log("Can't get the available Interpreters");
                });
        };


        /**
        * Get the Trainers and Interpreters
        */
        $scope.getCourseAllocatedTrainersAndInterpreters = function() {
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
        $scope.getAvailable();


        /**
         * Handles the process once the user is dropped into the new 
         */
        $scope.dropInNewArea = function (from, to, type) {

            var Interpreter;

            switch (type) {
                case "availablePractical":
                    Interpreter = $scope.availablePractical;
                    break;
                case "selectedPractical":
                    Interpreter = $scope.selectedPractical;
                    break;
                case "availableTheory":
                    Interpreter = $scope.availableTheory;
                    break;
                case "selectedTheory":
                    Interpreter = $scope.selectedTheory;
                    break;
            }


            if (type == 'availablePractical') {
                Interpreter = $scope.availablePractical
            }

            /**
            * If there is no data associated 
            * With the Interpreter then do nothing further
            */
            if (Interpreter === null) {
                return false;
            }

            /**
             * Find the index on the object
             * By the Interpreter ID
             */
            var objectID = CourseInterpreterFactory.find($scope[from], Interpreter.Id);

            /**
             * Check to see if the Interpreter ID 
             * Exists in the object that it's being moved to
             */
            var InterpreterExistsInObject = CourseInterpreterFactory.find($scope[to], Interpreter.Id);

            /**
             * If the Interpreter doesnt exist in the object
             * Add the Interpreter to the new object
             * Remove the Interpreter from the old object
             */
            if (InterpreterExistsInObject === undefined) {
                /**
                 * Add to the new obj
                 */
                $scope[to].push({ Id: Interpreter.Id, Name: Interpreter.Name, InterpreterLanguageList: Interpreter.InterpreterLanguageList });

                /**
                 * Remove from the current object
                 */
                $scope[from].splice([objectID], 1);

                /**
                 * Call the updateAllocated Interpreters method 
                 * Using the Course\InterpreterService
                 */
                CourseInterpreterService.updateAllocatedInterpreters({
                    "action": to,
                    "from": from,
                    "courseId": $scope.course.courseId,
                    "InterpreterId": Interpreter.Id,
                    "userId": $scope.userId
                })
               .then(function () {

                   /**
                    * Get the new selected and available lists
                    */
                   $scope.getSelected(true);
                   $scope.getAvailable();

                   $scope.showSuccessFader = true;

               }, function () {


                   $scope.showErrorFader = true;
                   console.log("Didn't update the user");
               });

            }

        };

        $scope.setValue = function (Interpreter, type) {

            // Need to clear out all previous values
            $scope.availablePractical = null;
            $scope.selectedPractical = null;
            $scope.availableTheory = null;
            $scope.selectedTheory = null;

            for (var i = 0 ; i < $scope.selectedInterpretersForPractical.length ; i++) {
                if ($scope.selectedInterpretersForPractical[i].Id != Interpreter.Id || type != "selectedPractical") {
                    $scope.selectedInterpretersForPractical[i].isSelected = false;
                }
            }

            for (var i = 0 ; i < $scope.availableInterpretersForPractical.length ; i++) {
                if ($scope.availableInterpretersForPractical[i].Id != Interpreter.Id || type != "availablePractical") {
                    $scope.availableInterpretersForPractical[i].isSelected = false;
                }
            }

            for (var i = 0 ; i < $scope.selectedInterpretersForTheory.length ; i++) {
                if ($scope.selectedInterpretersForTheory[i].Id != Interpreter.Id || type != "selectedTheory") {
                    $scope.selectedInterpretersForTheory[i].isSelected = false;
                }
            }

            for (var i = 0 ; i < $scope.availableInterpretersForTheory.length ; i++) {
                if ($scope.availableInterpretersForTheory[i].Id != Interpreter.Id || type != "availableTheory") {
                    $scope.availableInterpretersForTheory[i].isSelected = false;
                }
            }

            Interpreter.isSelected ? Interpreter.isSelected = false : Interpreter.isSelected = true;

            if (Interpreter.isSelected == true) {
                switch (type) {
                    case "availablePractical":
                        $scope.availablePractical = Interpreter;
                        break;
                    case "selectedPractical":
                        $scope.selectedPractical = Interpreter;
                        break;
                    case "availableTheory":
                        $scope.availableTheory = Interpreter;
                        break;
                    case "selectedTheory":
                        $scope.selectedTheory = Interpreter;
                        break;
                }
            }
        };

    }

})();