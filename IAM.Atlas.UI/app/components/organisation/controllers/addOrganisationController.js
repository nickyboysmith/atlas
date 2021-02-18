


(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddOrganisationCtrl', AddOrganisationCtrl);

    AddOrganisationCtrl.$inject = ["$scope", "$window", "OrganisationService"];

    function AddOrganisationCtrl($scope, $window, OrganisationService)
    {

        var organisationService = OrganisationService;
        $scope.$parent.successMessage = "";
        $scope.$parent.validationMessage = "";


        $scope.organisation = {
            Name: "",
            CreatedByUserId: ""
        };

        $scope.saveNewOrganisation = function () {

                $scope.newOrganisation = {

                    Name: $scope.organisation.Name,
                    CreationTime: "",
                    Active: "",
                    CreatedByUserId: $scope.$parent.userId
                };

                organisationService.CreateNew($scope.newOrganisation)

                .then(
                        function (response) {
                            console.log("Success");
                            console.log(response.data);

                            $scope.successMessage = "Save Successful";
                            $scope.validationMessage = "";
                        
                            // refresh organisation list
                            $scope.$parent.getOrganisations($scope.$parent.userId);
                        },
                        function (response) {
                            console.log("Error");
                            console.log(response);
                            $scope.successMessage = "";
                            $scope.validationMessage = "An error occurred please try again.";
                        }
                    );
            
        }

        $scope.HasOrganisationName = function () {

            if ($scope.organisation.Name.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

    }

})();
