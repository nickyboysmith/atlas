(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientCourseConfirmationCtrl", ClientCourseConfirmationCtrl);

    ClientCourseConfirmationCtrl.$inject = ["$scope", "$window", "ModalService", "ClientRegistrationService", "ShowVenueAddressService", "DateFactory", "OrganisationSelfConfigurationService"];

    function ClientCourseConfirmationCtrl($scope, $window, ModalService, ClientRegistrationService, ShowVenueAddressService, DateFactory, OrganisationSelfConfigurationService) {


        var sessionData = sessionStorage.getItem("registrationDetails");

        /**
         * Check that there is data in the session
         */
        if (sessionData === (undefined || null)) {
            try {
                $window.location.href = "/";
                exit(); // Stops any execution of code whilst processing page load
            } catch (err) { }
        }

            /**
             * Update the mouse over text
             */
        $scope.updateTheMouseOverText = function (terms) {
            var text = "You must Agree to the Terms and Conditions before you can continue";
            if (terms === true) {
                text = "Click to Save Selection and Continue to Payment Section";
        }
            /**
             * Set text on the scope
             */
            $scope.mouseOverText = text;
        };

            /**
             * Set the date selected option
             */
        $scope.dateSelected = "*";

            /**
             * Course Selected
             */
        $scope.courseSelected = {};

            /**
             * Instantiate terms accepted 
             * Property on the scope
             */
        $scope.termsAccepted = false;

            /**
             * Instantiate the property on the scope
             */
        $scope.longLat = {};

            /**
             * Set the mouse over text
             */
        $scope.mouseOverText = $scope.updateTheMouseOverText($scope.termsAccepted);

            /**
             * Set on the scope
             */
        $scope.registrationDetails = JSON.parse(sessionData);

            /**
             * CReate the system details
             */
        $scope.system = {
                OrganisationName: $scope.registrationDetails["Login"][0]["OrganisationIds"]["Name"],
                AppName: $scope.registrationDetails["Login"][0]["OrganisationIds"]["AppName"]
        }

            /**
             * Build object to display on the frontend
             */
        $scope.confirmationDetails = {
                DisplayName: $scope.registrationDetails["Login"][0].Name,
                DORSCourse: $scope.registrationDetails["BookingDetails"][0].Title,
                CourseFee: $scope.registrationDetails["BookingDetails"][0].CourseFee,
                CourseTypeId: $scope.registrationDetails["BookingDetails"][0].Id,
                OrganisationId: $scope.registrationDetails["Login"][0]["OrganisationIds"].Id
        };

            /**
             * build client object details
             */
        $scope.client = {
                Id: $scope.registrationDetails["Login"][0]["ClientId"],
                UserId: $scope.registrationDetails["Login"][0]["UserId"]
        };

            /**
             * build course object details
             */
        $scope.course = $scope.registrationDetails["Course"];

            /**
             *  Go back to the last step
             */
        $scope.previousStep = function () {
            try{
                $window.location.href = "/login/clientCourseSelection";
                exit(); // Stops any execution of code whilst processing page load
            } catch (err) { }
        };

            /**
             * Go back to the main home page
             */
        $scope.restartProcess = function () {
            try{
                $window.location.href = "/";
                exit(); // Stops any execution of code whilst processing page load
            } catch (err) { }
        };

            /**
             * Get the client Address
             */
        ClientRegistrationService.getClientAddress($scope.client.Id)
        .then(
            function (response) {
                var fullAddress = "";
                var clientAddress = response.data[0];
                var streetAddress = clientAddress.Address.replace(/\r\n/g, "<br/>");

                // Check to see if the postcode exists
                if (!clientAddress.PostCode) {
                    fullAddress = streetAddress;
                } else {
                    fullAddress = streetAddress + "<br/>" + clientAddress.PostCode;
            }

            $("#clientAddress").html(fullAddress);
            },
            function (reason) {
                console.log(reason.data);
        }
        );
   

            /**
             * Get the venue address service
             */
        ShowVenueAddressService.getAddress($scope.course.VenueId)
        .then(
            function (response) {
                var venueAddress = response.data[0];
                var streetAddress = venueAddress.Address.replace(/\r\n/g, "<br/>");
                var fullAddress = streetAddress + "<br/>" + venueAddress.PostCode;
                $("#venueAddress").html(fullAddress);

                //set venue postcode
                var postCodeCheck = venueAddress.PostCode;

                if (postCodeCheck !== (undefined || "")) {
                    var streetAddressForLongLat = postCodeCheck;
                    /**
                     * Get the long lat from the Googlemaps API
                     */
                    $scope.getLongLat(streetAddressForLongLat);
                    $scope.$watch(
                        "longLat",
                        function (newValue, oldValue) {
                            var objectLength = Object.keys(newValue).length;
                            /**
                             * If there are properties 
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
             * show ther terms modal
             */
        $scope.showTermsModal = function () {

            ModalService.displayModal({
                scope: $scope,
                    title: "Terms and Conditions",
                    cssClass: "showOnlineTermsModal",
                    filePath: "/app/components/login/showOnlineTerms.html",
                controllerName: "ShowTermsCtrl",
                    buttons: {
                    label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                }
        }
        });
        };

            /**
             * Convert date
             */
        $scope.formatDate = function (theDate) {
            return DateFactory.formatDateddMonyyyyDashes(DateFactory.parseDate(theDate)) + " " + DateFactory.getTimeString(DateFactory.parseDate(theDate));
        }

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
             * #map is available
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
                zoom: 14,
                
            });

            var marker = new google.maps.Marker({
                    position: { lat: lat, lng: long },
                map: map
        });

        };


            /**
             *
             */
        $scope.save = function () {

            ClientRegistrationService.saveCourseBooking({
                clientId: $scope.client.Id,
                    courseId: $scope.course.CourseId,
                    amount: $scope.confirmationDetails.CourseFee,
                    userId: $scope.client.UserId
        })
            .then(
                function successCallback(response) {
                    ClientRegistrationService.updateClientOnlineBookingState($scope.client.Id, $scope.course.CourseId);
                    $window.location.href = "/login/clientCoursePayment";
        },
                function errorCallback(response) {
                    if (response.data === "CourseFullyBooked") {
                        // Get the modal firing
                        ModalService.displayModal({
                            scope: $scope,
                                title: "Courses fully booked",
                                cssClass: "displayFullyBookedCoursesNotificationModal",
                                filePath: "/app/components/login/fullyBookedCourseNotification.html",
                                controllerName: "FullyBookedCourseNotificationCtrl",
                                buttons: {
                                label: 'Close',
                                    cssClass: 'closeModalButton',
                                    action: function (dialogItself) {
                                        dialogItself.close();
                            }
                        },
                                onhide: function () {
                                    try{
                                        $window.location.href = "/login/clientCourseSelection";
                                        exit();
                                    } catch (err) { }
                        }
                    });
                    }
                    else {
                        if (!response.data == false) {
                            if (response.data.ExceptionMessage) {
                                $scope.validationMessage = response.data.ExceptionMessage + " .... Please Contact Administration for help";
                            }
                            else if (response.data.Message) {
                                $scope.validationMessage = response.data.Message + " .... Please Contact Administration for help";
                            }
                            else {
                                $scope.validationMessage = "Please Contact Administration for help.";
                        }
                        }
                        else {
                            $scope.validationMessage = response.statusText;
                    }
                }
        }
            );


        };

            /**
             * Go to the OrganisationSelfConfiguration table
             * To check whether for MinutesToHoldOnlineUnpaidCourseBookings
             */
        $scope.orgSystemConfig = new Object();
        OrganisationSelfConfigurationService.GetByOrganisation($scope.confirmationDetails.OrganisationId)
            .then(
                function successCallback(response) {
                    if (response.data !== null) {
                        $scope.orgSystemConfig.bookingHeldMinutes = response.data.MinutesToHoldOnlineUnpaidCourseBookings;
                    }
                    else {
                        $scope.orgSystemConfig.bookingHeldMinutes = 15;
                }
        },
                function errorCallback(response) {
                    $scope.orgSystemConfig.bookingHeldMinutes = 15;
        }
            )

    }

})();