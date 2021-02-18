(function () {
    'use strict';

    angular
        .module('app')
        .controller('SystemSupportUsersCtrl', SystemSupportUsersCtrl);

    SystemSupportUsersCtrl.$inject = ["$scope", "UserService", "activeUserProfile", "ModalService"];

    function SystemSupportUsersCtrl($scope, UserService, activeUserProfile, ModalService) {

        $scope.selectedOrganisationId = {};
        $scope.selectedSupportUser = {};
        $scope.selectedSupportUserId = -1;
        $scope.supportUsers = {};
        $scope.displaySupportUsers = {};
        $scope.isOrganisationAdmin = false;

        $scope.getSelectedOrganisationId = function () {
            var selectedOrganisationId = '' +activeUserProfile.selectedOrganisation.Id;
            return selectedOrganisationId;
        };

        $scope.getSystemSupportUsers = function (organisationId) {
            $scope.errorMessage = "";
            $scope.selectedOrganisationId = organisationId; // because we trigger this fn from the onchange
            UserService.getSystemSupportUsers(organisationId)
                .then(
                    function successCallback(response) {
                        $scope.supportUsers = response;
                        $scope.displaySupportUsers = $scope.supportUsers;
                    },
                    function errorCallback(response) { 

                    }
                );
        };

        //Get Organisations function
        $scope.getOrganisations = function (userId) {
            UserService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                $scope.selectedOrganisationId = '' +activeUserProfile.selectedOrganisation.Id;
                UserService.checkSystemAdminUser(userId)
                    .then(function (data) {
                        $scope.isAdmin = data;
                        $scope.isOrganisationAdmin = activeUserProfile.IsOrganisationAdmin;
                        $scope.getSystemSupportUsers($scope.selectedOrganisationId);
                    });
                }, function(data) {
                    console.log("Can't get Organisations");
                });
        };

        $scope.addSystemSupportUser = function () {
            ModalService.displayModal({
                    scope: $scope,
                    title: "Add Support User",
                    cssClass: "addSystemSupportUserModal",
                    filePath: "/app/components/users/addSystemSupportUser.html",
                    controllerName: "AddSystemSupportUserCtrl",
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
            $scope.selectedSupportUserId = user.Id;
            $scope.selectedSupportUser = user;
        };

        $scope.removeSystemSupportUser = function (userId) {
            if ($scope.supportUsers.length > 1) {
                UserService.unmakeSupportUser(userId, $scope.selectedOrganisationId, activeUserProfile.UserId)
                    .then(
                        function (data) {
                            if (data == false) {
                                $scope.errorMessage = "Couldn't remove support user, please contact support.";
                            }
                            $scope.getSystemSupportUsers($scope.selectedOrganisationId);
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

        $scope.getOrganisations(activeUserProfile.UserId);
    }

})();