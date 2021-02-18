(function () {

    'use strict';

    angular
        .module("app")
        .controller("DORSLicenceCheckCtrl", DORSLicenceCheckCtrl);

    DORSLicenceCheckCtrl.$inject = ["$scope", "activeUserProfile", "DorsService", "ClientService", "DateFactory"]

    function DORSLicenceCheckCtrl($scope, activeUserProfile, DorsService, ClientService, DateFactory) {
        
        $scope.model = {
            LicenceNumber: "",
            CurrentLicenceNumber: "",
            ClientStatuses: [],
            ClientsWithLicenceNumber: []
        }

        $scope.LicenceNumber = {};

        $scope.getDORSLicenceInformation = function () {
            
            if ($scope.model.LicenceNumber != "") {

                $scope.model.CurrentLicenceNumber = $scope.model.LicenceNumber;

                DorsService.getClientStatuses($scope.model.LicenceNumber, activeUserProfile.selectedOrganisation.Id)
                    .then(
                        function success(response) {
                            $scope.model.ClientStatuses = response.data;
                        },
                        function error(response) {
                            return response.data;
                        }
                    );

                ClientService.getClientsByLicence($scope.model.LicenceNumber, activeUserProfile.selectedOrganisation.Id)
                    .then(
                        function success(response) {
                            $scope.model.ClientsWithLicenceNumber = response.data;
                        },
                        function error(response) {
                            return response.data;
                        }
                    );
            }
        }

        $scope.formatDate = function(date){
            //return date.toLocaleString();
            return DateFactory.formatDateSlashes(DateFactory.parseDate(date));
        }
    }

})();