(function () {

    'use strict';

    angular
        .module('app')
        .service('CourseRebookingFeeService', CourseRebookingFeeService);


    CourseRebookingFeeService.$inject = ["$http"];

    function CourseRebookingFeeService($http) {

        var courseRebookingFeeService = this;

        /**
        * Get the courseRebookingFee
        */
        courseRebookingFeeService.getCourseTypeRebookingFee = function (CourseTypeId, CourseTypeCategoryId) {
            return $http.get(apiServer + "/courseRebookingFee/GetCourseTypeRebookingFee/" + CourseTypeId + "/" + CourseTypeCategoryId)
        };

        /**
        * Cancel the courseRebookingFee
        */
        courseRebookingFeeService.cancelCourseRebookingFee = function (cancelCourseRebookingFee) {
            return $http.post(apiServer + "/courseRebookingFee/CancelCourseRebookingFee", cancelCourseRebookingFee)
        };

        /**
        * Add a new courseRebookingFee
        */
        //courseRebookingFeeService.addCourseRebookingFee = function (addCourseRebookingFee) {
        //    return $http.post(apiServer + "/courseRebookingFee/AddCourseRebookingFee", addCourseRebookingFee)
        //};

        /**
        * Saves the courseRebookingFee
        */
        courseRebookingFeeService.save = function (courseRebookingFee) {
            return $http.post(apiServer + "/courseRebookingFee/Save", courseRebookingFee)
        };



    }



})();