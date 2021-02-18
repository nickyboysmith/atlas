(function () {

    'use strict';

    angular
        .module('app')
        .service('DashBoardMeterService', DashBoardMeterService);

    DashBoardMeterService.$inject = ["$http"];

    function DashBoardMeterService($http) {

        var dashBoardMeterService = this;

        dashBoardMeterService.UpdateMeter = function (organisationMeter) {

            return $http.post(apiServer + '/dashboard/updateorganisationmeter/', organisationMeter)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        dashBoardMeterService.updateMeterUsers = function (organisationMeterUser) {

            return $http.post(apiServer + '/dashboard/savemeteruserupdate/', organisationMeterUser)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        dashBoardMeterService.getSelectedUsers = function (meterId, organisationId) {

            return $http.get(apiServer + '/dashboard/getmeterusersbyorganisation/' + meterId + '/' + organisationId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        dashBoardMeterService.getAvailableUsers = function (meterId, organisationId) {

            return $http.get(apiServer + '/dashboard/getmeterunallocatedusersbyorganisation/' + meterId + '/' + organisationId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        dashBoardMeterService.GetMetersByOrganisation = function (organisationId) {

            return $http.get(apiServer + '/dashboard/getmetersbyorganisation/' + organisationId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };
    }
})();