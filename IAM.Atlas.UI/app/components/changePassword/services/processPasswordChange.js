
(function () {
    'use strict';

    angular
        .module('app')
        .service('PasswordChangeService', PasswordChangeService, '$http');
    /**
     * Connect this service to a $http backend call
     */
    function PasswordChangeService() {

        this.processChange = function (organisation, passwordStrength, $http) {

            //var checkErrors = this.errorChecker(organisation, passwordStrength);
            //if (checkErrors !== undefined && checkErrors.status === "error") {
            //    return checkErrors;
            //}

            $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

            return $http.post(apiServer + '/passwordchange', organisation);
                
        }

        this.errorChecker = function (organisation, passwordStrength) {

            var organisationEmptyFields = [];
            this.organisationObjectKeys = ["name", "loginID", "currentPassword", "newPassword", "confirmPassword"];


            /**
             * If all fields are empty the organisation object will be empty && === undefined
             */
            if (organisation === undefined) {
                return {
                    status: "error",
                    message: "Please fill out all fields."
                };
            }


            /**
             * Run through the organisation object
             * Fill an empty array - "organisationEmptyFields" - if there are errors
             */
            angular.forEach(this.organisationObjectKeys, function (organisationKey, organisationValue) {
                if (organisation[organisationKey] === undefined) {
                    organisationEmptyFields.push(organisationKey + " is empty");
                }
            });


            /**
             * Check to see if the "organisationEmptyFields" array is empty
             * If it's not. 
             * Return an error message
             */
            if (organisationEmptyFields.length !== 0) {
                return {
                    status: "error",
                    message: "A required field is empty. Please fill out all fields."
                };
            }


            /**
             * Check the password strength
             * If very-weak.
             * Return an error message
             */
            if (passwordStrength === "very-weak") {
                return {
                    status: "error",
                    message: "Your password wasn't strong enough!"
                };
            }


            /**
             * Check the passwords are identical
             * If they are not identical.
             * Return an error message
             */
            if (organisation.newPassword !== organisation.confirmPassword) {
                return {
                    status: "error",
                    message: "Your passwords don't match!"
                };
            }
        }

        this.getUserPasswordDetails = function ($http, UserId) {

            return $http.get(apiServer + '/user/' + UserId);
        }        
    }

})();