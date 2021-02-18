(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ClientRegisterCtrl', ClientRegisterCtrl);

    ClientRegisterCtrl.$inject = ['$scope', 'ModalService', 'ClientRegistrationService', 'LicenceService', 'GetAddressFactory', 'GetAddressService', 'DateFactory', 'AtlasCookieFactory', 'TrainerProfileService', 'OrganisationSelfConfigurationService', 'EmailService', '$window'];

    function ClientRegisterCtrl($scope, ModalService, ClientRegistrationService, LicenceService, GetAddressFactory, GetAddressService, DateFactory, AtlasCookieFactory, TrainerProfileService, OrganisationSelfConfigurationService, EmailService, $window) {
        $scope.client = new Object();
        $scope.client.Address = {};
        $scope.licenceData = {};
        $scope.client.licenceTypeId;
        $scope.client.licenceExpiryDate = "";
        $scope.client.licencePhotocardExpiryDate = "";
        $scope.client.Address.Address = "";
        $scope.client.Address.Postcode = "";
        $scope.client.phoneNumbers = new Array();
        $scope.client.licenceNumber = sessionStorage.licenceNumber;
        $scope.client.ukLicence = sessionStorage.ukLicence;
        $scope.client.firstName = "";
        $scope.client.otherNames = "";
        $scope.client.surname = "";
        $scope.client.displayName = "";
        $scope.client.displayNameChanged = false;

        $scope.displayCalendar = false;
        $scope.displayPhotoCalendar = false;

        $scope.selectedDORSSchemeName = sessionStorage.selectedDORSSchemeName;
        $scope.clientDORSData = JSON.parse(sessionStorage.clientDORSData);
        /**
         * Instantiate the transformed address list
         */
        $scope.TransformedAddressList = [];
        $scope.listOfLicenceTypes = [];
       
        $scope.saveClientDetails = function () {
            $scope.validateForm();
            //$scope.validationMessage = '';

            $scope.client["courseTypeId"] = JSON.parse(sessionStorage.getItem("selectedCourseTypeId"));
            $scope.client["regionId"] = JSON.parse(sessionStorage.getItem("selectedRegionId"));
            $scope.client.clientDORSData = $scope.clientDORSData;

            if ($scope.validationMessage == '') {

                //pick up last phone number
                $scope.addPhone();

                ClientRegistrationService.registerNewClient($scope.client)
                .then(
                    function (response) {
                        var authToken = response.headers("X-Auth-Token");
                        $scope.goToConfirmationPage(response.data, authToken);
                    },
                    function (reason) {
                        $scope.validationMessage = reason.data;
                    }
                );
            }
        }

        $scope.showSystemDetails = function () {
            $scope.organisationName = sessionStorage.organisationName;
            $scope.systemName = sessionStorage.systemName;
            $scope.client.licenceNumber = sessionStorage.licenceNumber;
            $scope.client.organisationId = sessionStorage.selectedProvider;
            $scope.client.ukLicence = sessionStorage.ukLicence;
            //$scope.client.licenceTypeId;
            //$scope.client.licenceExpiryDate = "";
            //$scope.client.licencePhotocardExpiryDate = "";
            //$scope.client.Address.Address = "";
            //$scope.client.Address.Postcode = "";
            //$scope.client.phoneNumbers = new Array();

            if ($scope.client.ukLicence) {
                $scope.licenceData = LicenceService.extractDriverDetails($scope.client.licenceNumber);
                $scope.client.firstName = $scope.licenceData.firstName;
                $scope.client.otherNames = $scope.licenceData.otherNames;
                $scope.client.surname = $scope.licenceData.surname;
            }

        }

        /**
         * Get the address choices
         */
        $scope.getAddressChoices = function () {

            GetAddressService.getAddress($scope.client.Address.Postcode)
                .then(function (response) {

                    /**
                     * Set the address list
                     */
                    //$scope.AddressList = response;
                    $scope.TransformedAddressList = response.Addresses;  
                }, function(response) {
                    alert("There was an issue retrieving your address");
                });
        }

        /**
         * Merge the address to enter in to the text field
         */
        $scope.selectAddress = function (theSelectedAddress) {

            if (theSelectedAddress ) {
                $scope.client.Address.Address = GetAddressFactory.format(theSelectedAddress);
            }
            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];

            /**
             * Empty the address List
             */
            $scope.AddressList = [];

        }

        $scope.addPhone = function () {
            if ($scope.phoneNumber != undefined && $scope.phoneNumber != '' && $scope.phoneNumberType != undefined && $scope.phoneNumberType != '') {
                var phoneNumber = new Object();
                phoneNumber.number = $scope.phoneNumber;
                phoneNumber.type = $scope.phoneNumberType;
                $scope.client.phoneNumbers.push(phoneNumber);
                $scope.phoneNumber = '';
                $scope.phoneNumberType = 'Mobile';
            }
        }

        $scope.deletePhoneNumber = function (phoneNumberIndex) {
            $scope.client.phoneNumbers.splice(phoneNumberIndex, 1);
        }

        /**
        * @todo refactor like below;
        */
        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
            if ($scope.displayPhotoCalendar == true)
            {
                $scope.displayPhotoCalendar = false;
            }
        }

        /**
         * @todo refactor this to merge with the toggleCalendar method
         */
        $scope.togglePhotoCalendar = function () {
            $scope.displayPhotoCalendar = !$scope.displayPhotoCalendar;
            if ($scope.displayCalendar == true) {
                $scope.displayCalendar = false;
            }
        }

        $scope.validateForm = function() {
            $scope.validationMessage = '';

            if ($scope.client.firstName == undefined || $scope.client.firstName.length < 2) {
                concatenateValidationMessage("Please enter a full first name");
            }
            if ($scope.client.surname == undefined || $scope.client.surname.length < 2) {
                concatenateValidationMessage("Please enter a full last name");
            }
            if ($scope.client.displayName == undefined || $scope.client.displayName.length < 4) {
                concatenateValidationMessage("Please enter a display name");
            }
            if ($scope.client.Address.Address == "" || $scope.client.Address.Address == undefined) {
                concatenateValidationMessage("Please enter an address");
            }
            if ($scope.client.Address.Postcode == "" || $scope.client.Address.Postcode == undefined) {
                concatenateValidationMessage("Please enter a post code");
            }
            if ($scope.client.email != $scope.client.confirmEmail) {
                concatenateValidationMessage("Your email addresses don't match");
            }
            if ($scope.client.email == "" || $scope.client.email == undefined) {
                concatenateValidationMessage("Please enter an email address");
            }
            if ($scope.client.email == "" || $scope.client.confirmEmail == undefined) {
                concatenateValidationMessage("Please enter an confirm email address");
            }
            if (!EmailService.validate($scope.client.email)) {
                $scope.validationMessage = "Email address not in a recognised format.";
            }
        }

        function concatenateValidationMessage(newMessage) {
            $scope.validationMessage += $scope.validationMessage != "" ? "\n" : "";
            $scope.validationMessage += newMessage;
        }

        // return the entry in the array based on the value, so we can bind the ddl to the selected array entry
        $scope.getPhoneNumberType = function (index) {
            return $scope.client.phoneNumbers[index].type;
        }

        $scope.formatDate = function (date) {
            return DateFactory.formatDateSlashes(date);
        }

        /**
         * Check the linence types
         */        
        TrainerProfileService.getDriverLicenceTypes() // TODO: move out of TrainerProfileService into a shared module
            .then(function (response) {
                /**
                 * Set the licenceTypes property on the scope
                 */
                $scope.listOfLicenceTypes = response;

            }, function () {
                $scope.listOfLicenceTypes = [];
            });


        $scope.showSystemDetails();

        /**
        * Get showPhotoCardExpiry
        */
        OrganisationSelfConfigurationService.GetByOrganisationForClientSite($scope.client.organisationId)
            .then(function (response) {
                $scope.client.showPhotoCardExpiry = response.ShowLicencePhotocardDetails;
                $scope.client.showDriversLicenceExpiryDate = response.ShowDriversLicenceExpiryDate;
            }, function (response) {
                 $scope.client.showPhotoCardExpiry = true;
             });


        /**
         * Check the client data
         */
        $scope.goToConfirmationPage = function (response, authToken) {

            /**
             * Set the auth token on session storage
             */
            sessionStorage.setItem("authToken", authToken);

            /**
             * Set the details on the window
             */
            sessionStorage.setItem("registrationDetails", JSON.stringify(response));


            /**
             * Send to the admin page
             */
            $window.location.href = "/login/confirmRegistration";

        }

        /**
         *  Go back to the last step
         */
        $scope.previousStep = function () {
            $window.location.href = "/login/organisationselection";
            exit(); // Stops any execution of code whilst processing page load
        };

        $scope.displayName = function () {
            if (!$scope.displayNameChanged) {
                if ($scope.client.title == undefined) {
                    $scope.client.title = '';
                }
                if ($scope.client.firstName == undefined) {
                    $scope.client.firstName = '';
                }
                if ($scope.client.surname == undefined) {
                    $scope.client.surname = '';
                }

                if ($scope.client.title.toLowerCase() == 'other') {
                    if ($scope.client.otherTitle == undefined) {
                        $scope.client.otherTitle = '';
                    }
                    if ($scope.client.otherTitle != '') {
                        $scope.client.displayName = $scope.client.otherTitle + " " + $scope.client.firstName + " " + $scope.client.surname;
                    } else {
                        $scope.client.displayName = $scope.client.firstName + " " + $scope.client.surname;
                    }
                }
                else {
                    if ($scope.client.title != '') {
                        $scope.client.displayName = $scope.client.title + " " + $scope.client.firstName + " " + $scope.client.surname;
                    } else {
                        $scope.client.displayName = $scope.client.firstName + " " + $scope.client.surname;
                    }
                }
            }
        }


    }
})();

