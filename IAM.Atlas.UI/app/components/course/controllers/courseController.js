(function () {

    'use strict';


    angular
    .module("app.controllers")
    .controller("CourseCtrl", CourseCtrl);


    CourseCtrl.$inject = ["$scope", "AtlasCookieFactory", "CourseService", "ModalService", "$compile", 'activeUserProfile', "DateFactory"];


    function CourseCtrl($scope, AtlasCookieFactory, CourseService, ModalService, $compile, activeUserProfile, DateFactory) {

        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;

        /**
         * Getting the userId from the active object
         */
        console.log(activeUserProfile);
        $scope.userId = activeUserProfile.UserId;
        $scope.baseScreenId = "CourseSearchTester";

        /**
        * Organisation Id 
        * Comes from the active User Object
        */
        $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        /**
         * Set the scope.results object
         */
        $scope.results = {};

        /*
         * Set the scope.searches object
         */
        $scope.searches = {};

        /**
         * Put Course service on the scope
         */
        $scope.courseService = CourseService;

        $scope.modalService = ModalService;

        $scope.courseAvailabilityMessageContent = "";

        /**
        * 
        */
        $scope.courseCollection = [];

        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }
        /**
         * Call the method to pull the searches from the DB
         */
        $scope.courseService.getPreviousSearches($scope.baseScreenId, $scope.userId)
            .then(function (data) {
                var transformation = $scope.courseService.transformSearchData(data);
                $scope.searches = transformation.searches;

                // Results
                $scope.results = transformation.results;
            }, function () {
                console.log("There has been an error, getting the previous searches");
            });

        /**
         * Get related Course Types
         */
        $scope.courseService.getRelatedCourseTypes($scope.organisationId)
            .then(
                function (data) {
                    $scope.courseTypes = data;
                },
                function (reason) {
                    console.log(reason);
                }
            );

        /**
         * Get the Venues associated with the organisation
         */
        $scope.courseService.getRelatedVenues($scope.organisationId)
             .then(function (data) {
                 $scope.relatedVenues = data;
             }, function (data) {
                 console.log("Can't get related venues");
             });

        /**
         * 
         */
        //$scope.course = {
        //    venue: "*",
        //    searchDates: "*",
        //    type: "*"
        //};
        // refactoring the commented out code above to not lose the course.clients
        if ($scope.course === null || $scope.course === undefined) $scope.course = {};
        $scope.course.venue = "*";
        $scope.course.searchDates = "*";
        $scope.course.type = "*";
        $scope.course.futureCoursesOnly = true;

        //var maxRowsCookie = AtlasCookieFactory.getCookie("maxRows");
        //if (maxRowsCookie !== false) {
        //    $scope.course.maxRows = maxRowsCookie;
        //}

        $scope.course.maxRows = AtlasCookieFactory.getCookie("maxRows");
        if ($scope.course.maxRows == undefined || !$scope.course.maxRows) $scope.course.maxRows = 200;

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        };

        $scope.viewTrainerSearchModal = function () {

            //$scope.displayModal({
            //    theClass: "courseAddModal",
            //    title: "Add course",
            //    theController: "saveCourseCtrl",
            //    filePath: "/app/components/course/save.html"
            //});

            $scope.displayModal({
                theClass: "clientAddNoteModal",
                title: "Trainer Administration",
                theController: "trainerSearchCtrl",
                filePath: "/app/components/trainer/search/view.html"
            });
        };

        $scope.viewUserSearchModal = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "User Administration",
                cssClass: "userSearchModal",
                filePath: "/app/components/users/userSearch.html",
                controllerName: "UsersCtrl"
            });
        };


        /**
         * Method to display modal with predefined options
         */
        $scope.displayModal = function (modalOptions) {
            BootstrapDialog.show({
                scope: $scope,
                title: modalOptions.title,
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                cssClass: modalOptions.theClass,
                message: function (dialog) {
                    var pageToLoad = dialog.getData('pageToLoad');
                    return $compile('<div ng-app="app" ng-controller="' + modalOptions.theController + '" ng-include="\'' + pageToLoad + '\'"></div>')($scope);
                },
                data: {
                    'pageToLoad': modalOptions.filePath,
                }
            });
        };

        /**
        * Method to display modal with predefined options
        */
        $scope.showModal = function (scope, title, cssClass, filePath, controllerName) {
            $scope.modalService.displayModal({
                scope: scope,
                title: title,
                cssClass: cssClass,
                filePath: filePath,
                controllerName: controllerName
            });
        };

        /**
          * Open the course view in a modal when clicked
          */

        $scope.courseViewPage = function (courseId, index) {

            $scope.courseId = courseId;
            $scope.courseIndex = index;

            $scope.modalService.displayModal({
                scope: $scope,
                title: "View course",
                cssClass: "courseViewModal",
                filePath: "/app/components/course/edit.html",
                controllerName: "editCourseCtrl",
            });
        };

        $scope.courseCollection = [];

        /**
         * Functions for the course locked hover message
         */
        $scope.showHoverMessage = function (elementID, cancelledStatus) {

            if (cancelledStatus == "cancelled") {
                $scope.courseAvailabilityMessageContent = "This Course was Cancelled.";

                var rowElement = $("#courseSearchResult_" + elementID)
                $scope.rowID = rowElement.position();

                $scope.courseAvailiabiltyMessageMargin = $scope.rowID.top + "px";
                $scope.courseAvailiabiltyMessageWidth = rowElement.width() + "px";
                $scope.courseAvailiabiltyMessageHeight = rowElement.height() + "px";
                $scope.courseAvailiabiltyMessage = true;
            }

            if (cancelledStatus == "non-cancelled") {
                return;
            }            
        };

        $scope.disableFutureCourseCheckbox = function () {
            $scope.course.futureCoursesOnly = false;
        }


        /**
         * 
         */
        $scope.searchCourses = function () {

            $scope.formValidation = $scope.theCourseSearch.$valid;
            AtlasCookieFactory.createCookie("maxRows", $scope.course.maxRows, { expires: 18 });

            if ($scope.formValidation) {

                $scope.processing = true;
                $scope.noResults = false;
                $scope.course.searchDisplay = true;

                $scope.details = {};

                $scope.details.userId = $scope.userId;
                $scope.details.organisationId = $scope.organisationId;
                $scope.details.screenId = $scope.baseScreenId;
                $scope.details.searchParams = $scope.course;


                /**
                 * Send data to the WebAPI
                 */
                $scope.courseService.searchCourses($scope.details)
                    .then(function (response) {
                        $scope.courseCollection = [];
                        angular.forEach(response, function (course, index) {
                            $scope.courseCollection.push(course);

                        });
                        $scope.processing = false;
                        if ($scope.courseCollection.length == 0) {
                            $scope.noResults = true;
                        }

                    }, function () {
                        $scope.processing = false;

                        console.log("There has been an error");
                    });
            }

            if (!$scope.formValidation) {
                console.log("Not processed as the form has errors");
            }
        };


        /**
         * Add the search to the course object
         */
        $scope.loadSearchParams = function () {
            $scope.course = $scope.results[$scope.previousSearch];

            // To prevent the search display collapsing on selecting a previous search
            // set the course.SearchDisplay to false
            $scope.course.searchDisplay = false;
        };


        $scope.newCourse = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add New Course",
                cssClass: "addNewCourseModal",
                filePath: "/app/components/course/add.html",
                controllerName: "addCourseCtrl",
            });
        }


    }
})();