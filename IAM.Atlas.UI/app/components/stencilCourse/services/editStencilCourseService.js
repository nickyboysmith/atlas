(function () {

    'use strict';

    angular
        .module("app")
        .service("EditStencilCourseService", EditStencilCourseService);


    EditStencilCourseService.$inject = ["$http"];

    function EditStencilCourseService($http) {

        var EditStencilCourseService = this;

        EditStencilCourseService.removeStencilCourses = function (stencilId, userId) {
            var parameters = {};
            parameters.stencilId = stencilId;
            parameters.userId = userId;

            return $http.post(apiServer + "/stencilcourse/removestencilcourses", parameters)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        EditStencilCourseService.createStencilCourses = function (stencilId, userId) {
            var parameters = {};
            parameters.stencilId = stencilId;
            parameters.userId = userId;

            return $http.post(apiServer + "/stencilcourse/createstencilcourses", parameters)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        EditStencilCourseService.createNewStencilVersion = function (stencilId, userId, organisationId) {
            var parameters = {};
            parameters.stencilId = stencilId;
            parameters.userId = userId;
            parameters.organisationId = organisationId;

            return $http.post(apiServer + "/stencilcourse/createnewstencilversion", parameters)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        EditStencilCourseService.getOrganisationStencils = function (organisationId, userId) {
            return $http.get(apiServer + "/stencilCourse/GetAvailableCourseStencils/" + organisationId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }

})();