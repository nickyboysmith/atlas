(function () {

    'use strict';

    angular
        .module('app')
        .service('EmailAllService', EmailAllService);


    EmailAllService.$inject = ["$http"];

    function EmailAllService($http) {

        var emailAllService = this;

        /**
        * Records Emails
        */
        emailAllService.RecordEmails = function (emails) {
            return $http.post(apiServer + "/emailAll/RecordEmails", emails)
        };

        /* enjoy the name of this webapi route! */
        emailAllService.ClientsWithoutEmails = function (courseId) {
            return $http.get(apiServer + "/emailAll/ClientsWithoutEmails/" + courseId);
        }

        emailAllService.TrainersWithoutEmails = function (courseId) {
            return $http.get(apiServer + "/emailAll/TrainersWithoutEmails/" + courseId);
        }

    }



})();