(function () {

    'use strict';

    angular
        .module("app")
        .service("TaskService", TaskService);

    TaskService.$inject = ["$http"];

    function TaskService($http) {

        var taskService = this;

        /**
         * Get dashboard meters
         * For selected organisation and
         * Logged in UserId
         */
        taskService.GetTaskSummaryByUser = function (UserId) {
            return $http.get(apiServer + "/task/getTaskSummaryByUser/" + UserId);
        };

        taskService.GetTasksByOrganisationAndUser = function (OrganisationId, UserId) {
            return $http.get(apiServer + "/task/GetTasksByOrganisationAndUser/" + OrganisationId + "/" + UserId);
        }

        taskService.CompletedTask = function (taskId, taskForUserId, completedByUserId) {
            return $http.get(apiServer + "/task/CompletedTask/" + taskId + "/" + taskForUserId + "/" + completedByUserId);
        }

        taskService.AssignTaskToUser = function (taskId, userId, assigningUserId) {
            return $http.get(apiServer + "/task/AssignTaskToUser/" + taskId + "/" + userId + "/" + assigningUserId);
        }

        taskService.AddTask = function (addTaskForm) {
            return $http.post(apiServer + "/task", addTaskForm);
        }
    }

})();