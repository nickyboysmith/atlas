(function () {

    'use strict';

    angular
        .module("app")
        .controller("RelateTaskToCourseCtrl", RelateTaskToCourseCtrl);

    RelateTaskToCourseCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "DateFactory", "TaskService", "CourseService"];

    function RelateTaskToCourseCtrl($scope, $filter, activeUserProfile, DateFactory, TaskService, CourseService) {

        $scope.taskCourses = [];
        $scope.taskCoursesTemplate = [];
        $scope.selectedCourseId = -1;
        $scope.maxResults = 10;
        $scope.selectedTaskId = -1;
        $scope.selectedTaskTitle = "";

        $scope.getTaskCourses = function () {
            CourseService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.taskCourses = response.data;
                        $scope.taskCoursesTemplate = $scope.taskCourses;
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = "An error occurred, please try again.";
                    }
                );
        }

        $scope.selectCourse = function (courseId) {
            $scope.selectedCourseId = courseId;
        }

        $scope.linkTaskToCourse = function (courseId) {
            if ($scope.setCourseId) {
                var selectedCourses = $filter('filter')($scope.taskCourses, { CourseId: courseId });
                if (selectedCourses.length > 0) {
                    $scope.setCourseId(courseId, selectedCourses[0].CourseReference + " - " + DateFactory.formatDateddMONyyyy(new Date(selectedCourses[0].StartDate)) + " - " +selectedCourses[0].CourseType);
                    // close this modal
                    $('button.close').last().trigger('click');
                }
                else {
                    $scope.validationMessage = "Error: Couldn't link Task to Course.";
                }
            }
        }

        if ($scope.$parent.selectedTaskTitle) {
            $scope.selectedTaskTitle = $scope.$parent.selectedTaskTitle;
        }

        if ($scope.$parent.selectedTaskId) {
            $scope.selectedTaskId = $scope.$parent.selectedTaskId;
        }

        $scope.getTaskCourses();
    };


})();