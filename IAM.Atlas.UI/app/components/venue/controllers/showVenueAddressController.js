(function () {

    'use strict';

    angular
        .module("app")
        .controller("ShowVenueAddressCtrl", ShowVenueAddressCtrl);

    ShowVenueAddressCtrl.$inject = ["$scope", "ShowVenueAddressService", "DateFactory", "ModalOptionsFactory"];

    function ShowVenueAddressCtrl($scope, ShowVenueAddressService, DateFactory, ModalOptionsFactory) {


        /**
         * Instatiate the property on the scope
         */
        $scope.longLat = {};
        
        /**
         * Add parent scopes
         */
        $scope.$parent.courseSelectedVenueId;
        $scope.courseName = $scope.$parent.courseSelectedName;
        $scope.courseVenue = $scope.$parent.courseSelectedVenue;
        $scope.courseDate = DateFactory.convertDateTime($scope.$parent.courseSelectedDate);

        /**
         * Get the address
         * From the venue Id
         */
        ShowVenueAddressService.getAddress($scope.$parent.courseSelectedVenueId)
        .then(
            function (response) {
                var venueDetails = response.data[0];
                $scope.venueAddress = venueDetails.Address + "\r\n" + venueDetails.PostCode;

                if (venueDetails.PostCode !== (null || "")) {

                    /**
                     * Extend the modal!
                     */
                    ModalOptionsFactory.extend({
                        mainModalID: "#showVenueAddress",
                        firstColumn: "#addressDetails",
                        secondColumn: "#googleMap",
                        classToRemove: "col-md-12",
                        classToAdd: "col-md-5",
                        cssProperties: {
                            width: "663px"
                        }
                    });

                    /**
                     * Get the long lat from the Googlemaps API
                     */
                    $scope.getLongLat($scope.venueAddress);
                    $scope.$watch(
                        "longLat",
                        function (newValue, oldValue) {
                            var objectLength = Object.keys(newValue).length;
                            /**
                             * If there are p[roperties 
                             * In the object
                             * Then load the map
                             */
                            if (objectLength === 2) {
                                var location = newValue;
                                $scope.buildMap(location.lng, location.lat);
                            }
                        }
                    );
                }


            },
            function (reason) {
                console.log(reason);
            }
        );

        /**
         * Call the service and create the long lat object
         */
        $scope.getLongLat = function (address) {
            var replacedAddress = address.replace(/\r\n/g, "+");

            /**
             * Call the service
             */
            return ShowVenueAddressService.getLongLat(replacedAddress)
            .then(
                function (response) {
                    return response.map(function (item) {
                        $scope.longLat = item;
                    });
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        /**
         * Build the map
         * Once the long and Lat is 
         */
        $scope.buildMap = function (long, lat) {

            /**
             * Check to see when 
             * #map is avaiable
             */
            var check = setInterval(function () {
                var element = document.getElementById('map');
                if (element !== null) {
                    clearInterval(check);
                }
            }, 500);
            
            /**
             * Load the GoogleMap
             */
            var map = new google.maps.Map(document.getElementById('map'), {
                center: { lat: lat, lng: long },
                zoom: 14
            });

            var marker = new google.maps.Marker({
                position: { lat: lat, lng: long },
              map: map
            });
        };
 
    }

})();