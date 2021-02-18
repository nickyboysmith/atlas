(function () {
    'use strict';

    angular
        .module('app')
        .controller('NotificationCtrl', NotificationCtrl);


    NotificationCtrl.$inject = ['$scope', '$location', '$window', '$http'];

    function NotificationCtrl($scope, $location, $window, $http) {
        
        $scope.$root.title = 'System Messages';
        var userId = 1;
        $scope.showContentX = -1;
        
        var webServiceEndpoint = apiServer + "/notification/" + userId;
        $http.get(webServiceEndpoint)
            .then(function (data) {
                $scope.messages = data.data.messageCategory[0].message;
            }, function (data) {
                console.log("There has been an error processing the request.")
            });

        $scope.showMessageContent = function (messageIndex) {
            $scope.showContentX = messageIndex;
        }

        $scope.hideMessageContent = function () {
            $scope.showContentX = -1;
        }

        $scope.firstLine = function (message) {
            var first = message;
            if (message.indexOf('\n') > -1)
            {
                first = message.split('\n')[0] + '...';
            }
            return first
        }
    }

})();


