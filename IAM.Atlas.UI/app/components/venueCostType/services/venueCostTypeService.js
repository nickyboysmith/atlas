(function () {

    'use strict';

    angular
        .module('app')
        .service('VenueCostTypeService', VenueCostTypeService);

    VenueCostTypeService.$inject = ["$http"];

    function VenueCostTypeService($http) {

        var venueCostTypeService = this;

        venueCostTypeService.getVenueCostTypes = function (organisationId) {
            return $http.get(apiServer + '/venuecosttype/getbyorganisation/' + organisationId)
                .then(function (data, status, headers, config) {
                }, function(data, status, headers, config) {
                });
        };

        venueCostTypeService.saveVenueCostType = function (venueCostType) {

            return $http.post(apiServer + '/venuecosttype/', venueCostType)
                        .then(function (data, status, headers, config) {
                        }, function (data, status, headers, config) {
                        });
        };
    }
})();