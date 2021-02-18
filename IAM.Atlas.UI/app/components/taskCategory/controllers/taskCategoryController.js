(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('TaskCategoryCtrl', TaskCategoryCtrl);

    TaskCategoryCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'TaskCategoryService'];

    function TaskCategoryCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, TaskCategoryService) {

        $scope.taskCategoryService = TaskCategoryService;
       
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.taskCategories = [];

        $scope.selectedTaskCategory = [];

        $scope.selectedTaskCategoryId = "";

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        $scope.setSelectedTaskCategory = function (taskCategory) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedTaskCategory = angular.copy(taskCategory);
            $scope.selectedTaskCategoryId = taskCategory.TaskCategoryId;
        }

        //Get Task Categories
        $scope.getTaskCategoryByOrganisation = function (organisationId) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.taskCategoryService.getTaskCategoryByOrganisation(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.taskCategories = response.data;

                        if ($scope.taskCategories.length > 0) {
                            
                            $scope.selectedTaskCategory = angular.copy($scope.taskCategories[0]);
                            $scope.selectedTaskCategoryId = $scope.taskCategories[0].TaskCategoryId;
                        }

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }



        /**
         * Open the add task Category
         */
        $scope.add = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Task Category",
                closable: true,
                filePath: "/app/components/taskCategory/add.html",
                controllerName: "AddTaskCategoryCtrl",
                cssClass: "addTaskCategoryModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        /**
         * save task Category
         */
        $scope.save = function () {

            if ($scope.validateTaskCategory()) {

                $scope.selectedTaskCategory.UpdatedByUserId = $scope.userId;

                $scope.taskCategoryService.saveTaskCategory($scope.selectedTaskCategory)
                    .then(
                        function (response) {
                           
                            $scope.successMessage = response.data;
                            $scope.validationMessage = "";

                            $scope.getTaskCategoryByOrganisation($scope.organisationId);


                        },
                        function (response) {
                           
                            $scope.successMessage = "";
                            $scope.validationMessage = response.data;
                        }
                    );
            }
        }

        //$scope.taskCategoryFilter = function (item) {
        //    return item.TaskCategoryId === $scope.selectedTaskCategory.selectedTaskCategoryId;
        //};

        $scope.validateTaskCategory = function () {

            $scope.validationMessage = '';

            //$scope.validateTaskCategory = $filter('filter')($scope.taskCategories, { TaskCategoryId: $scope.selectedTaskCategory.selectedTaskCategoryId })

            if ($scope.selectedTaskCategory.TaskCategoryDescription.length == 0) {
                $scope.validationMessage = "Please enter a Task Category Description.";
            }

            if ($scope.selectedTaskCategory.TaskCategoryTitle.length == 0) {
                $scope.validationMessage = "Please enter a Task Category Title.";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getTaskCategoryByOrganisation($scope.organisationId);

    }

})();