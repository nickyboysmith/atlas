(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientHomeCtrl", ClientHomeCtrl);

    ClientHomeCtrl.$inject = ["$scope", "$filter", "$window", "activeUserProfile", "StringService", "GenderService", "OrganisationSelfConfigurationService", "ClientService", "SignOutFactory"];

    function ClientHomeCtrl($scope, $filter, $window, activeUserProfile, StringService, GenderService, OrganisationSelfConfigurationService, ClientService, SignOutFactory) {

        /**
         * 
         */
        $scope.client = {};

        /**
         * Put orgname on the scope
         */
        $scope.organisationName = activeUserProfile.selectedOrganisation.Name;

      
        $scope.editMode = false;

        $scope.displayDOBCalendar = false;

        $scope.displayNameChanged = false;

        // capitalize sentences first time only flags
        $scope.capitalizeFirstNameFlag = true;
        $scope.capitalizeSurnameFlag = true;
        $scope.capitalizeOtherNameFlag = true;

        /**
       * Get client titles
       */
        ClientService.getClientTitles()
            .then(
                function (response) {
                    $scope.clientTitles = response.data;
                },
                function (response) {
                }
            );

        /**
      * Get client genders
      */
        GenderService.get()
            .then(
                function (response) {
                    $scope.clientGenders = response.data;


                },
                function (response) {
                }
            );

        /**
       * Get the client configuration options
       */

        OrganisationSelfConfigurationService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
            .then(
                function (response) {

                    $scope.showClientDisplayName = response.data.ShowClientDisplayName;

                },
                function (response) {
                }
            );

        /**
         * Get client details
         */
        ClientService.get(activeUserProfile.ClientId)
        .then(
            function (response) {
                console.log("Success");
                console.log(response.data);
                

                $scope.loadClient(response.data);

            },
            function (response) {
                console.log("Error");
                console.log(reponse);
            }
        );

        $scope.loadClient = function (client) {

            $scope.client = client;

            if ($scope.client.Title !== undefined) {

                if ($scope.isKnownTitle($scope.client.Title)) {
                    $scope.selectedTitle = $scope.client.Title;
                }
                else {

                    $scope.selectedTitle = 'Other';
                    $scope.client.OtherTitle = $scope.client.Title;
                }
            }

            $scope.selectedGenderId = $scope.client.GenderId;
            $scope.client.Gender = $scope.findGenderName($scope.selectedGenderId);

            $scope.client.DateOfBirth = $filter('date')($scope.client.DateOfBirth, 'dd-MMM-yyyy');

            if (client.ClientEmails.length > 0) {
                $scope.client.Email = client.ClientEmails[0].Email.Address;
                $scope.client.EmailId = client.ClientEmails[0].Email.Id;;
            }

            if (client.ClientLocations.length > 0) {
                $scope.client.Address = client.ClientLocations[0].Location.Address;
                $scope.client.AddressId = client.ClientLocations[0].Location.Id;
                //$scope.client.PostCode = client.ClientLocations[0].Location.PostCode;
            }

            if (client.ClientPhones.length > 0) {
                $scope.client.Phone = client.ClientPhones[0].PhoneNumber;
                $scope.client.PhoneId = client.ClientPhones[0].Id;
            }

        }

        $scope.saveClient = function () {

            $scope.validationMessage = "";

            validateForm();

            // if the title is other, set the title to the contents of the 'other' text
            if ($scope.selectedTitle == 'Other') {
                if (angular.isDefined($scope.client.OtherTitle)) {
                    $scope.client.Title = $scope.client.OtherTitle;
                }
                else {
                    $scope.client.Title = $scope.selectedTitle;
                }
            }
            else {
                $scope.client.Title = $scope.selectedTitle;
            }



            if ($scope.validationMessage == "") {
              

                $scope.validationMessage = "";
                $scope.saveStatusMessage = "";


                // Define a trimmed down client profile object to save
                $scope.clientProfile = {
                    ClientId :activeUserProfile.ClientId,
                    UpdatedByUserId: activeUserProfile.UserId,
                    Title: $scope.client.Title,
                    FirstName: $scope.client.FirstName,
                    OtherNames: $scope.client.OtherNames,
                    Surname: $scope.client.Surname,
                    DisplayName: $scope.client.DisplayName,
                    DateOfBirth: $scope.client.DateOfBirth,
                    AddressId: $scope.client.AddressId,
                    Address: $scope.client.Address,
                    EmailId: $scope.client.EmailId,
                    Email: $scope.client.Email,
                    PhoneId: $scope.client.PhoneId,
                    Phone: $scope.client.Phone,
                    GenderId: $scope.selectedGenderId
                };


                ClientService.saveProfile($scope.clientProfile)
                        .then(
                            function successCallback(response) {

                                $scope.saveStatusMessage = "Save successful."

                                /**
                                * reload the client details
                                */
                                ClientService.get(activeUserProfile.ClientId)
                                .then(
                                    function (response) {
         
                                        $scope.loadClient(response.data);
                                        $scope.editMode = !$scope.editMode;
                                    },
                                    function (response) {
                                       
                                    }
                                );
                            },
                            function errorCallback(response) {
                                if (!response.data == false) {
                                    $scope.validationMessage = response.data;
                                } else {
                                    $scope.validationMessage = "Unable to save please contact the administrator.";
                                }
                            }
                        );
                //}
            }
        }



        /**
         * Get Client Online Email Change Request
         */
        ClientService.getClientOnlineEmailChangeRequest(activeUserProfile.ClientId)
        .then(
            function successCallback(response) {
                $scope.clientOnlineEmailChangeRequest = response.data;
            },
            function errorCallback(response) {
                $scope.clientOnlineEmailChangeRequest.Status = "There was an error with our service. If the problem persists please contact support";
            }
        );

        /**
         * Cancel Email Change Request
         */
        $scope.cancelEmailChangeRequest = function () {
            ClientService.cancelEmailChangeRequest($scope.clientOnlineEmailChangeRequest.Id)
            .then(
                function successCallback(response) {
                    $scope.clientOnlineEmailChangeRequest = response.data;
                },
                function errorCallback(response) {
                    $scope.clientOnlineEmailChangeRequest.Status = "There was an error with our service. If the problem persists please contact support";
                }
            );
        }

        /**
         * Confirm Email Change Request
         */
        $scope.confirmEmailChangeRequest = function () {
            ClientService.confirmEmailChangeRequest($scope.clientOnlineEmailChangeRequest.Id, $scope.clientOnlineEmailChangeRequest.confirmationCode)
            .then(
                function successCallback(response) {
                    $scope.clientOnlineEmailChangeRequest = response.data;
                    if ($scope.clientOnlineEmailChangeRequest.EmailUpdated == true) {

                        $scope.client.ClientEmails[0].Email.Address = $scope.clientOnlineEmailChangeRequest.NewEmailAddress;
                        $scope.$apply();
                    }
                },
                function errorCallback(response) {
                    $scope.clientOnlineEmailChangeRequest.Status = "There was an error with our service. If the problem persists please contact support";
                }
            );
        }


        $scope.capitalizeFirstName = function (inputtedString) {
            if ($scope.capitalizeFirstNameFlag == true) {
                $scope.client.FirstName = StringService.Capitalize(inputtedString);
                $scope.capitalizeFirstNameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        $scope.displayName = function (selectedTitle) {
            if (!$scope.displayNameChanged) {

                $scope.selectedTitle = selectedTitle;

                if ($scope.selectedTitle == undefined) {
                    $scope.selectedTitle = '';
                }
                if ($scope.client.FirstName == undefined) {
                    $scope.client.FirstName = '';
                }
                if ($scope.client.Surname == undefined) {
                    $scope.client.Surname = '';
                }

                if ($scope.selectedTitle == 'Other') {
                    if ($scope.client.OtherTitle == undefined) {
                        $scope.client.OtherTitle = '';
                    }
                    if ($scope.client.OtherTitle != '') {
                        $scope.client.DisplayName = $scope.client.OtherTitle + " " + $scope.client.FirstName + " " + $scope.client.Surname;
                    }
                    else {
                        $scope.client.DisplayName = $scope.client.FirstName + " " + $scope.client.Surname;
                    }
                }
                else {
                    if ($scope.selectedTitle != '') {
                        $scope.client.DisplayName = $scope.selectedTitle + " " + $scope.client.FirstName + " " + $scope.client.Surname;
                    }
                    else {
                        $scope.client.DisplayName = $scope.client.FirstName + " " + $scope.client.Surname;
                    }
                }
            }
        }


        $scope.capitalizeSurname = function (inputtedString) {
            if ($scope.capitalizeSurnameFlag == true) {
                $scope.client.Surname = StringService.Capitalize(inputtedString);
                $scope.capitalizeSurnameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        $scope.capitalizeOtherNames = function (inputtedString) {
            if ($scope.capitalizeOtherNameFlag == true) {
                $scope.client.OtherNames = StringService.Capitalize(inputtedString);
                $scope.capitalizeOtherNameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        /**
         * Is the title a pre-defined one or it's 'Other'
         */
        $scope.isKnownTitle = function (clientTitle) {

            var KnownTitle = false;

            angular.forEach($scope.clientTitles, function (value, key) {

                if (value.StringId == clientTitle) {
                    KnownTitle = true;
                }

            });

            return KnownTitle;
        };

        /**
         * Is the title a pre-defined one or it's 'Other'
         */
        $scope.findGenderName = function (genderId) {

            var KnownGender = "";

            angular.forEach($scope.clientGenders, function (value, key) {

                if (value.Id == genderId) {
                    KnownGender = value.Name;
                }

            });

            return KnownGender;
        };


        $scope.changeGender = function (genderId) {
            $scope.selectedGenderId = genderId;
        }

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy')
        }

        $scope.toggleDOBCalendar = function () {
            $scope.displayDOBCalendar = !$scope.displayDOBCalendar;
        }

        /**
        * Cancel Email Change Request
        */
        $scope.cancelEditMode = function () {

            /**
            * reload the client details
            */
            ClientService.get(activeUserProfile.ClientId)
            .then(
                function (response) {

                    $scope.loadClient(response.data);
                    $scope.editMode = !$scope.editMode;
                },
                function (response) {

                }
            );

        }

        /**
         * toggle Edit Mode
         */
        $scope.toggleEditMode = function (editMode) {
            
            $scope.validationMessage = "";
            $scope.saveStatusMessage = "";

            $scope.editMode = !editMode;

            return $scope.editMode;
        }

        function validateForm() {
            $scope.validationMessage = "";
            $scope.saveStatusMessage = "";

            if ($scope.client.FirstName == undefined || $scope.client.FirstName == "") {
                $scope.validationMessage = "Please enter a first name";
            }
            else if ($scope.client.Surname == undefined || $scope.client.Surname == "") {
                $scope.validationMessage = "Please enter a last name";
            }
            else if ($scope.client.Email == "" || $scope.client.Email == undefined) {
                $scope.validationMessage = "Please enter an email address";
            }
            //else if ($scope.client.UKLicence == true && !$scope.isUKLicence($scope.client.LicenceNumber)) {
            //    $scope.validationMessage = "UK Licence number is not in the valid format.";
            //}
        }






        // If browser is closed (x) update ExpiresOn in LoginSession to Now() and Delete from Local Storage
        /*
        $scope.onExit = function () {

            //SignOutService.SignOut(activeUserProfile.UserId)
            //.then(function (data) {

            SignOutFactory.client();

            //}, function (data) {

            //});

        };

        // If browser is closed update 
        $window.onbeforeunload = $scope.onExit;
        */
        
    }

})();