(function () {

    'use strict';

    angular
        .module("app")
        .service("GetAddressService", GetAddressService);

    GetAddressService.$inject = ["$http"];

    function GetAddressService($http) {

        var addressLookUp = this;

        /**
         * The "getAddress()" access token
         */ 
        addressLookUp.key = "GqSJznyXK0y54ouA4JVsfg5408";
        /**
         * Get the address from the postcode
         */
        addressLookUp.getAddress = function (postcode) {

            var JSONApiAddress = "https://api.getAddress.io/v2/uk/" + postcode + "?api-key=" + addressLookUp.key;
            return $http.get(JSONApiAddress)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }
})();