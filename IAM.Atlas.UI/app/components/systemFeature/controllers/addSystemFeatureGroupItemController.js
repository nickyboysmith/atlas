


(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddSystemFeatureGroupItemCtrl', AddSystemFeatureGroupItemCtrl);

    AddSystemFeatureGroupItemCtrl.$inject = ["$scope", "$window", "SystemFeatureService"];

    function AddSystemFeatureGroupItemCtrl($scope, $window, SystemFeatureService) {

        var systemFeatureService = SystemFeatureService;

        $scope.$parent.successMessage = "";
        $scope.$parent.validationMessage = "";


        $scope.featureGroupItem = {
            Name: "",
            Title: "",
            Description: ""
        };

        $scope.saveFeatureGroupItem = function () {

            $scope.newFeatureGroupItem = {
                Id: 0,
                Name: $scope.featureGroupItem.Name,
                Title: $scope.featureGroupItem.Title,
                Description: $scope.featureGroupItem.Description,
                SystemAdministratorOnly: false,
                OrganisationAdministratorOnly: false,
                UpdatedByUserId: $scope.$parent.userId,
                DateUpdated: new Date(),
                Disabled: false
            };

            $scope.newFeatureGroupItem.SystemFeatureGroupId = $scope.$parent.selectedFeatureGroup;

            systemFeatureService.SaveFeatureGroupItem($scope.newFeatureGroupItem)
            .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);

                        $scope.successMessage = "Save Successful";
                        $scope.validationMessage = "";

                        // refresh the feature groups
                        $scope.$parent.getFeatureGroupItem($scope.$parent.selectedFeatureGroup);
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );

        }

        $scope.HasFeatureGroupItemName = function () {

            if ($scope.featureGroupItem.Name.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

    }

})();
