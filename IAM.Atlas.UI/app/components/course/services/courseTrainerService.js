(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseTrainerService", CourseTrainerService);


    function CourseTrainerService($http) {



        //.then(function (response) { return response.data; }, function (response, status) { return response.data; });
        //.then(function () {}, function() {});

        var courseTrainerService = this;

        /**
         * Get all the selected trainers
         */
        this.getSelectedTrainers = function (courseID, organisationID) {
            return $http.get(apiServer + "/trainer/selected/" + courseID + "/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get all the selected practical trainers
         */
        this.getSelectedPracticalTrainers = function (courseID, organisationID) {
            return $http.get(apiServer + "/trainer/selectedPractical/" + courseID + "/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get all the selected theory trainers
         */
        this.getSelectedTheoryTrainers = function (courseID, organisationID) {
            return $http.get(apiServer + "/trainer/selectedTheory/" + courseID + "/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };


        /**
         *  Get all the available trainers
         */
        this.getAvailableTrainers = function (courseID, organisationID) {
            return $http.get(apiServer + "/trainer/available/" + courseID + "/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         *  Get all the available trainers
         */
        this.getAvailableTrainersBySession = function (courseId, organisationId, sessionId) {
            return $http.get(apiServer + "/trainer/available/" + courseId + "/" + organisationId + "/" + sessionId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Depending on the action 
         * Send to a different end point
         */
        this.updateAllocatedTrainers = function (trainerDetails) {
            return $http.post(apiServer + "/courseTrainer", trainerDetails)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        courseTrainerService.getTrainersAndInstructors = function (courseId) {
            return $http.get(apiServer + "/courseTrainer/getTrainersAndInstructors/");
        }


    }

})();