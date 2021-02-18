(function () {

    'use strict';

    angular
        .module("app")
        .controller("SystemFeatureInformationDirectiveCtrl", SystemFeatureInformationDirectiveCtrl);

    SystemFeatureInformationDirectiveCtrl.$inject = ["$scope", "activeUserProfile"];

    function SystemFeatureInformationDirectiveCtrl($scope, activeUserProfile) {

        console.log($scope);


        /**
         * Initialize the emitName
         */
        $scope.emitName;

        /**
         * Call the emit method
         * Based on what button is clicked
         */
        $scope.buildEmitMethod = function (emitName, objectToPass) {
            $scope.$emit(emitName, objectToPass);
        };

        /**
         * Save to favourite
         */
        $scope.addToFavourite = function () {
            $scope.emitName = "savemenufavourite";
            $scope.buildEmitMethod($scope.emitName, {
                UserId: activeUserProfile.UserId,
                Title: $scope.title,
                Link: $scope.viewPath,
                Parameters: $scope.controller,
                Modal: $scope.openInModal
            });
        };

        /**
         * Show feature information
         */
        $scope.showFeatureInformation = function () {
            $scope.emitName = "displaySystemFeatureInformation";
            $scope.buildEmitMethod($scope.emitName, {
                systemFeaturePageName: $scope.pageName
            });
        };

    }

})();