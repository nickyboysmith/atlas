(function () {

    'use strict';

    angular
        .module("app")
            .controller("CourseTrainersCtrl", CourseTrainersCtrl);

    CourseTrainersCtrl.$inject = ["$scope", "$filter", "CourseTrainersService", "CourseTrainerService", "ModalService", "UserService", "activeUserProfile", "CourseTypeService", "CourseTypeCategoryService", "CourseTypeFactory", "DateFactory"];

    function CourseTrainersCtrl($scope, $filter, CourseTrainersService, CourseTrainerService, ModalService, UserService, activeUserProfile, CourseTypeService, CourseTypeCategoryService, CourseTypeFactory, DateFactory) {

        $scope.modalService = ModalService;
        $scope.courseTypeService = CourseTypeService;
        $scope.courseTypeFactory = CourseTypeFactory;
        $scope.selectedCourseType = {};
        $scope.selectedCourseTypeObject = {};
        $scope.selectedCourseTypeCategory = {};
        $scope.userService = UserService;
        $scope.courseTypeCategoryService = CourseTypeCategoryService;
        $scope.courseTypeCategories = {};
        $scope.fromDate = DateFactory.formatDateddMONyyyy(new Date());
        $scope.toDate = DateFactory.formatDateddMONyyyy(new Date());//DateFactory.formatDateddMONyyyy((new Date()).setMonth((new Date()).getMonth() + 1));

        $scope.displayCalendar = false;
        $scope.displayCalendar2 = false;
        $scope.courseTrainersService = CourseTrainersService;
        $scope.courseTrainerService = CourseTrainerService;
        $scope.courses = {};
        $scope.coursesCollection = {};
        $scope.noTrainersAllocated = false;

        $scope.userId = activeUserProfile.UserId;

        $scope.loadOrganisations = function (userId) {

            $scope.userService.checkSystemAdminUser(userId)

                   .then(function (response) {

                       $scope.isAdmin = JSON.parse(response);

                       $scope.userService.getOrganisationIds(userId)

                           .then(function (response) {

                               $scope.relatedOrganisations = response;

                               if ($scope.isAdmin == true) {
                                   $scope.hideCourseTypeTable = true;
                               }
                               else {

                                   /**
                                   * Set course type input as disabled
                                   */
                                   $("#courseTypeInput").prop("disabled", true);

                                   /**
                                    * Show the add new button now an organisation has been selected.
                                    */
                                   $scope.hideAddNewOnStart = false;

                                   $scope.associatedOrganisationId = $scope.relatedOrganisations[0].id;

                                   $scope.courseTypeService.getCourseTypes($scope.associatedOrganisationId).then(function (response) {
                                       $scope.courseTypeCollection = response;
                                   });
                                   $scope.hideOrganisationList = true;

                               }
                           }, function (data, status) {
                       });
                   }, function (data, status) {
           });
        }

        $scope.loadOrganisations($scope.userId);

        $scope.selectedToDate = function (selectedDate) {
            $scope.toDate = selectedDate;
        }

        $scope.selectedFromDate = function (selectedDate) {
            $scope.fromDate = selectedDate;
        }

        /**
         * Select organisation
         */
        $scope.selectTheOrganisation = function (organisationId) {

            /**
             * Show the add new button now an organisation has been selected.
             */
            $scope.hideAddNewOnStart = false;
            $scope.selectedOrganisation = organisationId;
            $scope.courseTypeService.getCourseTypes($scope.selectedOrganisation).then(function (response) {
                $scope.courseTypeCollection = response;
            });
            $scope.hideCourseTypeTable = false;
        };


        /**
         * Select the course type the and then add to the page
         */
        $scope.selectTheCourseType = function (courseType) {

            $scope.selectedCourseType = courseType;

            if ($scope.courseTypeCollection.length > 0) {
                var selectedCourseTypeArray = $filter('filter')($scope.courseTypeCollection, { Id: $scope.selectedCourseType });
                if (selectedCourseTypeArray.length > 0) {
                    $scope.selectedCourseTypeObject = selectedCourseTypeArray[0];
                }
            }

            $scope.hideOnStart = false;

            if ($scope.isAdmin === false) {
                $("#courseTypeInput").prop("disabled", true);
            }

            $scope.disabledStatus = courseType.Disabled;
            $scope.disabledMessage = $scope.courseTypeFactory.getDisabledMessage($scope.disabledStatus);
            $scope.courseTypeCategoryService.showCourseTypeCategories(courseType, $scope.userId)
            .then(
                    function successCall(response) {
                        $scope.courseTypeCategories = response.data;
                    }
                    ,
                    function failCall(response) {
                    }
            );
        };

        $scope.selectTheCategory = function (selectedCategory) {

            $scope.selectedCourseTypeCategory = selectedCategory;

            //$scope.hideOnStart = false;

            //if ($scope.isAdmin === false) {
            //    $("#courseTypeInput").prop("disabled", true);
            //}

            //$scope.searchCriteria = {};
            //$scope.searchCriteria.organisationId = $scope.selectedOrganisation;
            //$scope.searchCriteria.courseTypeId = $scope.selectedCourseType;
            //$scope.searchCriteria.courseTypeCategoryId = $scope.selectedCourseTypeCategory;
            //$scope.searchCriteria.fromDate = $scope.fromDate;
            //$scope.searchCriteria.toDate = $scope.toDate;

            ////$scope.disabledStatus = courseType.Disabled;
            ////$scope.disabledMessage = $scope.courseTypeFactory.getDisabledMessage($scope.disabledStatus);
            //$scope.courseTrainerService.getCourses($scope.searchCriteria)
            //.then(
            //        function successCall(response) {
            //            $scope.courses = response.data;
            //        }
            //        ,
            //        function failCall(response) {
            //        }
            //);
        };

        $scope.selectTheCourse = function (course) {
            $scope.selectedCourse = course;
            $scope.courseStarted = course.started;
            $scope.courseTrainerService.getSelectedTrainers(course.Id, $scope.selectedOrganisation)
            .then(
                    function (data) {
                        $scope.trainers = data;
                    }
                    ,
                    function (data) {
                    }
            );
        }

        $scope.addCourseTrainer = function (courseData) {

            /**
             * Set the course data 
             * as a property on the scope
             */
            $scope.course = courseData;
            $scope.course.courseId = courseData.Id;

            $scope.course.courseDateStart = $scope.course.startDate;
            $scope.course.courseDateEnd = $scope.course.endDate;
            $scope.course.courseReference = $scope.course.reference;
            $scope.course.venueTitle = $scope.course.venue;

            if ($scope.selectedCourseTypeObject) {
                //$scope.course.courseType = {};
                $scope.course.MaxPracticalTrainers = $scope.selectedCourseTypeObject.MaxPracticalTrainers;
                $scope.course.MaxTheoryTrainers = $scope.selectedCourseTypeObject.MaxTheoryTrainers;
            }

            /**
             * Fire the modal
             * With the buttons object
             * Adds close button to the object
             */
            ModalService.displayModal({
                scope: $scope,
                title: "Update Course Trainers",
                cssClass: "addCourseTrainerModal",
                filePath: "/app/components/course/addCourseTrainer.html",
                controllerName: "AddCourseTrainerCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };

        $scope.resetDate = function () {
            $scope.fromDate = new Date();
            $scope.toDate = new Date();
            $scope.toDate.setMonth($scope.toDate.getMonth() + 1);
        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
            if ($scope.displayCalendar) {
                $scope.displayCalendar2 = false;
            }
        }

        $scope.toggleCalendar2 = function () {
            $scope.displayCalendar2 = !$scope.displayCalendar2;
            if ($scope.displayCalendar2) {
                $scope.displayCalendar = false;
            }
        }

        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }

        $scope.changeTrainersAllocated = function (val) {
            $scope.noTrainersAllocated = val;
        }

        $scope.zeroNullTrainerCount = function (trainerCount) {
            var zeroedCount = trainerCount;
            if (!trainerCount) {
                zeroedCount = 0;
            }
            return zeroedCount;
        }

        $scope.searchForCourses = function () {
            $scope.validationMessage = "";
            if ($scope.selectedCourseType > 0) {
                $scope.completedMessage == '';
                $scope.searchCriteria = {};
                $scope.searchCriteria.organisationId = $scope.selectedOrganisation;
                $scope.searchCriteria.courseTypeId = $scope.selectedCourseType;
                $scope.searchCriteria.courseTypeCategoryId = $scope.selectedCourseTypeCategory;
                $scope.searchCriteria.fromDate = String($scope.fromDate);
                $scope.searchCriteria.toDate = String($scope.toDate);
                $scope.searchCriteria.noTrainersAllocated = $scope.noTrainersAllocated;

                $scope.courseTrainersService.getCourses($scope.searchCriteria)
                .then(
                        function (data) {
                            $scope.courses = data;
                            $scope.coursesCollection = $scope.courses;
                            if (!data.length > 0) {
                                $scope.completedMessage == 'No Results Found.';
                            }
                        }
                        ,
                        function (data) {
                        }
                );
            }
            else {
                $scope.validationMessage = "Please pick a course type.";
            }
        }
    }
})();