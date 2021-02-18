(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('HomeCtrl', HomeCtrl);

    HomeCtrl.$inject = ['$scope', '$location', '$window', "activeUserProfile"];

    function HomeCtrl($scope, $location, $window, activeUserProfile) {


        
        $scope.$root.title = 'IAM.Atlas';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview',
                {
                    'page': $location.path(),
                    'title': $scope.$root.title
                });
        });
    }

})();



