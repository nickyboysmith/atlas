(function() {

    'use strict';

    angular
        .module("app")
        .factory("TrainerProfileFactory", TrainerProfileFactory);


    TrainerProfileFactory.$inject = [];

    function TrainerProfileFactory() {

        /**
         * Takes both objects 
         * Merges them to create the phonenumber list object
         */
        this.createPhoneNumberObject = function (phoneTypes, phoneNumbers) {

            var phoneNumberArray = [];

            angular.forEach(phoneTypes, function (phoneType, index) {

                var thePhoneTypeId = $(phoneType).val();
                var thePhoneNumber = $(phoneNumbers[index]).val();
                var thePhoneId = $(phoneNumbers[index]).data("phoneId");
                phoneNumberArray.push({ PhoneTypeId: thePhoneTypeId, Number: thePhoneNumber, Id: thePhoneId });

            });

            return phoneNumberArray;
        };

        /**
         * Transform the trainer information frmo the web api
         */
        this.transformTrainerInformation = function (trainerDetails) {

            var transformedTrainerDetails = {};

            /**
             * Loop through the first iteration of the object
             */
            angular.forEach(trainerDetails[0], function (trainerDetail, index) {

                /**
                 * If the key is Emails 
                 * then add to the "transformedTrainerDetails" object
                 */
                if (index === "Emails") {
                    index = "Email";
                    trainerDetail = trainerDetail[0];
                }

                /**
                 * If the key is Licences 
                 * then add to the "transformedTrainerDetails" object
                 */
                if (index === "Licences") {
                    index = "Licence";
                    trainerDetail = trainerDetail[0];
                }

                /**
                 * If the key is Addresses
                 * then add to the "transformedTrainerDetails" object
                 */
                if (index === "Addresses") {
                    index = "Address";
                    trainerDetail = trainerDetail[0];
                }

                /**
                 * Add property to new object
                 */
                transformedTrainerDetails[index] = trainerDetail;

            });

            return transformedTrainerDetails;

        };

        /**
         * Take date from the web api
         * Convert into a usable format
         * Splits time returns only the date
         * takes 14/05/1970 00:00:00
         * @returns 14/05/1970
         */
        this.transformDate = function (theDate) {

            var newDate = theDate.split(" ");
            return newDate[0];
        };

        return {
            create: this.createPhoneNumberObject,
            transform: this.transformTrainerInformation,
            transformDate: this.transformDate
        };

    }

})();