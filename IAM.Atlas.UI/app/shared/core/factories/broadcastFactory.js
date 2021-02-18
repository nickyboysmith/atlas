(function () {


     //.factory('broadcastService', function ($rootScope) {
    //    return {
    //        send: function(msg, data) {
    //            $rootScope.$broadcast(msg, data);
    //        }
    //    }
    //});

    'use strict';

    angular
        .module("app")
        .factory('broadcastService', broadcastService);
    
    function broadcastService($rootScope) {
        return {
            send: function(msg, data) {
                $rootScope.$broadcast(msg, data);
            }
        }
    }
});


   