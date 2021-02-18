(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('PaymentProviderCtrl', PaymentProviderCtrl);

    PaymentProviderCtrl.$inject = ["$scope", "$http", "$window", "UserService", "activeUserProfile", "PaymentProviderService"];

    function PaymentProviderCtrl($scope, $http, $window, UserService, activeUserProfile, PaymentProviderService)
    {

        $scope.paymentProviderService = PaymentProviderService;

        $scope.paymentProviders = {};
        $scope.paymentProviderDetails = {};
        
        $scope.userId = activeUserProfile.UserId;
        
        $scope.userService = UserService;

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        $scope.getPaymentProviders = function () {

            $scope.paymentProviderService.getPaymentProviders()

                .then(function (data) {

                    $scope.paymentProviders = data;

                    if ($scope.paymentProviders.length > 0) {

                        $scope.selectedPaymentProvider = $scope.paymentProviders[0].Id;
                        $scope.selectPaymentProvider($scope.selectedPaymentProvider);
                    }

                },
                function (data) {
                    
                });
        };


        // Selected Payment Provider
        $scope.selectPaymentProvider = function (selectedPaymentProvider) {

            $scope.selectedPaymentProvider = selectedPaymentProvider;

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.paymentProviderService.getPaymentProviderDetailsByPaymentProviderId($scope.selectedPaymentProvider)
                .then(
                    function (data) {
                        console.log("Success");
                        $scope.paymentProviderDetails = data[0];

                    },
                    function (data) {
                        console.log("Error");
                        console.log(data);
                    }
                );
        }

        $scope.savePaymentProvider = function () {

            if ($scope.validateForm()) {

                if (!angular.equals({}, $scope.paymentProviderDetails)) {

                    $scope.paymentProviderService.savePaymentProvider($scope.paymentProviderDetails)
                        .then(
                            function (data) {
                                console.log("Success");

                                $scope.paymentProviderDetails.Id = data;
                                $scope.getPaymentProviders();
                                $scope.paymentProviders.Id = $scope.paymentProviderDetails.Id;
                                $scope.selectedPaymentProvider = $scope.paymentProviders.Id;

                                $scope.successMessage = "Save Sucessful";
                                $scope.validationMessage = "";
                            },
                            function (data) {
                                console.log("Error");
                                console.log(data);
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            }
                        );
                }
            }
        }

        $scope.addPaymentProvider = function () {
            // reset paymentProvider Details
            $scope.paymentProviderDetails = {};
            $scope.successMessage = "";
            $scope.validationMessage = "";
        }

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (angular.isUndefined($scope.paymentProviderDetails.Name)) {
                $scope.validationMessage = "Please Enter a Payment Provider Name. \r ";
            }
            else if ($scope.paymentProviderDetails.Name.length == 0) {
                $scope.validationMessage = "Please Enter a Payment Provider Name. \r ";
            }

            if (angular.isUndefined($scope.paymentProviderDetails.Notes)) {
                $scope.validationMessage = $scope.validationMessage + "Please Supply a Payment Provider Note. ";
            }
            else if ($scope.paymentProviderDetails.Notes.length == 0) {
                $scope.validationMessage = $scope.validationMessage + "Please Supply a Payment Provider Note. ";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getPaymentProviders();

    } 
})();