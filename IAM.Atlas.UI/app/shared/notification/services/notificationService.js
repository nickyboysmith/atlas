(function () {
    'use strict';
    angular
        .module("app")
        .service("NotificationService", NotificationService);

    NotificationService.$inject = ["$http"];

    function NotificationService($http) {
        var NotificationService = this;
        //var messages = [];

        NotificationService.getMessages = function (userId) {
            var webServiceEndpoint = apiServer + "/notification/" + userId;
            return $http.get(webServiceEndpoint)
                .then(function (response) {
                    return response.data;
                }, function (response) {
                    return response.data;
                });

        };


        /**
         * 
         */
        NotificationService.messageAcknowledged = function (messageObject) {
            return $http.post(apiServer + "/notification", messageObject);
        };

    }

})();


