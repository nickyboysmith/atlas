(function () {
    'use strict';

    angular
        .module('app')
        .controller('AddSystemSupportUserCtrl', AddSystemSupportUserCtrl);

    AddSystemSupportUserCtrl.$inject = ["$scope", "UserService", "activeUserProfile", "ModalService", "OrganisationService"];

    function AddSystemSupportUserCtrl($scope, UserService, activeUserProfile, ModalService, OrganisationService) {

        $scope.selectedUserId = -1;
        $scope.organisationUsers = {};
        $scope.displayOrganisationUsers = {};
        $scope.selectedOrganisationName = "";
        $scope.addUserErrorMessage = "";

        $scope.getSelectedOrganisationId = function () {

            var selectedOrganisationId = -1;
            if ($scope.selectedOrganisationId) {
                selectedOrganisationId = $scope.selectedOrganisationId;
                OrganisationService.Get(selectedOrganisationId)
                    .then(
                        function successCallback(response) {
                            $scope.selectedOrganisationName = response.data.Name;
                        },
                        function errorCallback(response) {

                        }
                    );
            }
            return selectedOrganisationId;
        };

        $scope.getOrganisationUsers = function (organisationId) {
            UserService.getNonSystemSupportUsers(organisationId)
                .then(
                    function (data) {
                        $scope.organisationUsers = data;
                        $scope.displayOrganisationUsers = $scope.organisationUsers;
                    },
                    function (data) {

                    }
                );
        };

        $scope.selectUser = function (userId) {
            $scope.selectedUserId = userId;
        };

        $scope.makeSupportUser = function (userId) {
            UserService.makeSupportUser(userId, $scope.selectedOrganisationId, activeUserProfile.UserId)
                        .then(
                            function (data) {
                                if (data == false) $scope.errorMessage = "Couldn't make user into a support user.  Please contact support.";
                                $scope.getOrganisationUsers($scope.getSelectedOrganisationId());
                                $scope.getSystemSupportUsers($scope.getSelectedOrganisationId());
                            },
                            function (data) {

                            }
                        );
        }

        $scope.getOrganisationUsers($scope.getSelectedOrganisationId());
    }

})();