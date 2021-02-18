(function () {

    'use strict';

    angular
        .module("app")
        .service("VehicleCategoryService", VehicleCategoryService);

    VehicleCategoryService.$inject = ["$http"];

    function VehicleCategoryService($http) {

        var VehicleCategoryService = this;

        VehicleCategoryService.getVehicleCategories = function (organisationId) {
            return $http.get(apiServer + "/vehicleCategory/getVehicleCategories/" + organisationId)
        }

        VehicleCategoryService.addVehicleCategory = function (vehicleCategory) {
            return $http.post(apiServer + "/vehicleCategory/addVehicleCategory/", vehicleCategory)
        }

        VehicleCategoryService.saveVehicleCategory = function (vehicleCategory) {
            return $http.post(apiServer + "/vehicleCategory/saveVehicleCategory", vehicleCategory)
        }
    }
})();