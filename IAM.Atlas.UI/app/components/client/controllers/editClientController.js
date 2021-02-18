(function () {
    'use strict';

    angular
        .module('app')
        .controller('editClientCtrl', ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'ClientService', 'OrganisationSelfConfigurationService', 'DateFactory', 'ModalService', 'activeUserProfile', 'StringService', 'EmailService', 'GetAddressService', 'GetAddressFactory', editClientCtrl]);

    function editClientCtrl($scope, $location, $window, $http, $filter, UserService, ClientService, OrganisationSelfConfigurationService, DateFactory, ModalService, activeUserProfile, StringService, EmailService, GetAddressService, GetAddressFactory) {

        $scope.showPhotocardExpiry = true;
        $scope.showClientDisplayName = true;
        $scope.showDriversLicenceExpiryDate = true;

        $scope.userService = UserService;
        $scope.clientService = ClientService;
        $scope.modalService = ModalService;
        $scope.selectedDate = new Date();

        $scope.displayNameChanged = false;
        $scope.displayCalendar = false;
        $scope.client.postcode = "";

        $scope.client = new Object();
        //$scope.client.phoneNumbers = new Array();

        $scope.validationMessage = "";
        $scope.client.phoneNumber = '';
        $scope.client.LicenceNumber = "";

        $scope.clientTitles = {};
        $scope.selectedTitle = '';

        $scope.DOBDiffersFromLicence = true;

        $scope.displayDOBCalendar = false;

        /**
         * 
         */
        $scope.mobileExists = "";
        $scope.emailExists = "";

        // capitalize sentences first time only flags
        $scope.capitalizeFirstNameFlag = true;
        $scope.capitalizeSurnameFlag = true;
        $scope.capitalizeOtherNameFlag = true;

        /**
        * Get the client configuration options
        */
        $scope.getClientConfigurationOptions = function (organisationId) {
            OrganisationSelfConfigurationService.GetByOrganisation(organisationId)
                    .then(
                        function (response) {
                            $scope.showPhotoCardExpiry = response.data.ShowLicencePhotocardDetails;
                            $scope.showClientDisplayName = response.data.ShowClientDisplayName;
                            $scope.showDriversLicenceExpiryDate = response.data.ShowDriversLicenceExpiryDate;
                        },
                        function (response) {
                        }
                    );
        }


        $scope.getClientTitles = function () {
            ClientService.getClientTitles()
                    .then(
                        function (response) {
                            $scope.clientTitles = response.data;
                        },
                        function (response) {
                        }
                    );
        }

        $scope.getDriverLicenceTypes = function () {
            ClientService.getDriverLicenceTypes()
               .then(
                    function (response) {
                       $scope.licenceTypes = response;
                    },
                    function () {
                    }
               );
        }


        $scope.getClientNotesById = function (clientId) {
            ClientService.getClientNotesById(clientId)
                    .then(
                        function (response) {
                            $scope.client.Notes = response.data[0];
                        },
                        function (response) {
                        }
                    );
        }


        /*
         * load the returned client object into the $scope
         */
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

            if (client.ClientEmails.length > 0) {
                $scope.client.Email = client.ClientEmails[0].Email.Address;
            }

            if (client.ClientLocations.length > 0) {
                $scope.client.Address = client.ClientLocations[0].Location.Address;
                $scope.client.postcode = client.ClientLocations[0].Location.PostCode;
            }

            if (client.ClientMysteryShoppers.length > 0) {
                $scope.client.IsMysteryShopper = true;
            }

            if (client.ClientLicences.length > 0) {
                $scope.client.UKLicence = client.ClientLicences[client.ClientLicences.length - 1].UKLicence;
                $scope.client.LicenceNumber = client.ClientLicences[client.ClientLicences.length - 1].LicenceNumber;
                $scope.client.LicenceTypeId = client.ClientLicences[client.ClientLicences.length - 1].DriverLicenceTypeId;
                $scope.client.LicenceExpiryDate = client.ClientLicences[client.ClientLicences.length - 1].LicenceExpiryDate;
                $scope.client.LicencePhotoCardExpiryDate = client.ClientLicences[client.ClientLicences.length - 1].LicencePhotoCardExpiryDate;

                if ($scope.client.LicenceNumber != '') {
                    $scope.returnBirthdateFromUkLicenceNumber();
                }
            }
            else {
                $scope.client.LicenceNumber = "";
            }

            //if (client.DateOfBirth !== null && client.DateOfBirth.length > 0) {
            //    $scope.client.DateOfBirth = $filter('date')(client.DateOfBirth, 'dd-MMM-yyyy')
            //}

            if (client.ClientPhones.length > 0) {
                $scope.client.ClientPhones = client.ClientPhones;
            }

            if (client.ClientPreviousIds.length > 0) {
                $scope.client.PreviousIds = client.ClientPreviousIds;
            }

            //if (client.ClientOrganisations[0].Organisation.OrganisationSelfConfigurations[0].ShowLicencePhotocardDetails != true) {
            //    $scope.showPhotocardExpiry = false;
            //}            

            /**
            * Call the client configuration options
            */
            $scope.getClientConfigurationOptions(activeUserProfile.selectedOrganisation.Id);
            $scope.getClientNotesById($scope.client.Id);
            /**
             * Once the client data has loaded
             * Check to see if the mobilenumber & emails exist
             */
            $scope.mobileExists = $scope.checkMobileExists();
            $scope.emailExists = $scope.checkEmailAddressExists();

        }

        /**
         * Check to see
         * If the client Id was set on the parent scope
         * If it was set the name & client Id on current scope
         */
        if ($scope.clientId) {
            $scope.clientService.get($scope.clientId)
                .then(function (response) {
                    $scope.loadClient(response.data);

                    /**
                     * client setup close
                    **/
                    angular.forEach(BootstrapDialog.dialogs, function (dialog, Id) {
                        ModalService.getCurrentModalByClass('clientEditModal')
                        dialog.defaultOptions.onhide = function () {
                            $scope.removeClientLock($scope.client.Id);
                        }
                    });

                }, function(response) {
                });
        }

        /**
         * One the edit page we only need to add the lock
         * can only access the edit screen if it is not locked
         */
        ClientService.addClientLock($scope.clientId, activeUserProfile.UserId)
        .then(
            function (response) {
            },
            function (reason) {
                console.log(reason);
            }
        );


        /**
         * Call the client service to Delete Client Lock 
         */
        $scope.removeClientLock = function (Id) {
            ClientService.removeClientLock(Id)
            .then(
                function (response) {
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        $scope.postcodePopulate = function () {
            $scope.client.postcode = $scope.postcodeAddressLookup;
        }

        //Get Address

        $scope.getAddressChoices = function () {

            GetAddressService.getAddress($scope.client.postcode)

                .then(function (response) {

                    /**
                     * Set the address list
                     */
                    //$scope.AddressList = response;
                    $scope.TransformedAddressList = response.Addresses;
                    /**
                     * Transform the Address List
                     */
                    //$scope.TransformedAddressList = GetAddressFactory.transform(response.Addresses);

                }, function (response) {
                    alert("There was an issue retrieving your address");
                });
        }

        $scope.selectAddress = function (selectedAddress) {

            //if (theSelectedAddress) {
            //    $scope.trainer.Address.Address = GetAddressFactory.format(theSelectedAddress);
            //}
            if (selectedAddress) {
                $scope.client.county = GetAddressFactory.format(selectedAddress);
                $scope.client.Address = $scope.client.county;
                //client.ClientLocations[0].Location.Address = $scope.client.Address;
                //client.ClientLocations[0].Location.PostCode = $scope.client.postcode;
            }


            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];
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


        $scope.addPhone = function () {
            if ($scope.client.phoneNumber != undefined && $scope.client.phoneNumber != '' && $scope.client.phoneNumberType != undefined && $scope.client.phoneNumberType != '') {
                var phoneNumber = new Object();
                phoneNumber.PhoneNumber = $scope.client.phoneNumber;
                phoneNumber.PhoneType = {};
                phoneNumber.PhoneType.Type = $scope.client.phoneNumberType;
                $scope.client.ClientPhones.push(phoneNumber);
                $scope.client.phoneNumber = "";
                $scope.client.phoneNumberType = "";
                //phoneNumber = "";
                //phoneNumberType = "Mobile";
            }
        }

        $scope.deletePhoneNumber = function (phoneNumberIndex) {
            if ($scope.client.ClientPhones) {
                $scope.client.ClientPhones.splice(phoneNumberIndex, 1);
            }
        }

        // return the entry in the array based on the value, so we can bind the ddl to the selected array entry
        $scope.getPhoneNumberType = function (index) {
            return $scope.client.ClientPhones[index].PhoneType.Type;
        }

        $scope.updatePhoneType = function (item, index) {
            $scope.client.ClientPhones[index].phoneType.Type = item;
        }

        $scope.updatePhoneNumber = function (item, index) {
            $scope.client.ClientPhones[index].PhoneNumber = item;
        }

        /**
         * @todo refactor like below;
         */
        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        /**
         * @todo refactor this to merge with the toggleCalendar method
         */
        $scope.togglePhotoCalendar = function () {
            $scope.displayPhotoCalendar = !$scope.displayPhotoCalendar;
        }


        $scope.toggleDOBCalendar = function () {
           $scope.displayDOBCalendar = !$scope.displayDOBCalendar;

        }

        $scope.ckeckDOBAgainstLicence = function () {
            if ($scope.displayDOBCalendar == false) {
                $scope.client.DOBDiffersFromLicence = false;
                if (!$scope.client.birthdateFromUkLicenceNumber == false
                        && !$scope.client.DateOfBirth == false
                        && $scope.client.birthdateFromUkLicenceNumber != $filter('date')($scope.client.DateOfBirth, "dd-MMM-yyyy")) {
                    $scope.client.DOBDiffersFromLicence = true;
                }
            }
        }

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy')
        }

        $scope.addClient = function () {

            var company = angular.element(document.querySelector('#company'));
            var address1 = angular.element(document.querySelector('#address1'));
            var address2 = angular.element(document.querySelector('#address2'));

            var town = angular.element(document.querySelector('#town'));
            var county = angular.element(document.querySelector('#county'));

            $scope.client.company = company[0].value;
            $scope.client.address1 = address1[0].value;
            $scope.client.address2 = address2[0].value;
            $scope.client.town = town[0].value;
            $scope.client.county = county[0].value;

            validateForm();

            if ($scope.validationMessage == "") {


                $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

                $http.post(apiServer + '/client', $scope.client)
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available
                    console.log(data.toLowerCase().indexOf("success"));
                    console.log(data);
                    if (data === "success") {
                        /**
                         * Close the modal
                         * & pass the message back to the prvious modal
                         */
                        if ($scope.$parent.closeTheActiveModal !== undefined) {
                            $scope.$parent.printSuccessMessage("Updated " + $scope.client.DisplayName + "'s Client details.");
                            $scope.$parent.cancelAddUser($scope.$parent.closeTheActiveModal);
                        }

                        $scope.feedbackSent = true;

                    }
                    else {

                        $scope.validationMessage = "An error occurred please try again.";
                    }
                }, function(data, status, headers, config) {


                    $scope.validationMessage = "An error occurred please try again.";
                });
            }
        }

        // validate licence is a UK licence
        // @todo combine this function and the fn in addclient to one function
        $scope.isUKLicence = function (licence) {
            var regex = /[a-zA-Z0-9]{5}\d[0156]\d([0][1-9]|[12]\d|3[01])\d[a-zA-Z0-9]{3}[a-zA-Z]{2}/;
            return regex.test(licence);
        }

        function validateForm() {
            $scope.validationMessage = '';
            $scope.saveStatusMessage = "";

            if ($scope.client.FirstName == undefined || $scope.client.FirstName == "") {
                $scope.validationMessage = "Please enter a first name";
            }
            else if ($scope.client.Surname == undefined || $scope.client.Surname == "") {
                $scope.validationMessage = "Please enter a last name";
            }
            else if ($scope.client.UKLicence == true && !$scope.isUKLicence($scope.client.LicenceNumber)) {
                $scope.validationMessage = "UK Licence number is not in the valid format.";
            }
            else if ($scope.client.email) {
                if ($scope.client.email.length > 0) {
                    if (!EmailService.validate($scope.client.email)) {
                        $scope.validationMessage = "Email address not in recognised format.";
                    }
                }
            }
        }

        /**
         * Get the search content ffrom the Web API
         */
        $scope.getSearchableItems = function (searchContent) {

            /**
             * Set the search content
             * To a property on the scope
             */
            $scope.searchContent = searchContent;

            /**
             * Create search options object
             */
            var searchOptions = {
                    organisationId: activeUserProfile.selectedOrganisation.Id,
                    content: $scope.searchContent
        };

            /**
             * Return the related content
             */

            return $scope.userService.getOrganisationUsersQuickSearch(activeUserProfile.selectedOrganisation.Id, $scope.searchContent);
        };

        $scope.checkSMSFunctionalityStatus = function (organisationId) {
            OrganisationSelfConfigurationService.checkSMSFunctionalityStatus(organisationId)
                    .then(function (response) {
                        $scope.isSMSEnabled = response.data
                    });
        }

        $scope.selectedUser = function (user) {

            $scope.userService.isAssignedToClient(user.Id)
                .then(function (data) {
                    if (data == true) {
                        $scope.validationMessage = "This User is already bound to a Client's Details.";
                        $('#userText').val('');
                    }
                    else {
                        $scope.validationMessage = "";
                        $scope.saveStatusMessage = "";
                        $scope.client.UserId = user.Id;
                    }
                }, function() {
                });
        }

        $scope.saveClient = function () {
            if ($scope.client.Address == "" || $scope.client.Address == undefined || $scope.client.Address == null) {
                $scope.validationMessage = "You must enter an address to proceed";
            }
            else {


                $scope.validationMessage = "";

                validateForm();

                $scope.client.UpdatedByUserId = activeUserProfile.UserId;
                $scope.client.CreatedByUserId = activeUserProfile.UserId;

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
                    if ($scope.client.UKLicence == false && $scope.client.LicenceNumber.length < 5) {
                        $scope.validationMessage = "Non-UK licences must have at least 5 characters."
                    }
                    else {

                        //pick up last phone number
                        $scope.addPhone();

                        $scope.validationMessage = "";
                        $scope.saveStatusMessage = "";

                        $scope.clientService.save($scope.client)
                            .then(
                                function successCallback(response) {

                                    if ($scope.clientId) {
                                        $scope.clientService.get($scope.clientId)
                                            .then(function (response) {
                                                $scope.loadClient(response.data);
                                                $scope.saveStatusMessage = "Save successful."

                                                $scope.setFlagToRefreshClientHistory();

                                                if ($scope.loadClientDetails) {
                                                    $scope.loadClientDetails($scope.clientId);
                                                }

                                            }, function (response) {
                                            });
                                    }
                                },
                                function errorCallback(response) {
                                    if (!response.data == false) {
                                        $scope.validationMessage = response.data;
                                    } else {
                                        $scope.validationMessage = "Unable to save please contact the administrator.";
                                    }
                                }
                            );
                    }
                }
            }
        }

        $scope.addNote = function (clientId) {
            // reset the parameter so the watch in the history directive on the client details modal is still watching
            if ($scope.resetClientHistoryRefresh) {
                $scope.resetClientHistoryRefresh();
            }

            // open client details Modal
            $scope.clientId = clientId;
            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Add Client Note",
                    cssClass: "addClientNoteModal",
                    filePath: "/app/components/client/addNote.html",
                    controllerName: "addClientNoteCtrl"
            });
        }

        /**
         * Check a mobile number exists
         */
        $scope.checkMobileExists = function () {
            var status = false;
            angular.forEach($scope.client.ClientPhones, function (value, index) {
                if (value.PhoneType.Type === "Mobile") {
                    status = true;
        };
            });
            return status;
        };

        /**
         * Check an email address exists
         */
        $scope.checkEmailAddressExists = function () {
            if ($scope.client.ClientEmails.length > 0) {
                return true;
            }
            return false;
        };

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
         * 
         */
        $scope.processEmailConfirmation = function () {
            console.log("ProcessingInstruction");
            console.log($scope.client.Id);
            ClientService.createEmailReference({
                    clientName: $scope.client.FirstName + "" + $scope.client.Surname,
                    emailAddress: $scope.client.ClientEmails[0].Email.Address,
                // clientId: $scope.client.Id,
                    organisationId: activeUserProfile.selectedOrganisation.Id
            })
            .then(
                function (response) {
                    console.log("Success");
                    console.log(response);
                    $scope.loadClient(response.data);
            },
                function (response) {
                    console.log("Error");
                    console.log(response);
                }
            );
        };

        /**
         * 
         */
        $scope.processSMSConfirmation = function () {
            console.log("Open modal");
            ModalService.displayModal({
                scope: $scope,
                    title: "Unavailable Feature",
                    cssClass: "featureUnavailableModal",
                    filePath: "/app/shared/core/featureUnavailable.html",
                    controllerName: "AddDORSConnectionCtrl",
                    buttons: {
                    label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                    }
                }

            });
        };

        $scope.capitalizeFirstName = function (inputtedString) {
            if($scope.capitalizeFirstNameFlag == true){
                $scope.client.FirstName = StringService.Capitalize(inputtedString);
                $scope.capitalizeFirstNameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        $scope.capitalizeSurname = function (inputtedString) {
            if($scope.capitalizeSurnameFlag == true){
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



        $scope.capitaliseAddress = function (addressInput) {
            $scope.client.Address = StringService.toTitleCase(addressInput);
        }
        
        $scope.refreshNotes = function () {
            $scope.getClientNotesById($scope.client.Id);
        }

        $scope.getClientTitles();
        $scope.getDriverLicenceTypes();


        $scope.returnBirthdateFromUkLicenceNumber = function () {
            ClientService.returnBirthdateFromUkLicenceNumber($scope.client.LicenceNumber)
                .then(
                    function successCallback(response) {
                        $scope.client.birthdateFromUkLicenceNumber = $filter('date')(response.data, 'dd-MMM-yyyy');
                        $scope.ckeckDOBAgainstLicence();
                },
                    function errorCallback(response) {
                        //TODO: do we care if the call fails
                }
            );
        }

        UserService.isMysteryShopperAdministrator(activeUserProfile.UserId)
               .then(
                   function (data) {
                       if (data == true) {
                           $scope.IsMysteryShopperAdministrator = true;
                       }
                       else {
                           $scope.IsMysteryShopperAdministrator = false;
                       }
                   },
                   function (data) {
                       $scope.IsMysteryShopperAdministrator = false;
                   }
               );


        $scope.checkSMSFunctionalityStatus(activeUserProfile.selectedOrganisation.Id);

    }


})();