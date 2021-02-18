(function () {

    'use strict';

    angular
        .module("app")
        .service("VatService", VatService);


    VatService.$inject = ["$http"];

    function VatService($http) {

        var vatService = this;

        vatService.getList = function () {
            return $http.get(apiServer + "/vat/getlist/")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        vatService.delete = function (vateRateId, userId) {
            return $http.get(apiServer + "/vat/delete/" + vateRateId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
        
        vatService.addUKVATRate = function (vatRateToAdd, vatRateToAddEffectiveFromDate, userId) {
            return $http.get(apiServer + "/vat/add/" + vatRateToAdd + "/" + vatRateToAddEffectiveFromDate + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }
    }
})();