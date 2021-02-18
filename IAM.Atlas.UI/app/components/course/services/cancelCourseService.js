(function () {
    'use strict';
    angular
        .module('app')
        .service('CancelCourseService', CancelCourseService);

    CancelCourseService.$inject = ["$http"];

    function CancelCourseService($http) {

        var course = this;
        course.processCourseCancellation = function (courseCancelRequest) {
            return $http.post(apiServer + "/course/cancel", courseCancelRequest);
        }
    };
}
)();