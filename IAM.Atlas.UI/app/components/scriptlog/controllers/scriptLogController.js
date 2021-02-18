(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ScriptLogCtrl', ['$scope', '$location', '$window', '$http', ScriptLogCtrl]);

    function ScriptLogCtrl($scope, $location, $window, $http) {

        $scope.$root.title = 'IAM.Atlas | Script Log';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });

        $scope.getList = function () {
            $scope.isProcessing = true;
            //debugger;
            $http
                .get('/api/ScriptLog/Get')
                .then(function (data, status, headers, config) {
                    $scope.isProcessing = false;
                    $scope.ScriptLog = data;
                });
            $scope.message = "Hi There";
        }
    }

})();
