(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('ukVATRatesCtrl', ukVATRatesCtrl);

    ukVATRatesCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'VatService', 'DateFactory', 'activeUserProfile'];

    function ukVATRatesCtrl($scope, $location, $window, $http, $filter, VatService, DateFactory, activeUserProfile) {

        $scope.vatRates = {};
        $scope.currentVatRate = null;
        $scope.selectedVatRate = null;

        $scope.findCurrentVatRate = function () {
            var currentDate = new Date();
            for (var i = 0; i < $scope.vatRates.length; i++){
                var vatRateEffectiveFromDate = DateFactory.parseDate($scope.vatRates[i].EffectiveFromDate);
                if (vatRateEffectiveFromDate < currentDate) {
                    // this is the current date as the vatRates are ordered by effectiveFromDate desc
                    $scope.currentVatRate = $scope.vatRates[i];
                    break;
                }
            }
        }

        $scope.loadHistory = function () {
            $scope.statusMessage = '';
            VatService.getList()
                .then(
                    function successCallback(response) {
                        $scope.vatRates = response;
                        if ($scope.vatRates.length > 0) {
                            $scope.findCurrentVatRate();
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.deleteSelectedVatRate = function () {
            VatService.delete($scope.selectedVatRate.VatRateId, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        $scope.statusMessage = "VAT Rate deleted";
                        $scope.selectedVatRate = null;
                        $scope.loadHistory();
                    },
                    function errorCallback(response) {
                        $scope.statusMessage = "An Error occurred VAT Rate not deleted";
                    }
                );
        }

        $scope.selectVatRate = function (vatRate) {
            $scope.selectedVatRate = vatRate;
        }

        $scope.formatDateyyyyMondd = function (date) {
            return DateFactory.formatDateyyyyMondd(DateFactory.parseDate(date));
        }

        $scope.formatDateddMONyyyy = function (date) {
            return DateFactory.formatDateddMONyyyy(DateFactory.parseDate(date));
        }

        $scope.addUKVatRateModal = function(){
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add New VAT Rate",
                cssClass: "addUKVATRateModal",
                filePath: "/app/components/vat/addUKVATRate.html",
                controllerName: "addUKVATRateCtrl"                
            });
        }

        $scope.loadHistory();
    }

})();

