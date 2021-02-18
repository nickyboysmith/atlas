(function () {

    'use strict';

    angular
        .module('app')
        .service('MessagingService', MessagingService);


    MessagingService.$inject = ["$http"];

    function MessagingService($http) {

        var messagingService = this;

        /**
        * get the message categories
        */
        messagingService.getMessageCategories = function () {
            return $http.get(apiServer + "/messaging/GetCategories/")
        };

        /**
        * get the usernames
        */
        messagingService.getUserDetails = function (OrganisationId, searchText) {
            return $http.get(apiServer + "/messaging/GetUserDetails/" + OrganisationId + "/" + searchText)
             .then(function (response) {
                 return response.data.map(function (item) {
                     return item;
                 });
             });
        };

        /**
        * send the message
        */
        messagingService.send = function (message) {
            return $http.post(apiServer + "/messaging/Send", message)
        };

    }



})();