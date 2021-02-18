(function () {

    'use strict';

    angular
        .module('app')
        .service('CourseReferenceService', CourseReferenceService);


    CourseReferenceService.$inject = ["$http"];

    function CourseReferenceService($http) {

        var courseReferenceService = this;

        /**
         * Get the Course Reference Details
         */
        courseReferenceService.GetAll = function (OrganisationId) {
            return $http.get(apiServer + "/courseReference/Get")
          
        };

        /**
        * Get the Course Reference Trainer Settings
        */
        courseReferenceService.GetTrainerSettings = function (OrganisationId) {
            return $http.get(apiServer + "/courseReference/GetTrainerSettings/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

        /**
        * Get the Course Reference Interpreter Settings
        */
        courseReferenceService.GetInterpreterSettings = function (OrganisationId) {
            return $http.get(apiServer + "/courseReference/GetInterpreterSettings/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

        /**
        * Has A Course Reference Trainer Setting
        */
        courseReferenceService.HasTrainerSettings = function (OrganisationId) {
            return $http.get(apiServer + "/courseReference/HasTrainerSettings/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

        /**
        * Has A Course Reference Interpreter Setting
        */
        courseReferenceService.HasInterpreterSettings = function (OrganisationId) {
            return $http.get(apiServer + "/courseReference/HasInterpreterSettings/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

        /**
        * Save the Course Reference Trainer Settings
        */
        courseReferenceService.SaveTrainerSettings = function (TrainerSettings) {
            return $http.post(apiServer + "/courseReference/SaveTrainerSettings", TrainerSettings)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
       * Save the Course Reference Interpreter Settings
       */
        courseReferenceService.SaveInterpreterSettings = function (InterpreterSettings) {
            return $http.post(apiServer + "/courseReference/SaveInterpreterSettings", InterpreterSettings)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

    }

})();