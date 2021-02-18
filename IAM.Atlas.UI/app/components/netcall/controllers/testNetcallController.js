(function () {

    'use strict';

    angular
        .module("app")
        .controller("TestNetcallCtrl", TestNetcallCtrl);

    TestNetcallCtrl.$inject = ["$scope", "activeUserProfile", "ModalService", "DateFactory", "NetcallService"];

    function TestNetcallCtrl($scope, activeUserProfile, ModalService, DateFactory, NetcallService) {

        $scope.appContext = 'TestAppContext';
        $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        $scope.requestId = '';
        $scope.accountDetail = null;
        $scope.accountPaymentResult = null;

        $scope.guid = function() {
            function s4() {
                return Math.floor((1 + Math.random()) * 0x10000)
                    .toString(16)
                    .substring(1);
            }
            return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                s4() + '-' + s4() + s4() + s4();
        }

        $scope.testNetcall = function (agentsPhoneExtension, netcallPaymentResult) {
            $scope.requestId = $scope.guid();
            NetcallService.getAccountDetails($scope.requestId, $scope.appContext, agentsPhoneExtension)
                .then(
                    function successCallback(response) {
                        $scope.accountDetail = response.data;
                        if ($scope.accountDetail.AmountToPay > 0) {
                            if (netcallPaymentResult != '') {
                                NetcallService.postAccountPaymentResult($scope.requestId, $scope.appContext, $scope.accountDetail.ClientID, netcallPaymentResult, $scope.requestId)
                                    .then(
                                        function successCallback(response) {
                                            $scope.accountPaymentResult = response.data;
                                        },
                                        function errorCallback(response) {
                                            $scope.validationMessage = "There was an error during the Post Account Payment Result function.";
                                        }
                                    );
                            }
                            else {
                                $scope.validationMessage = "Netcall payment result is not set.";
                            }
                        }
                        else {
                            $scope.validationMessage = "Amount to pay is zero.";
                        }
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = "There was an error during the Get Account Details function.";
                    }
                );
        }

        $scope.formatDate = function (date) {
            var formattedDate = DateFactory.formatDateSlashes(DateFactory.parseDate(date));
            return formattedDate;
        }
    };


})();