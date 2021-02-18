(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('createStencilCourseCtrl', createStencilCourseCtrl);

    createStencilCourseCtrl.$inject = ["$scope", "$http", "$window", "EditStencilCourseService", "UserService", "ModalService"];

    function createStencilCourseCtrl($scope, $http, $window, EditStencilCourseService, UserService, ModalService) {

        $scope.stencilId = $scope.$parent.selectedCourseStencil.Id;
        $scope.userId = $scope.$parent.userId;

        $scope.course = {
            name: $scope.$parent.selectedCourseStencil.Name,
            versionNumber: $scope.$parent.selectedCourseStencil.VersionNumber
        };

        $scope.createCourses = function ($event) {
            $event.currentTarget.disabled = true;
            $event.currentTarget.innerText = "'Creating....'";
            EditStencilCourseService.createStencilCourses($scope.stencilId, $scope.userId)
            .then(
                    function successCallback(response) {
                        var i;
                        //for (i = 0; i < $scope.$parent.courseStencils.length - 1; i++) {
                        //    if ($scope.$parent.courseStencils[i].Id == $scope.stencilId) {
                        //        $scope.$parent.courseStencils[i].showCreateCourses = false;
                        //    }
                        //}
                        //$scope.$parent.selectedCourseStencil.showCreateCourses = false;
                        $scope.$parent.showStencils($scope.selectedOrganisationId)
                        $scope.close();
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = response.data.ExceptionMessage;
                        $event.currentTarget.disabled = false;
                        $event.currentTarget.innerText = "Create Courses";
                    }
                );
        }

        $scope.close = function () {
            ModalService.closeCurrentModal("createStencilCourseModal");
        }
    }
})();