(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddVehicleCategoryCtrl', AddVehicleCategoryCtrl);

    AddVehicleCategoryCtrl.$inject = ['$scope', '$location', '$window', '$http', 'VehicleCategoryService'];

    function AddVehicleCategoryCtrl($scope, $location, $window, $http, VehicleCategoryService) {

        $scope.vehicleCategory = {
            VehicleCategoryName: "",
            VehicleCategoryDescription: "",
            VehicleCategoryDisabled: false,
            OrganisationId: $scope.$parent.organisationId,
            AddedByUserId: $scope.$parent.userId
        };

        $scope.addVehicleCategory = function () {

            if ($scope.validateVehicleCategory()) {

                VehicleCategoryService.addVehicleCategory($scope.vehicleCategory)
                    .then(
                        function (response) {
                            $scope.$parent.getVehicleCategories($scope.$parent.organisationId);
                            $('button.close').last().trigger('click');
                        },
                        function (response) {

                        }
                    );
            }
        }

        $scope.validateVehicleCategory = function () {

            $scope.validationMessage = '';

            if ($scope.vehicleCategory.VehicleCategoryName.length == 0) {
                $scope.validationMessage = "Please enter a Vehicle Category Name.";
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