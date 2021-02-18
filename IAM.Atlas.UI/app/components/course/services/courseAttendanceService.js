(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseAttendanceService", CourseAttendanceService);

    CourseAttendanceService.$inject = ["$http"];

    function CourseAttendanceService($http) {

        var courseAttendance = this;

        /**
         * Get the course detail
         */
        courseAttendance.getCourseDetail = function (searchObject) {
            var endPoint = apiServer + "/CourseAttendance/Search";
            return $http.post(endPoint, searchObject);
        };

        /**
         * Get the course clients
         */
        courseAttendance.getCourseClients = function (courseDetails) {
            var endPoint = apiServer + "/CourseAttendance/CourseClients";
            return $http.post(endPoint, courseDetails);
        };

        /**
         * Get the trainerAttendance
         */
        courseAttendance.getAttendance = function (trainerDetails) {
            var endPoint = apiServer + "/CourseAttendance/Trainer";
            return $http.post(endPoint, trainerDetails);
        };

        /**
         * Set AttendanceCheckVerified
         */
        courseAttendance.setAttendanceCheckVerified = function (courseId, organisationId) {
            var endPoint = apiServer + "/CourseAttendance/SetAttendanceCheckVerified";
            return $http.get(endPoint + "/" + courseId + "/" + organisationId);
        };

        /*
         * Toggle Course Attendance
         */
        courseAttendance.setClientAttendance = function (courseId, clientId, userId) {
            return $http.get(apiServer + "/CourseAttendance/SetClientAttendance/" + courseId + "/" + clientId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /*
         * Course Attendance - Mark all as Absent
         */
        courseAttendance.setCourseAttendanceAbsentToAll = function (courseId, userId) {
            return $http.get(apiServer + "/CourseAttendance/SetCourseAttendanceAbsentToAll/" + courseId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /*
         * Course Attendance - Mark all as Present
         */
        courseAttendance.setCourseAttendancePresentToAll = function (courseId, userId) {
            return $http.get(apiServer + "/CourseAttendance/SetCourseAttendancePresentToAll/" + courseId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        courseAttendance.getCourseTypes = function (organisationId) {
            var endPoint = apiServer + "/CourseAttendance/GetCourseTypesByOrganisationId";
            return $http.get(endPoint + "/" + organisationId)
                    .then(function (response) { return response.data; }, function (response, status) { return response; });
        };

        courseAttendance.ClearDORSClientCourseAttendanceLog = function (dorsCourseIdentifier, dorsClientIdentifier, userId, organisationId) {
            return $http.get(apiServer + "/CourseAttendance/ClearDORSClientCourseAttendanceLog/" + dorsCourseIdentifier + "/" + dorsClientIdentifier + "/" + userId + "/" + organisationId);
        }
    }

})();