(function () {

    'use strict';

    angular
        .module('app')
        .service('CourseFeeService', CourseFeeService);


    CourseFeeService.$inject = ["$http"];

    function CourseFeeService($http) {

        var courseFeeService = this;

        /**
        * Get the courseFee
        */
        courseFeeService.getCourseTypeFee = function (CourseTypeId, CourseTypeCategoryId) {
            return $http.get(apiServer + "/courseFee/GetCourseTypeFee/" + CourseTypeId + "/" + CourseTypeCategoryId)
        };

        /**
        * Cancel the courseFee
        */
        courseFeeService.cancelCourseFee = function (cancelCourseFee) {
            return $http.post(apiServer + "/courseFee/CancelCourseFee", cancelCourseFee)
        };

        /**
        * Add a new courseFee
        */
        courseFeeService.addCourseFee = function (addCourseFee) {
            return $http.post(apiServer + "/courseFee/AddCourseFee", addCourseFee)
        };

        /**
        * Saves the courseFee
        */
        courseFeeService.save = function (courseFeeSettings) {
            return $http.post(apiServer + "/courseFee/Save", courseFeeSettings)
        };

        

    }



})();