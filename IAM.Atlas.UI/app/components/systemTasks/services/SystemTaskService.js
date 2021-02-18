(function () {

    'use strict';

    angular
        .module('app')
        .service('SystemTaskService', SystemTaskService);

    SystemTaskService.$inject = ["$http"];

    function SystemTaskService($http) {

        var systemTaskService = this;

        systemTaskService.saveSystemTask = function (systemTask) {

            return $http.post(apiServer + '/systemtask/', systemTask)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        systemTaskService.showSystemTasks = function (selectedOrganisationId, userId) {

            return $http.get(apiServer + '/systemtask/getbyorganisation/' + selectedOrganisationId + '/' + userId)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };
    }
})();