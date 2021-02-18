(function () {

    'use strict';

    angular
        .module('app')
        .service('VenueCostService', VenueCostService);

    VenueCostService.$inject = ["$http"];

    function VenueCostService($http) {

        var venueCostService = this;

        venueCostService.saveVenueCost = function (venueCost) {

            return $http.post(apiServer + '/venuecost/Save', venueCost)
                        .then(function (data, status, headers, config) {


                        }, function (data, status, headers, config) {
                        });
        };

        venueCostService.deleteVenueCost = function (venueCostId) {
            if (venueCostId > 0) {
                return $http.get(apiServer + '/venuecost/delete/' + venueCostId)
                    .then(function (data, status, headers, config) {
                    }, function (data, status, headers, config) {
                    });
            }
            else return;            
        };

        venueCostService.getVenueCost = function (venueCostId) {
            if (venueCostId > 0) {
                return $http.get(apiServer + '/venuecost/' + venueCostId)
                    .then(function (data, status, headers, config) {

                    }, function (data, status, headers, config) {
                    });
            }
            else return;
        };
    }
})();