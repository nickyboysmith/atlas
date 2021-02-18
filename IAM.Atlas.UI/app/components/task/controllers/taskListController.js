(function () {

    'use strict';

    angular
        .module("app")
        .controller("TaskListCtrl", TaskListCtrl);

    TaskListCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "ModalService", "DateFactory", "TaskService", "UserService"];

    function TaskListCtrl($scope, $filter, activeUserProfile, ModalService, DateFactory, TaskService, UserService) {

        $scope.tasks = [];
        $scope.selectedTaskId = -1;
        $scope.selectedTaskTitle = "";
        $scope.organisationUsers = [];
        $scope.organisations = [];
        $scope.selectedUserId = -1;
        $scope.selectedOrganisationId = -1;
        $scope.viewAllUsers = false;
        $scope.maxResults = 10;

        $scope.getTasks = function () {
            TaskService.GetTasksByOrganisationAndUser($scope.selectedOrganisationId, $scope.selectedUserId)
                .then(
                    function successCallback(response) {
                        $scope.tasks = $filter('filter')(response.data, { TaskPriorityNumber: $scope.TaskPriorityNumber, TaskCompletedByUser: false });
                        $scope.tasksTemplate = $scope.tasks;
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.showClientModal = function (clientId) {
            $scope.clientId = clientId;

            ModalService.displayModal({
                scope: $scope,
                cssClass: "clientDetailModal",
                title: "Client Details",
                controllerName: "clientDetailsCtrl",
                filePath: "/app/components/client/cd_view.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.showCourseModal = function (courseId) {
            $scope.courseId = parseInt(courseId);
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.userId = activeUserProfile.UserId;

            ModalService.displayModal({
                scope: $scope,
                title: "View Course",
                cssClass: "courseViewModal",
                filePath: "/app/components/course/edit.html",
                controllerName: "editCourseCtrl"
            });
        }

        $scope.showTrainerModal = function (trainerId) {
            $scope.trainerId = trainerId;
            $scope.isModal = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Trainer Details",
                cssClass: "trainerEditModal",
                filePath: "/app/components/trainer/about/view.html",
                controllerName: "TrainerAboutCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.Completed = function (taskId, taskForUserId, taskTitle) {
            $scope.validationMessage = "";
            TaskService.CompletedTask(taskId, taskForUserId, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        if(response.data && response.data > 0){
                            $scope.validationMessage = taskTitle + " checked.";
                            $scope.getTasks();
                            if ($scope.getUserTaskSummary) {
                                $scope.getUserTaskSummary();
                            }
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.openAssignTaskModal = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Send Task to Specific User",
                cssClass: "taskAssignToUserModal",
                filePath: "/app/components/task/assignToUser.html",
                controllerName: "TaskAssignToUserCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.selectTask = function (taskId, taskTitle) {
            if ($scope.selectedTaskId == taskId) {
                $scope.selectedTaskId = -1;
                $scope.selectedTaskTitle = "";
            }
            else {
                $scope.selectedTaskId = taskId;
                $scope.selectedTaskTitle = taskTitle;
            }
        }

        $scope.getUsers = function() {
            UserService.GetOrganisationUsers($scope.selectedOrganisationId)
                .then(
                    function successCallback(response) {
                        $scope.organisationUsers = response;
                        var userIsInOrganisation = $filter('filter')($scope.organisationUsers, { id: $scope.selectedUserId });
                        if (userIsInOrganisation.length == 0) {
                            if ($scope.organisationUsers.length > 0) {
                                $scope.selectedUserId = $scope.organisationUsers[0].Id;
                            }
                            else {
                                $scope.selectedUserId = -1;
                            }
                        }
                        $scope.selectUser($scope.selectedUserId);
                    },
                    function errorCallback(response) { 

                    }
                );
        }

        $scope.getOrganisations = function() {
            UserService.getOrganisationIds($scope.selectedUserId)
                .then(
                    function successCallback(response) { 
                        $scope.organisations = response;
                        $scope.getUsers();
                    },
                    function errorCallback(response) { 

                    }
                );
        }

        $scope.selectUser = function (userId) {
            $scope.selectedUserId = userId;
            $scope.getTasks();
        }

        $scope.selectOrganisation = function (organisationId) {
            $scope.selectedOrganisationId = organisationId;
            $scope.getUsers();
        }

        // initialise to the current user and organisation
        $scope.selectedOrganisationId =activeUserProfile.selectedOrganisation.Id;
        $scope.selectedUserId = activeUserProfile.UserId;

        // is this modal viewing all user's tasks or just the logged in user's?
        if ($scope.$parent.viewAllUsers && $scope.$parent.viewAllUsers == true) {
            $scope.viewAllUsers = true;
            $scope.getOrganisations();
        }
        else {
            $scope.getTasks();
        }        
    };


})();