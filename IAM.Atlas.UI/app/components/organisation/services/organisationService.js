(function () {

    'use strict';

    angular
        .module("app")
        .service("OrganisationService", OrganisationService);


    OrganisationService.$inject = ["$http"];

    function OrganisationService($http) {

        var organisationService = this;

        organisationService.Get = function (Id) {
            return $http.get(apiServer + "/organisation/" + Id);
        };

        organisationService.CreateNew = function (organisation) {
            return $http.post(apiServer + "/organisation/add", organisation);
        };

    }

})();