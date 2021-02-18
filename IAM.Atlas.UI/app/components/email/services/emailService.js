(function () {

    'use strict';

    angular
        .module("app")
        .service("EmailService", EmailService);

    EmailService.$inject = ["$http"];

    function EmailService($http) {


        var emailService = this;

        /**
         * Is the email address in a valid email format?
         */
        emailService.validate = function (emailAddress) {
            // regular expression from this stack overflow:
            // http://stackoverflow.com/questions/46155/validate-email-address-in-javascript

            var emailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

            var validEmail = emailFormat.test(emailAddress);

            return validEmail;
        };

    }

})();