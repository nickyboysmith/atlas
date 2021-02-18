(function () {

    'use strict';

    angular
        .module('app')
        .service('TrainerVehicleService', TrainerVehicleService);


    TrainerVehicleService.$inject = ["$http"];

    function TrainerVehicleService($http) {

        var trainerVehicleService = this;

        /**
        * Get the Trainers by Organisation
        */
        trainerVehicleService.getTrainersByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/TrainerVehicle/GetTrainersByOrganisation/" + OrganisationId)
        };

        /**
        * Get the Trainer Vehicle Details By Organisation, Trainer, VehicleType and  VehicleCategory Id
        */
        trainerVehicleService.getTrainerVehicleDetailsByOrganisation = function (TrainerVehicle) {
            return $http.get(apiServer + "/TrainerVehicle/GetTrainerVehicleDetailsByOrganisation" + "/" + TrainerVehicle.selectedOrganisationId
                                                                                                  + "/" + TrainerVehicle.selectedTrainerId
                                                                                                  + "/" + TrainerVehicle.selectedVehicleTypeId
                                                                                                  + "/" + TrainerVehicle.selectedVehicleCategoryId)
        };


        /**
        * Get Trainer Detail By TrainerId
        */
        trainerVehicleService.getTrainerById = function (TrainerId) {
            return $http.get(apiServer + "/TrainerVehicle/GetTrainerById/" + TrainerId)
        };

        /**
        * Get Trainer Vehicle Notes By Id
        */
        trainerVehicleService.getTrainerVehicleNotesById = function (OrganisationId, TrainerVehicleId) {
            return $http.get(apiServer + "/TrainerVehicle/GetTrainerVehicleNotesById/" + OrganisationId + "/" + TrainerVehicleId)
        };

        /**
        * Save a Trainer Vehicle Note
        */
        trainerVehicleService.saveNote = function (Note) {
            return $http.post(apiServer + "/TrainerVehicle/SaveNote", Note)
        };

        /**
        * Add a Trainer Vehicle
        */
        trainerVehicleService.addTrainerVehicle = function (TrainerVehicle) {
            return $http.post(apiServer + "/TrainerVehicle/AddTrainerVehicle", TrainerVehicle)
        };

        /**
        * Edit a Trainer Vehicle
        */
        trainerVehicleService.editTrainerVehicle = function (TrainerVehicle) {
            return $http.post(apiServer + "/TrainerVehicle/EditTrainerVehicle", TrainerVehicle)
        };

        /**
        * Removes a Trainer Vehicle
        */
        trainerVehicleService.removeTrainerVehicle = function (TrainerVehicle) {
            return $http.post(apiServer + "/TrainerVehicle/RemoveTrainerVehicle", TrainerVehicle)
        };

    }


})();