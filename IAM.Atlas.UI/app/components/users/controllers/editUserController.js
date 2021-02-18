(function () {
    'use strict';

    angular
        .module('app')
        .controller('EditUserCtrl', EditUserCtrl);

    EditUserCtrl.$inject = ["$scope", "UserService", "UserFactory", "activeUserProfile", "ChangePasswordRequestService", "ModalService", "GenderService"];

    function EditUserCtrl($scope, UserService, UserFactory, activeUserProfile, ChangePasswordRequestService, ModalService, GenderService) {

        $scope.user = {};
        $scope.genders = [];

        $scope.showButtons = false;

        /**
         * Check to see if the use is a system admin
         */
        if (activeUserProfile.IsOrganisationAdmin || activeUserProfile.IsSystemAdmin || activeUserProfile.UserId == $scope.selectedUserId) {
            $scope.showButtons = true;
        }

        if ($scope.selectedUserId > 0) {
            GenderService.get()
                .then(
                    function (response) {
                        
                        $scope.genders = response.data;

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
                    },
                    function (data) {
                    }
                );
        }

        $scope.saveUser = function () {
            // add toggle between user and admin to user
            $scope.user.IsAdministrator = $scope.userRoles.IsAdministrator;
            $scope.user.OrganisationId = $scope.userRoles.OrganisationId;
            //$scope.user.createdByUserId = activeUserProfile.UserId;
            $scope.user.UpdatedByUserId = activeUserProfile.UserId;
            
            UserService.postEntity($scope.user)
                .then(
                    function (data) {
                        var userId = data;
                        if (userId > 0) {
                            $scope.successMessage = "User saved successfully.";
                            $scope.validationMessage = "";
                        }
                    },
                    function (data) {
                        $scope.validationMessage = "User couldn't be saved. Please contact support.";
                        $scope.successMessage = "";
                    }
                );
        }

        $scope.switchRole = function () {
            $scope.userRoles.roleToDisplay = getUserRoleToDisplay();
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
    }

})();