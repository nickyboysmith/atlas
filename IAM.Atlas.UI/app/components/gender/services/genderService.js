(function () {

    'use strict';

    angular
        .module("app")
        .service("GenderService", GenderService);


    GenderService.$inject = ["$http"];

    function GenderService($http) {

        var genderService = this;
        
        genderService.get = function () {
            return $http.get(apiServer + "/gender/getGenders");
        }
    }
})();