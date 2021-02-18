(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerSettingsService", TrainerSettingsService);

    TrainerSettingsService.$inject = ["$http"];

    function TrainerSettingsService($http) {

        var trainerSettingsService = this;

        /**
         * Get the Organisation/s for the User
         */
        trainerSettingsService.getUserOrganisations = function (userID) {
            return $http.get(apiServer + "/organisation/GetByUser/" + userID);
        };

        /**
         * Get the related trainers for the selected Organisation
         */
        trainerSettingsService.getOrganisationTrainers = function (organisationID, userID) {
            return $http.get(apiServer + "/trainer/gettrainersbyorganisation/" + organisationID);
        };

        /**
         * Get the details for the trainer
         */
        trainerSettingsService.getTrainerSettings = function (trainerId) {
            return $http.get(apiServer + "/trainer/settings/" + trainerId);
        };

        /**
         * saves or updates the trainer settings 
         */
        trainerSettingsService.saveTrainerSettings = function (trainer) {
            return $http.post(apiServer + "/trainer/savesettings", trainer);
        }
    }
})();