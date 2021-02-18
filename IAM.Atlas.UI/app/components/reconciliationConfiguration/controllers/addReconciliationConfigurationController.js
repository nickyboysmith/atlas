(function () {
    'use strict';

    angular
        .module('app')
        .controller('AddReconciliationConfigurationCtrl', AddReconciliationConfigurationCtrl);

    AddReconciliationConfigurationCtrl.$inject = ["$scope", "ReconciliationConfigurationService", "UserService", "activeUserProfile", "DateFactory"];

    function AddReconciliationConfigurationCtrl($scope, ReconciliationConfigurationService, UserService, activeUserProfile, DateFactory) {

        $scope.newConfig = {};
        $scope.validationMessage = "";

        $scope.newConfig.createdByUserId = activeUserProfile.UserId;
        $scope.newConfig.organisationId = $scope.$parent.organisationId;

        $scope.save = function () {
            $scope.validationMessage = "";
            if (!$scope.newConfig.Name) {
                $scope.validationMessage = "Please enter a name for this configuration to proceed."
            }

            if (!$scope.newConfig.transactionDateColumnNumber) {
                $scope.validationMessage = "Please populate Date Column Number to proceed."
            }

            if (!$scope.newConfig.transactionAmountColumnNumber) {
                $scope.validationMessage = "Please populate Amount Column Number to proceed."
            }

            if ($scope.newConfig.transactionDateColumnNumber % 1 != 0 ||
                $scope.newConfig.transactionAmountColumnNumber % 1 != 0) {
                $scope.validationMessage = "Only whole numbers can be accepted."
            }

            if ($scope.newConfig.reference1ColumnNumber) {
                if ($scope.newConfig.reference1ColumnNumber % 1 != 0 ) {
                    $scope.validationMessage = "Only whole numbers can be accepted."
                }
            }
            if ($scope.newConfig.reference2ColumnNumber) {
                if ($scope.newConfig.reference2ColumnNumber % 1 != 0) {
                    $scope.validationMessage = "Only whole numbers can be accepted."
                }
            }
            if ($scope.newConfig.reference3ColumnNumber) {
                if ($scope.newConfig.reference3ColumnNumber % 1 != 0) {
                    $scope.validationMessage = "Only whole numbers can be accepted."
                }
            }
            if (!$scope.newConfig.reference1ColumnNumber && !$scope.newConfig.reference2ColumnNumber && !$scope.newConfig.reference3ColumnNumber) {
                $scope.validationMessage = "At least one reference field must be populated";
            }

            if (!$scope.validationMessage) {
                ReconciliationConfigurationService.saveNewReconciliationData($scope.newConfig)
                    .then(
                    function (response) {
                        if (response == true) {
                            $scope.validationMessage = "Saved successfully";
                            $scope.$parent.getPaymentReconciliationData($scope.$parent.organisationId);
                        } else {
                            $scope.validationMessage = "Unable to save. Please contact support."
                        }
                    });
            }
        }
    }
})();