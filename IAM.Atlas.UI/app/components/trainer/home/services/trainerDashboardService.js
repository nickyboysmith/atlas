(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerDashboardService", TrainerDashboardService);

    TrainerDashboardService.$inject = ["$http"];

    function TrainerDashboardService($http) {

        var trainerDashboard = this;

        /**
         * Get courses booked for 
         * Logged in TrainerId
         */
        trainerDashboard.getCourseBookingsByOrganisationTrainer = function (OrganisationId, TrainerId) {
            return $http.get(apiServer + "/TrainerBookings/getCourseBookingsByOrganisationTrainer/" + OrganisationId + "/" + TrainerId);
        };

        /**
         * Get SystemTrainerInformation By Organisation
         */
        trainerDashboard.getSystemTrainerInformation = function (OrganisationId) {
            return $http.get(apiServer + "/Trainer/getSystemTrainerInformation/" + OrganisationId)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };


    }

})();