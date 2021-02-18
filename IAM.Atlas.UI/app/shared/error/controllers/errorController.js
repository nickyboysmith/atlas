(function () {
    'use strict';
    angular
        .module('app.controllers')
        .controller('ErrorCtrl', ['$scope', '$location', '$window', ErrorCtrl]);

    function ErrorCtrl ($scope, $location, $window) {
        $scope.$root.title = 'Error 404: Page Not Found';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });
    }
})();


