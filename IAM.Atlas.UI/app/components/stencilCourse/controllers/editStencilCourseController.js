(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('editStencilCourseCtrl', editStencilCourseCtrl);

    editStencilCourseCtrl.$inject = ["$scope", "$http", "$window", "EditStencilCourseService", "UserService", "activeUserProfile"];

    function editStencilCourseCtrl($scope, $http, $window, EditStencilCourseService, UserService, activeUserProfile) {
        $scope.selectedCourseStencil = {};

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;
        $scope.organisationId = 0;

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (response) {
                            $scope.isAdmin = response;
                        },
                        function (response) {
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
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (data) {
                    $scope.isAdmin = data;
                });
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                    //$scope.getUsers();
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        $scope.showStencils = function (selectedOrganisationId) {
            $scope.organisationId = selectedOrganisationId;
            EditStencilCourseService.getOrganisationStencils(selectedOrganisationId, $scope.userId)
            .then(
                    function successCallback(response) {
                        $scope.courseStencils = response;
                        if ($scope.courseStencils.length == 0) {
                            $scope.selectedCourseStencil = null;
                        } else {
                            $scope.selectedCourseStencil = $scope.courseStencils[0];
                            document.getElementsByClassName('sml-scroll-div')[0].scrollTop = 0;
                        }
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = response.ExceptionMessage;
                    }
                );

        }

        $scope.loadStencilDetail = function (courseStencil) {
            $scope.selectedCourseStencil = courseStencil;
        }

        $scope.openCreateStencilCourseModal = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Create Stencil Courses",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/stencilcourse/create.html",
                controllerName: "createStencilCourseCtrl",
                cssClass: "createStencilCourseModal"
            });
        }

        $scope.openRemoveStencilCourseModal = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Remove Stencil Courses",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/stencilcourse/remove.html",
                controllerName: "removeStencilCourseCtrl",
                cssClass: "removeStencilCourseModal"
            });
            }

        $scope.openNewStencilModal = function () {

            $scope.editStencilVersionId = 0;
            $scope.newVersion = false;

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Create Multi-Course Stencil",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/courseStencil/add.html",
                controllerName: "addCourseStencilCtrl",
                cssClass: "courseStencilModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                        $scope.showStencils($scope.selectedOrganisationId);
                    }
                }
            });
        }
        
        $scope.openEditStencilModal = function (newVersion) {
            $scope.editStencilVersionId = $scope.selectedCourseStencil.Id;
            $scope.newVersion = newVersion;

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Create Multi-Course Stencil",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/courseStencil/add.html",
                controllerName: "addCourseStencilCtrl",
                cssClass: "courseStencilModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                        $scope.showStencils($scope.selectedOrganisationId)
                    }
                }
            });
        }

        $scope.getOrganisations($scope.userId);

        //if we have a selected organisation populate stencil list
        if ($scope.organisationId) {
            $scope.selectedOrganisationId = $scope.organisationId;
            $scope.showStencils($scope.selectedOrganisationId);
        }

    }
})();