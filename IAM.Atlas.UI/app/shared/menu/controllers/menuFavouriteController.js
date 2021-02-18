

// THIS CONTROLLER CAN BE REMOVED FROM PROJECT
//(function () {
//    'use strict';

//    angular
//        .module('app.controllers')
//        .controller('MenuFavouriteCtrl', ["$scope", "$location", "$window", "$compile", "MenuFavouriteService", MenuFavouriteCtrl]);
//    //MenuFavouriteCtrl.$inject = ["$scope", "$location", "$window", "$compile", "$http", "menuFavouriteService"];
    

//    //function MenuFavouriteCtrl($scope, $http, $location, $window, $compile, menuFavouriteService) {
//    function MenuFavouriteCtrl($scope, $location, $window, $compile, MenuFavouriteService) {

//        $scope.$on('savemenufavourite', function (event, args) {
//            //$scope.getList();
//            $scope.menuFavouriteEntries = MenuFavouriteService.saveMenuFavourites(1);
//        })

//        $scope.menuFavouriteEntries = MenuFavouriteService.getMenuFavourites(1);

//        $scope.routeIs = function(routeName) {  
//            return $location.path() === routeName;  
//            };  



//        $scope.ShowMenuItem = function (title, url, controller, enabled, modal) {
//            if (enabled == 'true') {
//                if (modal == true) {
//                    BootstrapDialog.show({
//                        scope: $scope,
//                        title: title,
//                        closable: true,
//                        closeByBackdrop: false,
//                        closeByKeyboard: false,
//                        draggable: true,
//                        cssClass: "AtlasModal",
//                        message: function (dialog) {
//                            var pageToLoad = dialog.getData('pageToLoad');
//                            return $compile('<div ng-app="app" ng-controller="' + controller + '" ng-include="\'' + pageToLoad + '.cshtml\'"></div>')($scope);
//                        },
//                        data: {
//                            'pageToLoad': url
//                        }
//                    });
//                } else {
//                    $location.url(url);
//                }
//            }
//        }

//    }

//})();