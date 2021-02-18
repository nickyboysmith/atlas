(function () {

    'use strict';

    angular
        .module('app')
        .service('SpecialRequirementService', SpecialRequirementService);

    SpecialRequirementService.$inject = ["$http"];

    function SpecialRequirementService($http) {

        var specialRequirementService = this;

        specialRequirementService.saveSpecialRequirement = function (specialRequirement) {

            return $http.post(apiServer + '/specialrequirement/UpdateRequirement', specialRequirement)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        specialRequirementService.addRequirement = function (specialRequirement) {

            return $http.post(apiServer + '/specialrequirement/AddRequirement', specialRequirement)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        specialRequirementService.showSpecialRequirements = function (selectedOrganisationId, userId) {

            return $http.get(apiServer + '/specialrequirement/getbyorganisation/'  + selectedOrganisationId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };
    }
})();