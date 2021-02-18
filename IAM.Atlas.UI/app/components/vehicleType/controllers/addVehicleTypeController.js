(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddVehicleTypeCtrl', AddVehicleTypeCtrl);

    AddVehicleTypeCtrl.$inject = ['$scope', '$location', '$window', '$http', 'VehicleTypeService'];

    function AddVehicleTypeCtrl($scope, $location, $window, $http, VehicleTypeService) {

        $scope.vehicleType = {
            VehicleTypeName: "",
            VehicleTypeDescription: "",
            VehicleTypeDisabled: false,
            VehicleTypeAutomatic: false,
            OrganisationId: $scope.$parent.organisationId,
            CreatedByUserId: $scope.$parent.userId
        };

        $scope.addVehicleType = function () {

            if ($scope.validateVehicleType()) {

                VehicleTypeService.addVehicleType($scope.vehicleType)
                    .then(
                        function (response) {
                            $scope.$parent.getVehicleTypes($scope.$parent.organisationId);
                            $('button.close').last().trigger('click');
                        },
                        function (response) {

                        }
                    );
            }
        }

        $scope.validateVehicleType = function () {

            $scope.validationMessage = '';

            if ($scope.vehicleType.VehicleTypeName.length == 0) {
                $scope.validationMessage = "Please enter a Vehicle Type Name.";
            }
            
            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }
    }

})();