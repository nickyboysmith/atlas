(function () {
    'use strict';

    angular
        .module('app')
        .controller('addClientPaymentCtrl', ['$scope', '$location', '$window', '$http', addClientPaymentCtrl])
        .directive('blurCurrency', blurCurrency);

    function blurCurrency($filter) {

        function link(scope, el, attrs, ngModelCtrl) {

            function formatter(value) {
                value = parseFloat(value.toString().replace(/[^0-9._-]/g, ''));
                var formattedValue = $filter('currency')(value, '£');
                el.val(formattedValue);
                return formattedValue;
            }

            ngModelCtrl.$formatters.push(formatter);

            // clears out the textbox on focus
            //el.bind('focus', function () {
            //    el.val('');
            //});

            el.bind('blur', function () {
                formatter(el.val());
            });
        }

        return {
            require: '^ngModel',
            scope: true,
            link: link
        };
    }

    blurCurrency.$inject = ['$filter'];

    function addClientPaymentCtrl($scope, $location, $window, $http) {
    
        $scope.clientPayment = new Object();

        $scope.clientPayment.selectedPaymentType = null;
        $scope.clientPayment.selectedPaymentMethod = null;
        $scope.clientPayment.selectedAdditionalPaymentMethod = null;

        $scope.clientPayment.amount = "";
        $scope.clientPayment.additionalAmount = "";
     
        $scope.paymentTypes = [];
        $scope.paymentMethods = [];
        $scope.additionalPaymentMethods = [];

        $scope.clientPayment.ClientId = $scope.clientId;

        $scope.displayCalendar = false;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
       
        if ($scope.clientPayment.ClientId == undefined) {
            $scope.clientPayment.ClientId = $location.search().clientid;
        }

        // TODO : get the user id
        $scope.clientPayment.UserId = 1;

        $scope.sumTotals= function () {
            var total = 0;
            total = Number($scope.clientPayment.amount.replace(/[^\d.-]/g, '')) + Number($scope.clientPayment.additionalAmount.replace(/[^\d.-]/g, ''));
            return total;
        }

        $scope.hasError = function (modelController, error) {
            return (modelController.$dirty || $scope.submitted) && error;
        }


        

        $scope.getPaymentTypes = function () {
            $http.get(apiServer + '/ClientPayment/GetPaymentTypes')
                .then(function (response, status, headers, config) {
                   
                    $scope.paymentTypes = response.data;
                    $scope.clientPayment.paymentTypeId = $scope.paymentTypes[0].Id;
                }, function (response, status, headers, config) {
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.getPaymentMethods = function () {
            $http.get(apiServer + '/ClientPayment/GetPaymentMethods')
                .then(function (response, status, headers, config) {
                    
                    $scope.paymentMethods = response.data;
                    $scope.clientPayment.paymentMethodId = $scope.paymentMethods[0].Id;

                    $scope.additionalPaymentMethods = data;
                    $scope.clientPayment.additionalPaymentMethodId = $scope.additionalPaymentMethods[0].Id;

                }, function(data, status, headers, config) {
                   
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.addPayment = function () {

            //if ($scope.clientPaymentForm.$invalid) return;
            //$scope.clientPayment = PavmentService.save();
            //$scope.clientPaymentForm.$setPristine();

            validateForm();

            if ($scope.validationMessage == "") {


                $http.post(apiServer + '/ClientPayment/', $scope.clientPayment)
                    .then(function (data, status, headers, config) {

                        $scope.showSuccessFader = true;
                        
    
                        $scope.validationMessage = "Success.";
                    }, function (data, status, headers, config) {

                        $scope.showErrorFader = true;

                        $scope.validationMessage = "An error occurred please try again.";
                    });
            }
        }

        function validateForm() {

            $scope.validationMessage = '';


            if ($scope.clientPayment.selectedPaymentType == null) {
                $scope.validationMessage = "Please select a payment type.";
            }

            else if ($scope.clientPayment.selectedPaymentMethod == null) {
                $scope.validationMessage = "Please select a payment method.";
            }

            else if ($scope.clientPayment.amount <= 0) {
                $scope.validationMessage = "Please enter a payment amount.";
            }

            else if ($scope.clientPayment.transactionDate > Date.now()) {
                $scope.validationMessage = "You cannot enter a date in the future.";

            }
            
        }



        $scope.cancelPayment = function () {

        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.getPaymentTypes();
        $scope.getPaymentMethods();


    }
})();
