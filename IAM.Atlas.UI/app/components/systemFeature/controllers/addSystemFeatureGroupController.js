


(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddSystemFeatureGroupCtrl', AddSystemFeatureGroupCtrl);

    AddSystemFeatureGroupCtrl.$inject = ["$scope", "$window", "SystemFeatureService"];

    function AddSystemFeatureGroupCtrl($scope, $window, SystemFeatureService) {

        var systemFeatureService = SystemFeatureService;

        $scope.$parent.successMessage = "";
        $scope.$parent.validationMessage = "";


        $scope.featureGroup = {
            Name: "",
            Title: "",
            Description:""
        };

        $scope.saveFeatureGroup = function () {

            $scope.newFeatureGroup = {
                Id: 0,
                Name: $scope.featureGroup.Name,
                Title: $scope.featureGroup.Title,
                Description: $scope.featureGroup.Description,
                SystemAdministratorOnly: false,
                OrganisationAdministratorOnly: false,
                UpdatedByUserId: $scope.$parent.userId,
                DateUpdated: new Date(),
                Disabled: false,
                
            };

            systemFeatureService.SaveFeatureGroup($scope.newFeatureGroup)

            .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);

                        $scope.successMessage = "Save Successful";
                        $scope.validationMessage = "";

                        // refresh the feature groups
                        $scope.$parent.getFeatureGroups();
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );

        }

        $scope.HasFeatureGroupName = function () {

            if ($scope.featureGroup.Name.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

    }

})();
