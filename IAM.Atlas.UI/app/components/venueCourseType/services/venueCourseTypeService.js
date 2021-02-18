(function () {

    'use strict';

    angular
        .module("app")
        .service("VenueCourseTypeService", VenueCourseTypeService);


    VenueCourseTypeService.$inject = ["$http"];

    function VenueCourseTypeService($http) {

        var venueCourseTypeService = this;

        venueCourseTypeService.deleteVenueCourseType = function (venueCourseTypeId) {
            if (venueCourseTypeId > 0) {
                return $http.get(apiServer + "/venuecoursetype/delete/" + venueCourseTypeId)
                    .then(function (data, status, headers, config) {
                    }, function (data, status, headers, config) {
                    });
            }
            else return;
        };


        /**
         * Get courseTypes associated with the 
         * selected organisation
         */

        //venueCourseTypeService.getCourseTypes = function (organistionId) {
        //    return $http.get(apiServer + "/coursetype/" + organistionId)
        //        .then(function (data) { })
        //        .error(function (data, status) { });
        //};

        /**
         * Get the courseType by Id 
         */

        //venueCourseTypeService.getCourseType = function (Id) {
        //    return $http.get(apiServer + "/coursetype/getbyid/" + Id)
        //        .then(function (data) { })
        //        .error(function (data, status) { });
        //};


        //venueCourseTypeService.saveCourseType = function (courseTypeObject) {
        //    return $http.post(apiServer + "/coursetype", courseTypeObject)
        //        .then(function (data) { })
        //        .error(function (data, status) { });
        //};
    }

})();