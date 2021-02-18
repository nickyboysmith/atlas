(function () {
    'use strict';

    angular
        .module('app')
        .controller('WebAPITestCtrl', ['$scope', '$location', '$window', '$http',  WebAPITestCtrl]);

    function WebAPITestCtrl($scope, $location, $window, $http) {

        $scope.getValues = function () {
            $scope.processing = true;
            $http
                .get('http://localhost:63103/api/values')
                .then(function (data, status, headers, config) {
                    alert('hooray');
                    $scope.values = data;
                }, function(data, status, headers, config) {
                    alert('error : (');
                });

        }
    }

})();