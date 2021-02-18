(function () {
    'use strict';

    angular
        .module('app')
        .controller('ReconciliationConfigurationCtrl', ReconciliationConfigurationCtrl);

    ReconciliationConfigurationCtrl.$inject = ["$scope", "ReconciliationConfigurationService", "UserService", "activeUserProfile", "DateFactory", "ModalService"];

    function ReconciliationConfigurationCtrl($scope, ReconciliationConfigurationService, UserService, activeUserProfile, DateFactory, ModalService) {

        $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            UserService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                UserService.checkSystemAdminUser(userID)
                .then(function (data) {
                    $scope.isAdmin = data;
                });
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;

                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getPaymentReconciliationData = function (organisationId) {
            $scope.organisationId = organisationId;
            ReconciliationConfigurationService.getPaymentReconciliationData(organisationId)
                .then(function (response) {
                    $scope.reconciliationConfigurations = response;
                    $scope.selectedConfiguration = response[0];
                });
        }

        $scope.selectConfiguration = function (reconciliationConfig) {
            $scope.selectedConfiguration = reconciliationConfig;
        }

        $scope.newConfig = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "New Configuration",
                closable: true,
                filePath: "/app/components/reconciliationConfiguration/add.html",
                controllerName: "AddReconciliationConfigurationCtrl",
                cssClass: "addReconciliationConfiguration",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.getOrganisations(activeUserProfile.UserId);
        $scope.getPaymentReconciliationData($scope.organisationId);
    }
})();