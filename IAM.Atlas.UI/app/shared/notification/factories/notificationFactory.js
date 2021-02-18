//(function () {


//    'use strict';

//    angular
//        .module("app")
//        .factory("NotificationFactory", NotificationFactory);
        
//    NotificationFactory.$inject = ["$http"];
    
//    function NotificationFactory($http) {

//        //var userid = "1";
//        var NotificationFactory = this;
//        //var messages = [];

//        NotificationFactory.getMessages = function () {
//            var webServiceEndpoint = apiServer + "/notification/";
//            return $http.get(webServiceEndpoint)
//                .then(function (response) {
//                    //messages = response.data;
//                    //return messages;
//                })
//                .error(function (response) {
//                });
  
//        };
//    }

//})();

        //(function () {


        //    'use strict';

        //    angular
        //        .module("app")
        //        .service("MenuFavouriteService", MenuFavouriteService);
        

        //    MenuFavouriteService.$inject = ["$http"];
    
        //    function MenuFavouriteService($http) {

        //        var userid = "1";
        //        var menuFavouriteService = this;

        //        menuFavouriteService.getMenuFavourite = function (userId) {
        //            var webServiceEndpoint = apiServer + "/menuFavourite/" + userId;
        //            return $http.get(webServiceEndpoint)
        //                .then(function (data) {
        //                })
        //                .error(function (data) {
        //                });
  
        //        };

//var notificationModule = angular.module("app", []);
//  notificationModule.factory('notificationmessages', ['$http', '$rootScope', function ($http, $rootScope) {
//  var messages = [];

//  return {
//    getMessages: function() {
//      return $http.get(apiServer + '/notification/get').then(function(response) {
//        messages = response.data;
//        return messages;
//      })
//    }
//  };
//}]);




//      var notificationModule = angular.module('notificationModule', []);

//notificationModule.factory('sharednotifications', ['$http', '$rootScope', function($http, $rootScope) {
//  var orders = [];

//  return {
//    getNotifications: function() {
//      return $http.get(base_url + 'notification/getNotifications').then(function(response) {
//        notifications = response.data;
//        return notifications;
//      })
//    }
//  };
//}]);

//notificationModule.controller('notifications', function($scope,$timeout,sharednotifications) {
//  $scope.name = 'notifications';
//  (function tock() {
//    sharednotifications.getNotifications().then(function(notifications) {
//      $scope.notifications = notifications;
//      $timeout(tock, 5000);
//    });
//  })();  
//});





//(function () {

//    'use strict';

//    angular
//        .module("app")
//        .factory('broadcastService', broadcastService);

//    function broadcastService($rootScope) {
//        return {
//            send: function (msg, data) {
//                $rootScope.$broadcast(msg, data);
//            }
//        }
//    }
//});