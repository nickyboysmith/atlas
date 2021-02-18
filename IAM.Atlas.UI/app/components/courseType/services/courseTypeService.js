(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseTypeService", CourseTypeService);


    CourseTypeService.$inject = ["$http"];

    function CourseTypeService($http) {

        var courseTypeService = this;

      
        /**
         * Get courseTypes associated with the 
         * selected organisation
         */
        courseTypeService.getCourseTypes = function (organistionId) {
            return $http.get(apiServer + "/coursetype/" + organistionId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the courseType by Id 
         */
        courseTypeService.getCourseType = function (Id) {
            return $http.get(apiServer + "/coursetype/getbyid/" + Id)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Get the CourseTypes by Organisation
        */
        courseTypeService.GetCourseTypesByOrganisationId = function (OrganisationId) {
            return $http.get(apiServer + "/coursetype/GetCourseTypesByOrganisationId/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Edit a Course Type
         */
        courseTypeService.saveCourseType = function (courseTypeObject) {
            return $http.post(apiServer + "/coursetype/EditCourseType", courseTypeObject)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Add new Course Type
        */
        courseTypeService.addCourseType = function (courseTypeObject) {
            return $http.post(apiServer + "/coursetype/AddCourseType", courseTypeObject)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * saves or updates the venue details
         */
        courseTypeService.saveVenueCourseType = function (VenueId, CourseTypeId) {
            return $http.post(apiServer + "/venuecoursetype/"
                                        + VenueId
                                        + "/"
                                        + CourseTypeId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * Get the DORSScheme associated with the  
         * selected CourseType
         */
        courseTypeService.getDORSScheme = function (courseTypeId) {
            return $http.get(apiServer + "/coursetype/GetDORSScheme/" + courseTypeId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the DORSScheme associated with the  
         * selected CourseType
         */
        courseTypeService.getCourseTypeByDORSScheme = function (dorsSchemeId, organisationId) {
            return $http.get(apiServer + "/coursetype/GetCourseType/" + dorsSchemeId + "/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
        

        courseTypeService.getDORSSchemeList = function (organisationId) {
            return $http.get(apiServer + "/DORSScheme/GetList/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }

})();