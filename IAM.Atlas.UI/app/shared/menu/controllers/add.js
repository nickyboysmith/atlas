(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('addMenuFavouriteCtrl', ['$scope', '$location', '$window', '$http', addMenuFavouriteCtrl]);

    function addMenuFavouriteCtrl($scope, $location, $window, $http) {

        $scope.menuFavourite = new Object();


        $scope.addMenuFavourite = function () {

            // temp hardcode values
            $scope.menuFavourite.UserId = 1;
            $scope.menuFavourite.Title = 'Add Client'
            $scope.menuFavourite.Link = 'app/components/client/addclientview';
            $scope.menuFavourite.Parameters = 'addClientCtrl';
            $scope.menuFavourite.Modal = true;

            //$http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

            $http.post('http://localhost:63105/api/menuFavourite', $scope.menuFavourite)

                //$http.post(apiServer + '/client', $scope.client)
                .success(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available
                    if (data.toLowerCase().indexOf("success")) {
                        $scope.validationMessage = "All OK.";
                    }
                    else {
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                })
                .error(function (data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });

        }


        $scope.addMenuFavourite();
    }

})