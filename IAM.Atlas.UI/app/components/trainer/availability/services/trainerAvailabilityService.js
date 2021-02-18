(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerAvailabiltyService", TrainerAvailabiltyService);

    TrainerAvailabiltyService.$inject = ["$http"];

    function TrainerAvailabiltyService($http) {

        var trainerAvailable = this;

        /**
         * Get the available weekdays from the WebAPI
         */
        trainerAvailable.getAvailableWeekDays = function (trainerId) {
            return $http.get(apiServer + "/traineravailability/available/" + trainerId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the unavailable days from the web api
         */
        trainerAvailable.getUnavailableDays = function (trainerId, showPastDates) {
            return $http.get(
                    apiServer
                    + "/traineravailability/unavailable/"
                    + trainerId
                    + "/"
                    + showPastDates
                )
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Save the data from the WebAPI
         */
        trainerAvailable.saveWeekDays = function (available) {
            return $http.post(apiServer + "/traineravailability/weekdays", available)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the selected course types for a trainer
         * From the webAPI
         */
        trainerAvailable.getCourseTypes = function (trainerId, organisationId) {
            return $http.get(apiServer
                + "/traineravailability/selectedcoursetypes/"
                + trainerId
                + "/"
                + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the available course types for a trainer
         * From the webAPI
         */
        trainerAvailable.getAvailableCourseTypes = function (organisationId, trainerId) {
            return $http.get(apiServer
                + "/traineravailability/availablecoursetypes/"
                + organisationId
                + "/"
                + trainerId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the courses the Trainer is booked on
         */
        trainerAvailable.getCoursesBooked = function (trainerId, showPastDates) {
            return $http.get(
                apiServer
                + "/traineravailability/courses/"
                + trainerId
                + "/"
                + showPastDates
            )
            .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Update the trainerCoursetypes
         */
        trainerAvailable.updateTrainerCourseTypes = function (trainerDetails) {
            return $http.post(apiServer + "/trainercoursetypecategory", trainerDetails)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Save the unavailablity
         */
        trainerAvailable.saveUnavailability = function (unavailability) {
            return $http.post(apiServer + "/traineravailability/saveUnavailability", unavailability)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Remove the unavailablity
         */
        trainerAvailable.removeUnavailability = function (unavailabilityId, userId) {
            return $http.get(apiServer + "/traineravailability/removeUnavailability/" + unavailabilityId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        trainerAvailable.getAvailabilityByMonth = function(trainerId, month, year){
            return $http.get(apiServer + "/traineravailability/getAvailabilityByMonth/" + trainerId + "/" + month + "/" + year);
        }

        trainerAvailable.updateAvailability = function (trainerId, available, date, sessionNumber) {
            return $http.get(apiServer + "/traineravailability/UpdateAvailability/" + trainerId + "/" + available + "/" + date + "/" + sessionNumber);
        }
    }

})();