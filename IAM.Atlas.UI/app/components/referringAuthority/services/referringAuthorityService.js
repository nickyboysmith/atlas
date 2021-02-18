(function () {

    'use strict';

    angular
        .module("app")
        .service("ReferringAuthorityService", ReferringAuthorityService);


    ReferringAuthorityService.$inject = ["$http"];

    function ReferringAuthorityService($http) {

        var referringAuthorityService = this;

        referringAuthorityService.getReferringAuthorityOrganisations = function () {
            return $http.get(apiServer + "/referringauthority/Get/")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        referringAuthorityService.getByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/referringauthority/GetByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        referringAuthorityService.saveAuthority = function (authority) {
            return $http.post(apiServer + "/referringauthority/saveauthority", authority)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        referringAuthorityService.getAuthority = function (organisationId) {
            return $http.get(apiServer + "/referringauthority/getauthority/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }
    }
})();