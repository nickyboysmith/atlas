(function () {
    'use strict';
    angular
        .module("app")
        .service("AdministrationService", AdministrationService);

    AdministrationService.$inject = ["$http"];

    function AdministrationService($http) {

        var AdministrationService = this;

        AdministrationService.getMenuItems = function (userId, organisationId) {
            // var userId = 1; // @todo dont hard code user id
            return $http.get(apiServer + "/administration/" + userId + "/" + organisationId);
        };
    }
})();
