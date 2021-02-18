(function () {

    'use strict';

    angular
        .module('app')
        .factory('GetAddressFactory', GetAddressFactory);

    GetAddressFactory.$inject = ["GetAddressService"];

    function GetAddressFactory(GetAddressService) {


        /**
         * Transforms the address 
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
        this.mergeSelectedAddress = function (selectedAddress) {
            if (selectedAddress) {
                var re = new RegExp("\\n\\n{2,6}", 'g');
                selectedAddress = selectedAddress.replace(/, /g, "\n").replace(re, "\n");
            }
            return selectedAddress;
        };

        return {
            transform: this.transformAddresses,
            format: this.mergeSelectedAddress
        };
    }
})();