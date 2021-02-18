(function () {

    'use strict';

    angular
        .module("app")
        .service("CraftyClicksService", CraftyClicksService);

    CraftyClicksService.$inject = ["$http"];

    function CraftyClicksService($http) {

        var craftyClicks = this;

        /**
         * The crafty clicks access token
         */
        craftyClicks.key = "baad2-c97f0-791d0-00ebc";

        /**
         * Get the address from the postcode
         */
        craftyClicks.getAddress = function (postcode) {
            var JSONApiAddress = "http://pcls1.craftyclicks.co.uk/json/rapidaddress?postcode=" + postcode + "&key=" + craftyClicks.key + "&response=data_formatted";
            return $http.get(JSONApiAddress)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };


    }

})();