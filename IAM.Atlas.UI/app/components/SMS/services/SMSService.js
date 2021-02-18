(function () {

    'use strict';

    angular
        .module("app")
        .service("SMSService", SMSService);

    SMSService.$inject = ["$http"];

    function SMSService($http) {


        var smsService = this;

        /**
         * Send Single Client SMS
         */
        smsService.Send = function (smsOptions) {
            return $http.post(apiServer + "/sms/client", smsOptions);
        };


        /**
        * Get All Client SMS
        */
        smsService.GetAllClientsOnCourse = function (OrganisationId, CourseId) {
            return $http.get(apiServer + "/sms/GetAllClientsOnCourse/" + OrganisationId + "/" + CourseId)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
        * Send All Client SMS
        */
        smsService.SendAllClientsOnCourse = function (sms) {
            return $http.post(apiServer + "/sms/SendAllClientsOnCourse", sms)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };


        /**
       * Get All Trainer SMS
       */
        smsService.GetAllTrainersOnCourse = function (OrganisationId, CourseId) {
            return $http.get(apiServer + "/sms/GetAllTrainersOnCourse/" + OrganisationId + "/" + CourseId)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
        * Send All Trainer SMS
        */
        smsService.SendAllTrainersOnCourse = function (sms) {
            return $http.post(apiServer + "/sms/SendAllTrainersOnCourse", sms)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

    }

})();