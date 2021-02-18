(function () {

    'use strict';


    angular
        .module("app")
        .service("TrainerService", TrainerService);


    TrainerService.$inject = ["$http"];

    function TrainerService($http) {


        var trainerService = this;

        trainerService.GetByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/trainer/gettrainersbyorganisation/" + organisationId);
        }

    }

})();