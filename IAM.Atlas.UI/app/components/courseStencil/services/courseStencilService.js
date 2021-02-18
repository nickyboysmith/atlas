(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseStencilService", CourseStencilService);

    CourseStencilService.$inject = ["$http"];

    function CourseStencilService($http) {

        var courseStencil = this;

        courseStencil.get = function (courseStencilId, userId) {
            return $http.get(apiServer + "/courseStencil/" + courseStencilId + "/" + userId)
        }

        courseStencil.getAvailableCourseStencils = function (organisationId, userId) {
            return $http.get(apiServer + "/courseStencil/GetAvailableCourseStencils/" + organisationId + "/" + userId);
        }

        courseStencil.setCreateCourses = function (courseStencilId, userId, organisationId) {
            return $http.get(apiServer + "/courseStencil/SetCreateCourses/" + courseStencilId + "/" + userId + "/" + organisationId);
        }
    }

})();