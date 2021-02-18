(function () {
    'use strict';

    angular
        .module('app')
        .service('PasswordValidationService', PasswordValidationService);

    function PasswordValidationService() {

        /**
        * This function needs to be moved to a new file
        * This Puts the character types in string into an object
        */
        this.passwordValidator = function (password) {

            var passwordStrength = {
                upperCase: 0,
                lowerCase: 0,
                numeric: 0,
                specialCharacters: 0
            };

            var upperCase = password.match(/[A-Z]/g);
            var lowerCase = password.match(/[a-z]/g);
            var numeric = password.match(/[0-9]/g);
            var specialCharacter = password.match(/[+-.,!@#$%^&*();\/|<>"'_]/g);


            if (upperCase !== null) {
                passwordStrength.upperCase = upperCase.length;
            }

            if (lowerCase !== null) {
                passwordStrength.lowerCase = lowerCase.length;
            }

            if (numeric !== null) {
                passwordStrength.numeric = numeric.length;
            }

            if (specialCharacter !== null) {
                passwordStrength.specialCharacters = specialCharacter.length;
            }


            return this.passwordValidationScore(passwordStrength, password.length);
        }

        /**
         * This function needs to be moved to a new file
         * Calculates a score based on what the object passed to the function
         */
        this.passwordValidationScore = function(passwordValidatedObject, passwordLength) {

            /**
                * Very Strong
                * 2 or More Lowercase Character
                * 2 or More Uppercase Character
                * 2 or More Number
                * 2 or More Special Character
                * & Password Length minimum : 6
                */
            if (passwordValidatedObject.lowerCase >= 2 && passwordValidatedObject.upperCase >= 2 && passwordValidatedObject.numeric >= 2 && passwordValidatedObject.specialCharacters >= 2 && passwordLength >= 6) {
                return { validatedClass: "very-strong", text: "Very Strong Password" };
            }

            /**
                * Strong
                * 1 or More Lowercase Character
                * 1 or More Uppercase Character
                * 1 or More Number
                * 1 or More Special Character
                * & Password Length minimum : 6
                */
            if (passwordValidatedObject.lowerCase >= 1 && passwordValidatedObject.upperCase >= 1 && passwordValidatedObject.numeric >= 1 && passwordValidatedObject.specialCharacters >= 1 && passwordLength >= 6) {
                return { validatedClass: "strong", text: "Strong Password" };
            }

            /**
                * Medium
                * 1 letter (Lowercase or Uppercase)
                * 1 Number
                * 1 Special Character
                * & Password Length minimum : 6
                */
            if ((passwordValidatedObject.lowerCase >= 1 || passwordValidatedObject.upperCase >= 1) && passwordValidatedObject.numeric >= 1 && passwordValidatedObject.specialCharacters >= 1 && passwordLength >= 6) {
                return { validatedClass: "medium-strong", text: "Medium Password" };
            }

            /**
                * Doesn't match any of the above
                */
            return { validatedClass: "very-weak", text: "Very Weak Password" };
        }


    }

})();