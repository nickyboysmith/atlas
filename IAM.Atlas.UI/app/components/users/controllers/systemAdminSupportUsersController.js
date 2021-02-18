(function () {
    'use strict';

    angular
        .module('app')
        .controller('SystemAdminSupportUsersCtrl', SystemAdminSupportUsersCtrl);

    SystemAdminSupportUsersCtrl.$inject = ["$scope", "UserService", "activeUserProfile", "ModalService"];

    function SystemAdminSupportUsersCtrl($scope, UserService, activeUserProfile, ModalService) {

        $scope.selectedOrganisationId = {};
        $scope.selectedSupportUser = {};
        $scope.selectedSupportUserId = -1;
        $scope.supportUsers = {};
        $scope.displaySupportUsers = {};
        $scope.isOrganisationAdmin = false;

        $scope.getSystemAdminSupportUsers = function () {
            $scope.errorMessage = "";
            UserService.getSystemAdminSupportUsers()
                .then(
                    function successCallback(data) {
                        $scope.supportUsers = data;
                        $scope.displaySupportUsers = $scope.supportUsers;
                    },
                    function errorCallback(response) {

                    }
                );
        };

        $scope.addSystemAdminSupportUser = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add System Admin To Support List",
                cssClass: "addSystemAdminSupportUsersModal",
                filePath: "/app/components/users/addSystemAdminSupportUsers.html",
                controllerName: "AddSystemAdminSupportUsersCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.selectSupportUser = function (user) {
            $scope.selectedSupportUserId = user.UserId;
            $scope.selectedSupportUser = user;
        };

        $scope.removeSystemAdminSupportUser = function (userId) {
            if ($scope.supportUsers.length > 1) {
                UserService.unmakeAdminSupportUser(userId, activeUserProfile.UserId)
                    .then(
                        function (data) {
                            if (data == false) {
                                $scope.errorMessage = "Couldn't remove administrator support user, please contact support.";
                            }
                            else {
                                $scope.getSystemAdminSupportUsers();

                                // need hidden menu toggle add/remove from admin support list updated only if the user removed is the active user
                                if (userId == activeUserProfile.UserId) {
                                    $scope.$parent.ActiveUserProfile.IsSystemAdminSupport = false;
                                    $scope.$parent.isSystemAdminSupport = false;
                                    $scope.$parent.personalMenusMiddle;
                                }
                                
                            }
                            
                        },
                        function (data) {
                            $scope.errorMessage = "An error occurred, please try again.";
                        }
                    );
            }
            else {
                $scope.errorMessage = "Can't remove user: you must leave one System Support User.";
            }
        };

        $scope.getSystemAdminSupportUsers();
        //$scope.getOrganisations(activeUserProfile.UserId);
    }

})();