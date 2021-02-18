(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddTaskCtrl", AddTaskCtrl);

    AddTaskCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "ModalService", "DateFactory", "TaskService", "TaskCategoryService"];

    function AddTaskCtrl($scope, $filter, activeUserProfile, ModalService, DateFactory, TaskService, TaskCategoryService) {

        $scope.taskCategories = [];
        $scope.task = {};
        $scope.task.PriorityNumber = 2;
        $scope.task.TaskCategoryId = -1;
        $scope.displayCalendar = false;
        $scope.hours = ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'];
        $scope.task.DeadlineTime = "12:00";
        $scope.taskUserNameId = "";
        $scope.taskClientLabel = "";
        $scope.taskCourseLabel = "";
        $scope.taskTrainerLabel = "";

        $scope.getTaskCategories = function () {
            TaskCategoryService.getTaskCategoryByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.taskCategories = response.data;
                        if ($scope.taskCategories.length > 0) {
                            $scope.task.TaskCategoryId = $scope.taskCategories[0].TaskCategoryId;
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.setTaskPriority = function (priority) {
            $scope.task.PriorityNumber = priority;
        }

        $scope.validateForm = function () {
            return true;
        }

        $scope.saveTask = function () {
            $scope.task.CreatedByUserId = activeUserProfile.UserId;
            if ($scope.task.SendToOrganisation == true) {
                $scope.task.OrganisationId = activeUserProfile.selectedOrganisation.Id;
            }
            if($scope.validateForm()){
                TaskService.AddTask($scope.task)
                    .then(
                        function successCallback(response) {
                            if (response.data > 0) {
                                $scope.validationMessage = "Task added successfully.";
                            }
                        },
                        function errorCallback(response) {
                            $scope.validationMessage = response.data.ExceptionMessage;
                        }
                    );
            }
        }

        $scope.openSelectUserModal = function () {
            ModalService.displayModal({
                scope: $scope,
                cssClass: "AddTaskSelectUserModal",
                title: "Client Details",
                controllerName: "AddTaskSelectUserCtrl",
                filePath: "/app/components/task/addTaskSelectUser.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.openRelateTaskToClientModal = function () {
            ModalService.displayModal({
                scope: $scope,
                cssClass: "relateTaskToClientModal",
                title: "Link Task to Specific Client",
                controllerName: "RelateTaskToClientCtrl",
                filePath: "/app/components/task/relateTaskToClient.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.openRelateTaskToTrainerModal = function () {
            ModalService.displayModal({
                scope: $scope,
                cssClass: "relateTaskToTrainerModal",
                title: "Link Task to Specific Trainer",
                controllerName: "RelateTaskToTrainerCtrl",
                filePath: "/app/components/task/relateTaskToTrainer.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.openRelateTaskToCourseModal = function () {
            ModalService.displayModal({
                scope: $scope,
                cssClass: "relateTaskToCourseModal",
                title: "Link Task to Specific Course",
                controllerName: "RelateTaskToCourseCtrl",
                filePath: "/app/components/task/relateTaskToCourse.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        // this function is called from the addTaskSelectUserCtrl
        $scope.setUserId = function (userId, userName) {
            $scope.task.TaskAssignedToUserId = userId;
            $scope.taskUserNameId = userName + " (" + userId + ")";
        }

        // this function is called from the relateTaskToClientCtrl
        $scope.setClientId = function (clientId, clientName) {
            $scope.task.TaskRelatedToClientId = clientId;
            $scope.taskClientLabel = clientName + " (" + clientId + ")";
        }

        // this function is called from the relateTaskToCourseCtrl
        $scope.setCourseId = function (courseId, courseLabel) {
            $scope.task.TaskRelatedToCourseId = courseId;
            $scope.taskCourseLabel = courseLabel + " (" + courseId + ")";
        }

        // this function is called from the relateTaskToTrainerCtrl
        $scope.setTrainerId = function (trainerId, trainerName) {
            $scope.task.TaskRelatedToTrainerId = trainerId;
            $scope.taskTrainerLabel = trainerName + " (" + trainerId + ")";
        }

        // set the deadline to midday tomorrow (unless a weekend then set to monday)
        var today = new Date();
        var taskDueDate = new Date();
        var daysToAdd = 1;
        if (today.getDay() == 5) {     // friday
            daysToAdd = 3;
        }
        taskDueDate.setDate(today.getDate() + daysToAdd);
        $scope.task.DeadlineDate = DateFactory.formatDateDashesyyyyMMddString(taskDueDate);

        $scope.getTaskCategories();
    };

})();