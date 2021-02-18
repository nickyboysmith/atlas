(function() {

    'use strict';

    angular
        .module("app")
        .controller("AddVenueLocaleCtrl", AddVenueLocaleCtrl);

    AddVenueLocaleCtrl.$inject = ["$scope", "VenueLocaleService", "ModalService"];

    function AddVenueLocaleCtrl($scope, VenueLocaleService, ModalService) {

        /**
         * Instatiate the venueLocale Object
         */
        $scope.venueLocale = {};

        $scope.showForEditLocale = false;

        /**
         * Set the locale Id as a vartiable
         */
        var venueLocaleId = $scope.$parent.selectedVenueLocaleId;

        /**
         * Check to see if the parent has a locale Id
         * If it does then get the details
         */
        if (venueLocaleId !== "") {


            VenueLocaleService.getTheVenueLocale(venueLocaleId)
                .then(
                    function (response) {
                        $scope.showForEditLocale = true;
                        $scope.venueLocale = response.data;
                    },
                    function (response) {
                        console.log(response);
                    }
                );

        }

        /**
         * SAve the venue locale or update it
         */
        $scope.save = function () {

            /**
             * Add the venue Id to the object
             */
            $scope.venueLocale.VenueId = $scope.$parent.selectedVenue;

            if (venueLocaleId !== "" && $scope.venueLocale.Enabled !== null) {
                $scope.venueLocale.Enabled = +$scope.venueLocale.Enabled;
            }

            /**
             * Call the webservice
             */
            VenueLocaleService.saveVenueLocale($scope.venueLocale)
                .then(
                    function (response) {

                        /**
                         * Clear the venue locale Id once we've succesfully 
                         * Updated the current venue locale
                         */
                        if (venueLocaleId !== undefined || venueLocaleId !== "") {
                            $scope.$parent.selectedVenueLocaleId = "";
                        }

                        /**
                         * Refresh the locales
                         */
                        $scope.$parent.getVenueLocale($scope.venueLocale.VenueId);

                        /**
                         * Close the modalvenu
                         */
                        ModalService.closeCurrentModal("addVenueLocaleModal");
                    },
                    function (response) {
                        console.log(response);
                    }
                );
        }

    }

})();