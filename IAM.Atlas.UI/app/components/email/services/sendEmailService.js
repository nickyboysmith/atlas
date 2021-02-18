(function () {

    'use strict';

    angular
        .module("app")
        .service("SendEmailService", SendEmailService);

    SendEmailService.$inject = ["$http"];

    function SendEmailService($http) {


        var sendEmail = this;

        /**
         * 
         */
        sendEmail.send = function (emailOptions) {
            return $http.post(apiServer + "/SendEmail/SendEmail", emailOptions);
        };

        sendEmail.getClientEmailTemplates = function (organisationId) {
            return $http.get(apiServer + "/ClientEmailTemplate/GetClientEmailTemplates/" + organisationId);
        }

    }

})();