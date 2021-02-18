(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientCourseSelectionCtrl", ClientCourseSelectionCtrl);

    ClientCourseSelectionCtrl.$inject = ["$scope", "$window", "DateFactory", "ClientRegistrationService", "ModalService"];

    function ClientCourseSelectionCtrl($scope, $window, DateFactory, ClientRegistrationService, ModalService) {

        $scope.validationMessage = '';

        var sessionData = sessionStorage.getItem("registrationDetails");


        /**
         * Check that there is data in the session
         */
        if (sessionData === (undefined || null)) {
            $window.location.href = "/";
            exit(); // Stops any execution of code whilst processing page load
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

        $scope.showCourses = false;

        /**
         * Course Selected
         */
        $scope.courseSelected = {};

        /**
         * Instatiate terms accepted 
         * Property on the scope
         */
        $scope.termsAccepted = false;

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
            DORSCourse: $scope.registrationDetails["BookingDetails"][0].Title
        };

        /**
         *  Go back to the last step
         */
        $scope.previousStep = function () {
            $window.location.href = "/login/clientSpecialRequirements";
            exit(); // Stops any execution of code whilst processing page load
        };

        /**
         * Go back to the main home page
         */
        $scope.restartProcess = function () {
            $window.location.href = "/";
            exit(); // Stops any execution of code whilst processing page load
        };

        /**
         * Array of dates
         */
        $scope.courseAvailableDates = [
            {
                label: "All dates",
                date: {
                    is: "present",
                    startDate: "",
                    endDate: "",
                    index: 0
                }
            }
        ];

        /**
         * Get the months ahead
         * And put into the course available array
         */
        angular.forEach(DateFactory.createNextMonth(), function (value, index) {
            $scope.courseAvailableDates.push(value);
        });
        $scope.initialDateSelected = $scope.courseAvailableDates[1].date;

        /**
         * Dummy Course data
         */
        $scope.courses = [];


        /**
         * Select a course
         */
        $scope.selectCourse = function ($event, course) {

            /**
             * Once a new one is clicked 
             * Then remove the previous class/(es)
             */
            angular.forEach($("tr.course-selected"), function (element, index) {
                $(element).removeClass("course-selected");
            });
            
            /**
             * Add the class to the element
             */
            $($event.currentTarget).addClass("course-selected");

            /**
             * Find the radio buton 
             * Then selcet it on click
             */
            $($event.currentTarget).find("input").prop("checked", true);

            /**
             * Put course on scope
             */
            $scope.courseSelected = course;

        };

        /**
         * check
         */
        $scope.limitedPlaceCheck = function (bookedPlaces, amountOfPlaces) {
            var isLimited = "Places Available";
            var percentageOfBooked = (1 - (bookedPlaces / amountOfPlaces)) * 100;
            if (percentageOfBooked <= 10) {
                isLimited = "Limited PLaces left";
            }
            return isLimited;
        };

        /**
         * Show the modal
         */
        $scope.showTheVenueLocationModal = function (course) {

            $scope.courseSelectedVenueId = course.VenueId;
            $scope.courseSelectedVenue = course.Location;
            $scope.courseSelectedName = $scope.confirmationDetails.DORSCourse;
            $scope.courseSelectedDate = course.StartDate;


            ModalService.displayModal({
                scope: $scope,
                title: "Course Venue Details",
                cssClass: "showVenueAddressModal",
                filePath: "/app/components/venue/showVenueAddress.html",
                controllerName: "ShowVenueAddressCtrl",
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
         * Load courses based on dates
         */
        $scope.loadCourses = function (courseDate) {

            $scope.showCourses = false;

            $("#rowProcessingSpinner").show();
            /**
            * Empty current course data
            */
            $scope.courses = [];

            $scope.noCoursesForDateSelectedLabel = "";


            /**
             * Create object to pass to web api
             */
            var courseDateSearchObject = {
                courseTypeId: $scope.registrationDetails["BookingDetails"][0].Id,
                organisationId: $scope.registrationDetails["Login"][0]["OrganisationIds"]["Id"],
                regionId: $scope.registrationDetails["Region"][0]["Id"],
                date: courseDate,
                clientId: $scope.registrationDetails.ClientId
            };

            /**
             * Call the web api
             */
            ClientRegistrationService.getAvailableCourses(courseDateSearchObject)
            .then(
                function successCallback(response) {
                    $scope.courses = response.data;
                    $scope.courseSelected = {};
                    $scope.validationMessage = '';
                    if (response.data.length == 0) {
                        $scope.noCoursesForDateSelectedLabel = $scope.courseAvailableDates[courseDateSearchObject.date.index].label;
                    }
                    $("#rowProcessingSpinner").hide();
                    $scope.showCourses = true;
                },
                function errorCallback(response) {
                    if (!response.data == false) {
                        $scope.validationMessage = response.data;
                    }
                    else {
                        $scope.validationMessage = response.statusText;
                    }
                    $("#rowProcessingSpinner").hide();
                    $scope.showCourses = true;
                }
            )

        };


        /**
         * Save the course selection
         */
        $scope.saveCourse = function () {
            $scope.validationMessage = '';
            var courseObjectLength = Object.keys($scope.courseSelected).length;
            /**
             * Check to see if a course has been selected
             */
            if (courseObjectLength === 0) {
                concatenateValidationMessage("Please select a course to proceed.");
            }
            if ($scope.termsAccepted === false) {
                concatenateValidationMessage("Please agree the terms and conditions.");
            }

            if ($scope.validationMessage == '') {
                /**
                 * Add the course data to the registration details object
                 */
                $scope.registrationDetails["Course"] = $scope.courseSelected;

                /**
                 * Set the updated registration details on the window
                 */
                sessionStorage.setItem("registrationDetails", JSON.stringify($scope.registrationDetails));

                /**
                 * Send user to the course confirmation page
                 */
                $window.location.href = "/login/clientCourseConfirmation";
                //exit(); // Stops any execution of code whilst processing page load
            }
        };

        function concatenateValidationMessage(newMessage) {
            $scope.validationMessage += $scope.validationMessage != "" ? "\n" : "";
            $scope.validationMessage += newMessage;
        }

        $scope.loadCourses($scope.initialDateSelected);
        
    }

})();