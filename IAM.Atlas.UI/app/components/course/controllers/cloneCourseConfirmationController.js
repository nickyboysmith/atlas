(function () {

    'use strict';

    angular
        .module("app")
        .controller("CloneCourseConfirmationCtrl", CloneCourseConfirmationCtrl);

    CloneCourseConfirmationCtrl.$inject = ["$scope", "ModalService", "CourseService"];

    function CloneCourseConfirmationCtrl($scope, ModalService, CourseService) {


        /**
         * 
         */
        $scope.courseType = $scope.$parent.courseType;

        /**
         * 
         */
        $scope.courseTypeCategory = $scope.$parent.courseTypeCategory;

        /**
         * 
         */
        $scope.courseCreate = function () {
            CourseService.cloneCourseRequest($scope.$parent.cloneSettings)
            .then(
                function (response) {
                    $scope.$parent.successMessage = response.data;
                    ModalService.closeCurrentModal("cloneCourseConfirmationModal");
                },
                function (reason) {
                    // set error message on current modal
                    $scope.$parent.errorMessage = reason.data;
                    ModalService.closeCurrentModal("cloneCourseConfirmationModal");
                }
            );
        };

    }



})();