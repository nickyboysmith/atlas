(function () {
    'use strict';

    angular
        .module('app')
        .controller('PaymentReconciliationCtrl', PaymentReconciliationCtrl);

    PaymentReconciliationCtrl.$inject = ["$scope", "PaymentReconciliationService", "UserService", "activeUserProfile", "DateFactory", "ModalService"];

    function PaymentReconciliationCtrl($scope, PaymentReconciliationService, UserService, activeUserProfile, DateFactory, ModalService) {

        $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        $scope.isSystemAdmin = activeUserProfile.IsSystemAdmin;
        $scope.selectedConfiguration = {};
        $scope.reconciliationDatas = [];
        $scope.reconciliationDatasTemplate = [];
        $scope.maxResults = 15;

        $scope.getOrganisations = function (userID) {

            UserService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;

                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getPaymentReconciliationList = function (organisationId) {
            //$scope.organisationId = organisationId;
            PaymentReconciliationService.getPaymentReconciliationList(organisationId)
                .then(function (response) {
                    $scope.reconciliationConfigurations = response;
                    $scope.selectedConfiguration = response[0];
                });
        }

        $scope.getPaymentReconciliationData = function (reconciliationId) {
            //$scope.organisationId = organisationId;
            PaymentReconciliationService.getPaymentReconciliationData(reconciliationId)
                .then(function (response) {
                    $scope.reconciliationDatas = response;
                    $scope.reconciliationDatasTemplate = $scope.reconciliationDatas;
                });
        }

        $scope.openNewReconciliationModal = function () {
                ModalService.displayModal({
                    scope: $scope,
                    title: "New Reconciliation",
                    cssClass: "newPaymentReconciliation",
                    filePath: "/app/components/paymentReconciliation/new.html",
                    controllerName: "NewPaymentReconciliationCtrl",
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
        $scope.getPaymentReconciliationList($scope.organisationId);

    }
})();