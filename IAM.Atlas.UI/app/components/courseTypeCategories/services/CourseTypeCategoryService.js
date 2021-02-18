(function () {

    'use strict';

    angular
        .module('app')
        .service('CourseTypeCategoryService', CourseTypeCategoryService);

    CourseTypeCategoryService.$inject = ["$http"];

    function CourseTypeCategoryService($http) {

        var courseTypeCategoryService = this;

        /**
        * Add new Course Type Category
        */
        courseTypeCategoryService.addCourseTypeCategory = function (courseTypeCategory) {
            return $http.post(apiServer + "/coursetypecategory/AddCourseTypeCategory/", courseTypeCategory)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
            };

        /**
        * Edit Course Type Category
        */
        courseTypeCategoryService.saveCourseTypeCategory = function (courseTypeCategory) {
            return $http.post(apiServer + "/coursetypecategory/EditCourseTypeCategory/", courseTypeCategory)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        courseTypeCategoryService.showCourseTypeCategories = function (selectedCourseTypeId, userId) {
            return $http.get(apiServer + '/coursetypecategory/getbycoursetype/' + selectedCourseTypeId + '/' + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }
})();