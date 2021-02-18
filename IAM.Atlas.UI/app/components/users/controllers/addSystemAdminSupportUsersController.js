(function () {
    'use strict';

    angular
        .module('app')
        .controller('AddSystemAdminSupportUsersCtrl', AddSystemAdminSupportUsersCtrl);

    AddSystemAdminSupportUsersCtrl.$inject = ["$scope", "UserService", "activeUserProfile", "ModalService", "OrganisationService", "NavigationFactory"];

    function AddSystemAdminSupportUsersCtrl($scope, UserService, activeUserProfile, ModalService, OrganisationService, NavigationFactory) {

        $scope.selectedUserId = -1;
        $scope.displayAdminUsers = {};
        
        $scope.addUserErrorMessage = "";

        $scope.selectUser = function (userId) {
            $scope.selectedUserId = userId;
        };


        $scope.getNonSystemAdminSupportUsers = function () {
            $scope.errorMessage = "";
            UserService.getNonSystemAdminSupportUsers()
                .then(
                    function (data) {
                        $scope.adminUsers = data;
                        $scope.displayAdminUsers = $scope.adminUsers;
                    },
                    function (data) {

                    }
                );
        };

        $scope.makeAdminSupportUser = function (userId) {
            UserService.makeAdminSupportUser(userId, activeUserProfile.UserId)
                        .then(
                            function (data) {
                                if (data == false) $scope.errorMessage = "Couldn't make user into a support user.  Please contact support.";
                                $scope.getNonSystemAdminSupportUsers();
                                $scope.getSystemAdminSupportUsers();

                                // need hidden menu toggle add/remove from admin support list updated only if the user added is the active user
                                if (userId == activeUserProfile.UserId) {
                                    $scope.$parent.$parent.ActiveUserProfile.IsSystemAdminSupport = true;
                                    $scope.$parent.$parent.isSystemAdminSupport = true;
                                    $scope.$parent.$parent.personalMenusMiddle;
                                }
                            },
                            function (data) {

                            }
                        );
        }

        $scope.getNonSystemAdminSupportUsers();
    }

})();