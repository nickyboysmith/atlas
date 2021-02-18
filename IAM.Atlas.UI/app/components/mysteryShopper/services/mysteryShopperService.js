(function () {

    'use strict';

    angular
        .module("app")
        .service("MysteryShopperService", MysteryShopperService);

    MysteryShopperService.$inject = ["$http"];

    function MysteryShopperService($http) {

        var mysteryShopperService = this;

        mysteryShopperService.getAvailableUsers = function (organisationId) {
            return $http.get(apiServer + "/mysteryShopper/getAvailableUsers/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        mysteryShopperService.getMysteryShopperAdministrators = function (organisationId) {
            return $http.get(apiServer + "/mysteryShopper/getMysteryShopperAdministrators/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        mysteryShopperService.updateMysteryShopperAdmin = function (mysteryShopper) {
            return $http.post(apiServer + "/mysteryShopper/updateMysteryShopperAdministrators", mysteryShopper)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

    }
})();