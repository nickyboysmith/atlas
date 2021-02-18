(function () {

    'use strict';

    angular
        .module("app")
        .service("VenueLocaleService", VenueLocaleService);

    VenueLocaleService.$inject = ["$http"];

    function VenueLocaleService($http) {

        var venueLocale = this;

        /**
         * Save the Locale for the add / edit
         */
        venueLocale.saveVenueLocale = function (locale) {
            return $http.post(apiServer + "/venuelocale", locale);
        };

        /**
         * Get the venue Locale details
         */
        venueLocale.getTheVenueLocale = function (localeId) {
            return $http.get(apiServer + "/venuelocale/single/" + localeId);
        };

    }

})();