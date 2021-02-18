(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('addUKVATRateCtrl', addUKVATRateCtrl);

    addUKVATRateCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'VatService', 'DateFactory', 'activeUserProfile'];

    function addUKVATRateCtrl($scope, $location, $window, $http, $filter, VatService, DateFactory, activeUserProfile) {

        $scope.vatRateToAdd = '';
        $scope.vatRateToAddEffectiveFromDate = '';
        $scope.displayCalendar = false;

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }
        
        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }

        $scope.addUKVATRate = function (vatRateToAdd, vatRateToAddEffectiveFromDate) {
            VatService.addUKVATRate(vatRateToAdd, vatRateToAddEffectiveFromDate, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        if (response.ExceptionMessage) {
                            $scope.statusMessage = response.ExceptionMessage;
                        }
                        else {
                            if (response > 0) {
                                $scope.statusMessage = "VAT Rate added";
                                if ($scope.loadHistory) {
                                    $scope.loadHistory();
                                }
                            }
                            else {
                                $scope.statusMessage = "VAT Rate not added";
                            }
                        }
                    },
                    function errorCallback(response) {
                        if (response.data) {
                            $scope.statusMessage = response.data.message;
                        }
                        else {
                            $scope.statusMessage = "An error occurred, VAT Rate might not be added.";
                        }
                    }
                );
        }
    }

})();

