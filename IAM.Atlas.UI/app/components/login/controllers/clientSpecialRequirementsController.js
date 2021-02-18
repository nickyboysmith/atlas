(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientSpecialRequirementsCtrl", ClientSpecialRequirementsCtrl);

    ClientSpecialRequirementsCtrl.$inject = ["$scope", "$window", "$filter", "ClientRegistrationService"];

    function ClientSpecialRequirementsCtrl($scope, $window, $filter, ClientRegistrationService) {


        var sessionData = sessionStorage.getItem("registrationDetails");

        /**
         * Check that there is data in the session
         */
        if (sessionData === (undefined || null)) {
            $window.location.href = "/";
            exit(); // Stops any execution of code whilst processing page load
        }

        /**
         * Create the requirements object 
         * and the selected array
         */
        $scope.theRequirements = {
            selected: []
        };

        /**
         * Instantiate client requirement s object on the scope
         */
        $scope.clientRequirements = {};

        /**
         * aDD Notes property on the scope
         */
        $scope.clientNote = "";

        /**
         * Set on the scope
         */
        $scope.registrationDetails = JSON.parse(sessionData);

        /**
         * 
         */
        ClientRegistrationService.getOrganisationSpecialRequirements(
            $scope.registrationDetails["Login"][0]["ClientId"],
            $scope.registrationDetails["Login"][0]["OrganisationIds"]["Id"]
        )
        .then(
            function successCallback(response) {
                $scope.specialRequirements = response.data;
                $scope.specialRequirements = $filter('filter')($scope.specialRequirements, { 'Disabled': false })
                $scope.specialRequirements = $filter('orderBy')($scope.specialRequirements, 'Name');
            },
            function errorCallback(response) {
                if (!response.data == false) {
                    $scope.validationMessage = response.data;
                } else {
                    $scope.validationMessage = response.statusText;
                }
            }
        );

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

        /**
         * Build object to display on the frontend
         */
        $scope.confirmationDetails = {
            DisplayName: $scope.registrationDetails["Login"][0].Name,
            DORSCourse: $scope.registrationDetails["BookingDetails"][0].Title,
            CourseFee: $scope.registrationDetails["BookingDetails"][0].CourseFee
        };



        /**
         *  Go back to the last step
         */
        $scope.previousStep = function () {
            $window.location.href = "/login/confirmRegistration";
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
         * Push ng model into array
         * Todo: should be an easier way to do this
         */
        $scope.otherRequirementsArray = function (clientRequirements) {
            var array = [];
            angular.forEach(clientRequirements, function (value, index) {
                array.push(value);
            });
            return array;
        };

        /**
         * 
         */
        $scope.save = function () {
            $scope.validationMessage = '';

            ClientRegistrationService.saveClientSpecialRequirements({
                specialRequirements: $scope.theRequirements.selected,
                otherRequirements: $scope.otherRequirementsArray($scope.clientRequirements),
                clientNote: $scope.clientNote
            })
            .then(
                function successCallback(response) {
                    $window.location.href = "/login/clientCourseSelection";
                    //exit(); // Stops any execution of code whilst processing page load
                },
                function errorCallback(response) {
                    if (!response.data == false) {
                        $scope.validationMessage = response.data;
                    } else {
                        $scope.validationMessage = response.statusText;
                    }
                }
            );
        }


    }

})();