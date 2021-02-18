


(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddExistingSystemFeatureGroupItemCtrl', AddExistingSystemFeatureGroupItemCtrl);

    AddExistingSystemFeatureGroupItemCtrl.$inject = ["$scope", "$window", "$filter", "SystemFeatureService"];

    function AddExistingSystemFeatureGroupItemCtrl($scope, $window, $filter, SystemFeatureService) {

        var systemFeatureService = SystemFeatureService;

        $scope.$parent.successMessage = "";
        $scope.$parent.validationMessage = "";


        $scope.existingFeatureItems = {};

        //Get SystemFeature Settings
        $scope.getExistingFeatureGroupItems = function () {

            $scope.systemFeatureService.GetAddExistingFeatureGroupItemDetails($scope.$parent.selectedFeatureGroup)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.existingFeatureItems = response.data;

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }
        
        //Set Selected Feature Items 
        $scope.setSelectedFeatureItems = function (FeatureItem) {
            FeatureItem.isSelected ? FeatureItem.isSelected = false : FeatureItem.isSelected = true;
        }

        //Add Selected Feature Items 
        $scope.Save = function () {

            var featuredItems = {
                selectedItems: []
            };

            featuredItems.SystemFeatureGroupId = $scope.$parent.selectedFeatureGroup;

            //Filter out Selected Emails for removal
            var selectedItems = $filter("filter")($scope.existingFeatureItems, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedItems.forEach(function (arrayItem) {
                var x = arrayItem.Id
                featuredItems.selectedItems.push(x);
            });

            $scope.systemFeatureService.SaveAddExistingFeatureGroupItems(featuredItems)
                .then(
                    function (response) {

                        // refresh the existing list 
                        $scope.getExistingFeatureGroupItems($scope.$parent.selectedFeatureGroup);

                        // refresh the feature groups
                        $scope.$parent.getFeatureGroupItem($scope.$parent.selectedFeatureGroup);

                        $scope.successMessage = "Add Successful";
                        $scope.validationMessage = "";
                    },
                    function (response) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }

        $scope.HasItemsSelected = function () {

            if ($scope.existingFeatureItems.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.getExistingFeatureGroupItems();

    }

})();
