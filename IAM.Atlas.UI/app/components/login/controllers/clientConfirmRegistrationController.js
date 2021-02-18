(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientConfirmRegistrationCtrl", ClientConfirmRegistrationCtrl);

    ClientConfirmRegistrationCtrl.$inject = ["$scope", "$window", "ClientRegistrationService"];

    function ClientConfirmRegistrationCtrl($scope, $window, ClientRegistrationService) {

        var sessionData = sessionStorage.getItem("registrationDetails");
        $scope.validationMessage = '';

        /**
         * Check that there is data in the session
         */
        if (sessionData === (undefined || null)) {
            $window.location.href = "/";
            exit(); // Stops any execution of code whilst processing page load
        }

        /**
         * Set on the scope
         */
        $scope.registrationDetails = JSON.parse(sessionData);

        /**
         * Remove from the storage
         * might put this back
         */
        //sessionStorage.removeItem("registrationDetails");

        /**
         * 
         */
        $scope.system = {
            OrganisationName: $scope.registrationDetails["Login"][0]["OrganisationIds"]["Name"],
            AppName: $scope.registrationDetails["Login"][0]["OrganisationIds"]["AppName"]
        }

        $scope.confirmationDetails = {
            DisplayName: $scope.registrationDetails["Login"][0].Name,
            DORSCourse: $scope.registrationDetails["BookingDetails"][0].Title,
            CourseFee: $scope.registrationDetails["BookingDetails"][0].CourseFee
        };
        
        /**
         * Build checkbox object
         */
        $scope.confirmation = $scope.registrationDetails["BookingState"][0];

        /**
         *  Go back to the last step
         */
        $scope.previousStep = function () {
            $window.location.href = "/login/clientregister";
        };

        /**
         * Go back to the main home page
         */
        $scope.restartProcess = function () {
            $window.location.href = "/";
        };

        /**
         * save the legal requirements
         */
        $scope.save = function () {
            ClientRegistrationService.confirmRegistration($scope.confirmation)
            .then(
                function (response) {
                    console.log(response);
                    $window.location.href = "/login/clientSpecialRequirements";
                },
                function (reason) {
                    $scope.validationMessage = reason.data;
                }
            );
        };

    }

})();