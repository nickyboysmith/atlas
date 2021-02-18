(function () {

    'use strict';

    angular
        .module("app")
        .service("VehicleTypeService", VehicleTypeService);

    VehicleTypeService.$inject = ["$http"];

    function VehicleTypeService($http) {

        var vehicleTypeService = this;

        vehicleTypeService.getVehicleTypes = function (organisationId) {
            return $http.get(apiServer + "/vehicleType/getVehicleTypes/" + organisationId)
        }

        vehicleTypeService.addVehicleType = function (vehicleType) {
            return $http.post(apiServer + "/vehicleType/AddVehicleType/", vehicleType)
        }

        vehicleTypeService.saveVehicleType = function (vehicleType) {
            return $http.post(apiServer + "/vehicleType/saveVehicleType/", vehicleType)
        }
    }
})();