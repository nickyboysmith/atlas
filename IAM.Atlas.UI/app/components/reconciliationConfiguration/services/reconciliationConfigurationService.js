(function () {

    'use strict';

    angular
        .module("app")
        .service("ReconciliationConfigurationService", ReconciliationConfigurationService);


    ReconciliationConfigurationService.$inject = ["$http"];

    function ReconciliationConfigurationService($http) {

        var ReconciliationConfigurationService = this;

        //referringAuthorityService.getReferringAuthorityOrganisations = function () {
        //    return $http.get(apiServer + "/referringauthority/Get/")
        //        .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        //}

        ReconciliationConfigurationService.getPaymentReconciliationData = function (organisationId) {
            return $http.get(apiServer + "/ReconciliationConfiguration/GetReconciliationConfigurations/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        ReconciliationConfigurationService.saveNewReconciliationData = function (reconciliationConfig) {
            return $http.post(apiServer + "/ReconciliationConfiguration/SaveNewReconciliationConfiguration/", reconciliationConfig)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

    }
})();