(function () {
    'use strict';
    angular
        .module('app')
        .controller('cancelCourseCtrl', ['$scope', 'CancelCourseService', 'ModalService', cancelCourseCtrl]);

    function cancelCourseCtrl($scope, CancelCourseService, ModalService) {

        $scope.cancelService = CancelCourseService;

        $scope.cancelRequest = function () {

        };

        $scope.cancelCourse = function () {
            var courseCancelRequest = {};
            courseCancelRequest.courseId = $scope.$parent.$parent.$parent.course.courseId;
            courseCancelRequest.userId = $scope.$parent.$parent.$parent.course.userId;

            $scope.cancelService.processCourseCancellation(courseCancelRequest)
            .then
            (
                function successCallback(response) {
                    if (response.data == "Success") {
                        $scope.$parent.$parent.$parent.cancelledMessage = "Course Cancelled";
                    } else {
                        $scope.$parent.$parent.$parent.cancelledMessage = "Course Cancellation Failed: Course is still live.";
                    }
                }
                ,
                function failureCallback(response) {
                    $scope.$parent.$parent.$parent.cancelledMessage = "Course Cancellation Failed: Course is still live.";
                }
            );

            ModalService.closeCurrentModal("cancelCourseModal");
        };

    }
}
)();