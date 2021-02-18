(function () {

    'use strict';


    angular
        .module("app")
        .service("TrainerProfileService", TrainerProfileService);


    TrainerProfileService.$inject = ["$http"];

    function TrainerProfileService($http) {


        var trainerProfile = this;

        /**
         * Get the list of phone Types
         */
        trainerProfile.getPhoneTypes = function () {
            return $http.get(apiServer + "/phonetype/")
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }


        /**
         * Get the list of driver licence Types
         */
        trainerProfile.getDriverLicenceTypes = function () {
            return $http.get(apiServer + "/DriverLicenceType/")
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
        * Get the trainer Titles
        */
        trainerProfile.getTrainerTitles = function () {
            return $http.get(apiServer + "/trainer/GetTitles");
        };

        /**
         * Gets the trainers profile details
         */
        trainerProfile.getTrainerDetails = function (trainerId) {
            return $http.get(apiServer + "/trainer/" + trainerId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * saves or updates the trainers details
         */
        trainerProfile.saveTrainerDetails = function (trainerDetails) {
            return $http.post(apiServer + "/trainer", trainerDetails)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        trainerProfile.getTrainerNotes = function (trainerId, userId) {
            return $http.get(apiServer + "/TrainerNote/GetByTrainerId/" + trainerId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        }

        trainerProfile.getTrainerDocuments = function (trainerId, userId) {
            return $http.get(apiServer + "/TrainerDocument/GetByTrainerId/" + trainerId + "/" + userId);
        }

        /**
         * Get user quicksearch content
         */
        trainerProfile.getOrganisationUsersContent = function (orgID, searchText) {

            return $http.get(apiServer + "/User/GetUnassignedByOrganisationId/" + orgID + "/" + searchText)
                .then(function (response) {
                    return response.data.map(function (item) {
                        return item;
                    });
                });
        };

        /**
         * Check if the user is assigned to a trainer
         */
        trainerProfile.isUserAssignedToTrainer = function (userID) {
            return $http.get(apiServer + "/User/UserAssignedToTrainer/" + userID )
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
        /**
         * Bind to the User
         */
        trainerProfile.bindTrainerUser = function (userId, trainerId) {
            return $http.get(apiServer + "/trainer/bindtouser/" + trainerId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }

})();