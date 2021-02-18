(function () {

    'use strict';

    angular
        .module("app")
        .service("ShowVenueAddressService", ShowVenueAddressService);

    ShowVenueAddressService.$inject = ["$http"];

    function ShowVenueAddressService($http) {

        var showVenue = this;

        /**
         * Get the venue data from the venueId
         */
        showVenue.getAddress = function (venueId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/Venue/Location/" + venueId;
            return $http.get(endPointUrl, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Get Address LongLat
         */
        showVenue.getLongLat = function (address) {
            var apiKey = "AIzaSyBj1SVO3p9YQITzjFFEnCb9bui-M9RyYgM";
            var googleMapsEndpoint = "https://maps.googleapis.com/maps/api/geocode/json?address=";
            var withAPIKey = "&key=" + apiKey;
            return $http.get(googleMapsEndpoint + address + withAPIKey)
            .then(function (response) {
                return response.data.results.map(function (item) {
                    return item.geometry.location;
                });
            });
        };


    }

})();