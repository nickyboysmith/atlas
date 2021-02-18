(function () {

    'use strict';

    angular
        .module('app')
        .factory('CraftyClicksFactory', CraftyClicksFactory);

    CraftyClicksFactory.$inject = ["CraftyClicksService"];

    function CraftyClicksFactory(CraftyClicksService) {


        /**
         * Transforma the address 
         * so it can be used in a select dropdown
         */
        this.transformAddresses = function (addressList) {

            var updatedAddressList = [];
            angular.forEach(addressList, function (value, index) {

                /**
                 * Instantiate the address variable
                 * Set it to empty 
                 */
                var address = "";

                /**
                 * If the organisation name is empty
                 */
                if (value.organisation_name === "") {
                    address += value.line_1 + " " + value.line_2;
                }

                /**
                 * If there is an organisation name
                 */
                if (value.organisation_name !== "") {
                    address += value.organisation_name + " " + value.line_1;
                }

                /**
                 * Add the object to the list of addresses
                 */
                updatedAddressList.push({ id: index, theAddress: address });


            });

            return updatedAddressList;

        };

        /**
         * merge the selected address
         */
        this.mergeSelectedAddress = function (selectedAddress, addressList) {

            var addressID = selectedAddress.id;
            var currentAddress = addressList["delivery_points"][addressID];

            /**
             * Remove unused properties 
             */
            delete currentAddress["dps"];
            delete currentAddress["udprn"];

            var mergedAddress = "";

            angular.forEach(currentAddress, function (address, index) {

                if (address !== "") {
                    mergedAddress += address + "\r\n";
                }

            });

            /**
             * Add the town
             */
            mergedAddress += addressList["town"] + "\r\n";

            return mergedAddress;

        };



        return {
            transform: this.transformAddresses,
            merge: this.mergeSelectedAddress
        };


    }

})();