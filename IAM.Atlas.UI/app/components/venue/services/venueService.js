(function () {

    'use strict';

    angular
        .module("app")
        .service("VenueService", VenueService);

    VenueService.$inject = ["$http"];

    function VenueService($http) {

        var venueService = this;

        /**
         * Get the Organisation/s for the User
         */
        venueService.getUserOrganisations = function (userID) {

            return $http.get(apiServer + "/organisation/GetByUser/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Regions for the selected Organisation
         */
        venueService.getOrganisationRegions = function (organisationID, userID) {
            return $http.get(apiServer + "/organisation/GetRegions/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Venues for the selected Organisation
         */
        venueService.getOrganisationVenuesByRegion = function (organisationID, regionID) {
            return $http.get(apiServer + "/venue/" + organisationID + "/" + regionID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Venues for the selected Organisation
         */
        venueService.getOrganisationVenues = function (organisationID) {
            return $http.get(apiServer + "/venue/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the Venue details for the Venue
         */
        venueService.getVenue = function (venueID, userID) {
            return $http.get(apiServer + "/venue/GetVenue/" + venueID + "/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the Course Types for the Venue
         */
        venueService.getVenueCourseTypes = function (venueID) {
            return $http.get(apiServer + "/coursetype/venuerelated/" + venueID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the Costs for the Venue
         */
        venueService.getVenueCosts = function (venueID) {
            return $http.get(apiServer + "/venuecost/getbyvenue/" + venueID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * saves or updates the venue details
         */
        venueService.saveVenueDetails = function (venue) {
            return $http.post(apiServer + "/venue", venue)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * Get the locale related to a venue
         */
        venueService.getVenueLocale = function (venueId) {
            return $http.get(apiServer + "/venuelocale/" + venueId);
        };

        venueService.addVenueRegion = function (venueId, regionId, userId, organisationId) {
            return $http.get(apiServer + "/Venue/AddRegion/" + venueId + "/" + regionId + "/" + userId + "/" + organisationId);
        }

    }
})();