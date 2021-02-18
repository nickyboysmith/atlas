(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddTaskCategoryCtrl', AddTaskCategoryCtrl);

    AddTaskCategoryCtrl.$inject = ['$scope', '$location', '$window', '$http', 'TaskCategoryService'];

    function AddTaskCategoryCtrl($scope, $location, $window, $http, TaskCategoryService) {

        $scope.taskCategory = {
            TaskCategoryTitle: "",
            TaskCategoryDescription: "",
            TaskCategoryDisabled: false,
            TaskCategoryColourName: "LightYellow",
            CreatedByUserId: $scope.$parent.userId,
            OrganisationId: $scope.$parent.organisationId
        };

        $scope.addTaskCategory = function () {

            if ($scope.validateTaskCategory()) {

                TaskCategoryService.addTaskCategory($scope.taskCategory)
                    .then(
                        function (response) {
                            $scope.$parent.getTaskCategoryByOrganisation($scope.$parent.organisationId);
                            $('button.close').last().trigger('click');
                        },
                        function (response) {

                        }
                    );
            }
        }

        $scope.validateTaskCategory = function () {

            $scope.validationMessage = '';

            if ($scope.taskCategory.TaskCategoryDescription.length == 0) {
                $scope.validationMessage = "Please enter a Task Category Description.";
            }

            if ($scope.taskCategory.TaskCategoryTitle.length == 0) {
                $scope.validationMessage = "Please enter a Task Category Title.";
            }
            
            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

    }

})();