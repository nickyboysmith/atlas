(function () {
    'use strict';

    angular
        .module('app')
        .controller('ViewUserCtrl', ViewUserCtrl);

    ViewUserCtrl.$inject = ["$scope", "UserService", "UserFactory", "activeUserProfile", "ModalService", "ReferringAuthorityService", "ChangePasswordRequestService"];

    function ViewUserCtrl($scope, UserService, UserFactory, activeUserProfile, ModalService, ReferringAuthorityService, ChangePasswordRequestService) {

        $scope.user = {};
        $scope.showButtons = false;

        /**
         * Check to see if the use is a system admin
         */
        if (activeUserProfile.IsOrganisationAdmin || activeUserProfile.IsSystemAdmin || activeUserProfile.UserId == $scope.selectedUserId) {
            $scope.showButtons = true;
        }

        if ($scope.selectedUserId > 0) {
            getUserData();
        }

        $scope.editUser = function (userId) {
            $scope.selectedUserId = userId;
            ModalService.displayModal({
                scope: $scope,
                title: "Edit User",
                cssClass: "editUserModal",
                filePath: "/app/components/users/edit.html",
                controllerName: "EditUserCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                        getUserData();
                    }
                }
            });
        }

        $scope.requestPasswordChange = function (user) {
            ChangePasswordRequestService.sendPasswordChangeToWebAPI(user)
                    .then(
                            function (data) {
                                $scope.successMessage = data;
                            }
                            ,
                            function (data) {
                                $scope.validationMessage = "An error occured. Please contact your administrator.";
                            }
                     );
        }


        function getUserData() {
            UserService.get($scope.selectedUserId)
                .then(
                    function (data) {
                        $scope.user = data;
                    },
                    function (data) {
                        
                    }
                );

            UserService.getCurrentUserRoles($scope.selectedUserId, activeUserProfile.selectedOrganisation.Id)
                .then(
                    function (data) {
                        $scope.userRoles = data;
                        $scope.userRoles.roleToDisplay = getUserRoleToDisplay();
                    },
                    function (data) {
                    }
                );

            UserService.getCurrentUserExtendedRoles(activeUserProfile.UserId)
                .then(
                    function (data) {
                        $scope.UserExtendedRoles = data;
                        $scope.allowUserToCreateTasks = $scope.UserExtendedRoles.IsAllowedToCreateTasks;
                        $scope.showUserTaskPanel = $scope.UserExtendedRoles.IsAllowedAccessToTaskPanel;
                    },
                    function (response) {

                    }
                );

        }

        function getUserRoleToDisplay() {                       
            if ($scope.userRoles.IsSystemAdministrator == true) {
                return "Atlas Systems Administrator";                
            } else if ($scope.userRoles.IsAdministrator == true) {
                return $scope.userRoles.OrganisationName + " Administrator";
            } else if ($scope.userRoles.IsClient == true) {
                return "Client";
            } else if ($scope.userRoles.IsTrainer) {
                return "Trainer";
            } else if ($scope.userRoles.IsOrgUser == true) {
                return $scope.userRoles.OrganisationName + " User";
            } else {
                return "";
            }        
        }

    }
})();