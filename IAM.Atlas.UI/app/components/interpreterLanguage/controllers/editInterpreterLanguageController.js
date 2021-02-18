(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('EditInterpreterLanguageCtrl', EditInterpreterLanguageCtrl);

    EditInterpreterLanguageCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'GetAddressFactory', 'GetAddressService', 'DateFactory', 'OrganisationSelfConfigurationService', 'InterpreterLanguageService'];

    function EditInterpreterLanguageCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, GetAddressFactory, GetAddressService, DateFactory, OrganisationSelfConfigurationService, InterpreterLanguageService) {


        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.displayNameChanged = false;
        $scope.displayCalendar = false;

        $scope.interpreterTitles = {};
        $scope.selectedTitle = '';

        // Define the interpreter object
        $scope.interpreter = {
            InterpreterId : $scope.selectedInterpreter,
            OrganisationId: $scope.organisationId,
            UpdatedByUserId: $scope.userId,
            EmailId: "",
            AddressId: "",
            Title: "",
            OtherTitle: "",
            FirstName: "",
            OtherNames: "",
            Surname: "",
            DisplayName: "",
            DateOfBirth: "",
            Company: "",
            Address1: "",
            Address2: "",
            Town: "",
            County: "",
            PostCode: "",
            Country: "",
            Email: "",
            Languages: [],
            Notes: [],
            PhoneNumbers: [],
            phoneNumber: "",
            phoneNumberType: "",
            Disabled: false
        };

        $scope.getInterpreterTitles = function () {
            InterpreterLanguageService.getInterpreterTitles()
                    .then(
                        function (response) {
                            $scope.interpreterTitles = response.data;
                        },
                        function (response) {
                        }
                    );
        }

        $scope.getInterpreterConfigurationOptions = function () {
            OrganisationSelfConfigurationService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
                    .then(
                        function (response) {
                            $scope.showClientDisplayName = response.data.ShowClientDisplayName;
                        },
                        function (response) {
                        }
                    );
        }

        $scope.getInterpreterById = function (interpreterId) {
            InterpreterLanguageService.getInterpreterById(interpreterId)
                    .then(
                        function (response) {
                            $scope.transformInterpreter(response.data[0]);
                        },
                        function (response) {
                        }
                    );
        }

        $scope.getInterpreterNotesById = function (interpreterId) {
            InterpreterLanguageService.getInterpreterNotesById(interpreterId)
                    .then(
                        function (response) {
                            $scope.interpreter.Notes = response.data[0];
                        },
                        function (response) {
                        }
                    );
        }

        /*
        * transform the interpreter into the $scope.interpreter object
        */
        $scope.transformInterpreter = function (Interpreter) {

            //$scope.interpreter.OrganisationId: $scope.organisationId,
            $scope.interpreter.UpdatedByUserId = $scope.userId;

            if ($scope.isKnownTitle(Interpreter.Title)) {
                $scope.selectedTitle = Interpreter.Title;
                $scope.interpreter.Title = Interpreter.Title; 
            }
            else {
                $scope.selectedTitle = 'Other';
                $scope.interpreter.OtherTitle = Interpreter.Title;
            }

            $scope.interpreter.FirstName = Interpreter.FirstName;
            $scope.interpreter.OtherNames = Interpreter.OtherNames;
            $scope.interpreter.Surname = Interpreter.Surname;
            $scope.interpreter.DisplayName = Interpreter.DisplayName;

            $scope.interpreter.DateOfBirth = $filter('date')(Interpreter.DateOfBirth, 'dd-MMM-yyyy')
            
            //$scope.interpreter.Address1 = Interpreter.Address1;
            //$scope.interpreter.Address2 = Interpreter.Address2;
            //$scope.interpreter.Town = Interpreter.Town;
            //$scope.interpreter.County = Interpreter.County;

            if (Interpreter.InterpreterLocations.length > 0) {
                $scope.interpreter.PostCode = Interpreter.InterpreterLocations[0].Location.PostCode;
                $scope.interpreter.Address = Interpreter.InterpreterLocations[0].Location.Address;
                $scope.interpreter.AddressId = Interpreter.InterpreterLocations[0].Location.Id;
            }
            
            if (Interpreter.InterpreterEmails.length > 0) {
                $scope.interpreter.EmailId = Interpreter.InterpreterEmails[0].Email.Id;
                $scope.interpreter.Email = Interpreter.InterpreterEmails[0].Email.Address;
            }
    
            if (Interpreter.InterpreterPhones.length > 0) {
                $scope.interpreter.PhoneNumbers = Interpreter.InterpreterPhones;
            }

            if (Interpreter.InterpreterLanguages.length > 0) {

                // Remove the additional .Language object.
                // Puts Id and Englishname into parent Language object
                Interpreter.InterpreterLanguages.forEach(function (arrayItem) {
                    $scope.interpreter.Languages.push(arrayItem.Language);
                });

                //$scope.interpreter.Languages = Interpreter.InterpreterLanguages;
            }

            if (Interpreter.InterpreterNotes.length > 0) {
                $scope.interpreter.Notes = Interpreter.InterpreterNotes;
            }

            $scope.interpreter.Disabled = Interpreter.Disabled;
            
        }

        $scope.displayName = function (selectedTitle) {
            if (!$scope.displayNameChanged) {

                $scope.selectedTitle = selectedTitle;

                if ($scope.selectedTitle == undefined) {
                    $scope.selectedTitle = '';
                }
                if ($scope.interpreter.FirstName == undefined) {
                    $scope.interpreter.FirstName = '';
                }
                if ($scope.interpreter.Surname == undefined) {
                    $scope.interpreter.Surname = '';
                }

                if ($scope.selectedTitle == 'Other') {
                    if ($scope.interpreter.OtherTitle == undefined) {
                        $scope.interpreter.OtherTitle = '';
                    }
                    if ($scope.interpreter.OtherTitle != '') {
                        $scope.interpreter.DisplayName = $scope.interpreter.OtherTitle + " " + $scope.interpreter.FirstName + " " + $scope.interpreter.Surname;
                    } else {
                        $scope.interpreter.DisplayName = $scope.interpreter.FirstName + " " + $scope.interpreter.Surname;
                    }
                }
                else {
                    if ($scope.selectedTitle != '') {
                        $scope.interpreter.DisplayName = $scope.selectedTitle + " " + $scope.interpreter.FirstName + " " + $scope.interpreter.Surname;
                    } else {
                        $scope.interpreter.DisplayName = $scope.interpreter.FirstName + " " + $scope.interpreter.Surname;
                    }
                }
            }
        }

        /**
        * Get the address choices
        */
        $scope.getAddressChoices = function () {
            GetAddressService.getAddress($scope.interpreter.PostCode)
                .then(function (response) {
                    $scope.TransformedAddressList = response.Addresses;

                }, function(response) {
                    alert("There was an issue retrieving your address");
                });
        }

        /**
        * Merge the address to enter in to the text field
        */
        $scope.selectAddress = function (theSelectedAddress) {

            if (theSelectedAddress) {
                $scope.interpreter.Address = GetAddressFactory.format(theSelectedAddress);
            }

            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];
        }

        $scope.addPhone = function () {
            if ($scope.interpreter.phoneNumber != undefined && $scope.interpreter.phoneNumber != '' && $scope.interpreter.phoneNumberType != undefined && $scope.interpreter.phoneNumberType != '') {
                var phoneNumber = new Object();
                phoneNumber.Number = $scope.interpreter.phoneNumber;
                phoneNumber.PhoneType = {};
                phoneNumber.PhoneType.Type = $scope.interpreter.phoneNumberType;
                $scope.interpreter.PhoneNumbers.push(phoneNumber);
                $scope.interpreter.phoneNumber = "";
                $scope.interpreter.phoneNumberType = "";
            }
        }

        $scope.deletePhoneNumber = function (phoneNumberIndex) {
            if ($scope.interpreter.PhoneNumbers) {
                $scope.interpreter.PhoneNumbers.splice(phoneNumberIndex, 1);
            }
        }

        $scope.getPhoneNumberType = function (index) {
            return $scope.interpreter.PhoneNumbers[index].PhoneType.Type;
        }

        $scope.updatePhoneType = function (item, index) {
            $scope.interpreter.PhoneNumbers[index].PhoneType.Type = item;
        }

        $scope.updatePhoneNumber = function (item, index) {
            $scope.interpreter.PhoneNumbers[index].PhoneNumber = item;
        }

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy');
        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
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

        $scope.save = function () {


            if ($scope.validateEditInterpreter()) {


                var address1 = angular.element(document.querySelector('#Address1'));
                var address2 = angular.element(document.querySelector('#Address2'));
                var town = angular.element(document.querySelector('#Town'));
                var county = angular.element(document.querySelector('#County'));

                $scope.interpreter.Address1 = address1[0].value;
                $scope.interpreter.Address2 = address2[0].value;
                $scope.interpreter.Town = town[0].value;
                $scope.interpreter.County = county[0].value;

                // if the title is Other, set the title to the contents of the 'Other' text
                if ($scope.selectedTitle == 'Other') {
                    if (angular.isDefined($scope.interpreter.OtherTitle)) {
                        $scope.interpreter.Title = $scope.interpreter.OtherTitle;
                    }
                    else {
                        $scope.interpreter.Title = $scope.selectedTitle;
                    }
                }
                else {
                    $scope.interpreter.Title = $scope.selectedTitle;
                }

                InterpreterLanguageService.saveEdit($scope.interpreter)
                        .then(
                            function (response) {

                                $scope.successMessage = response.data;
                            },
                            function (response) {

                                $scope.validationMessage = response.data;

                            }
                        );
            }

        };



        /**
         * Open the add language modal
         */
        $scope.openAddLanguageModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Language",
                closable: true,
                filePath: "/app/components/interpreterLanguage/addLanguage.html",
                controllerName: "AddLanguageCtrl",
                cssClass: "AddLanguageModal",
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
         * Open the add language modal
         */
        $scope.openAddNoteModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Note",
                closable: true,
                filePath: "/app/components/interpreterLanguage/addNote.html",
                controllerName: "AddInterpreterNoteCtrl",
                cssClass: "AddInterpreterNoteModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };


        $scope.isValidEmail = function (emailaddess) {

            //ref
            //http://stackoverflow.com/questions/46155/validate-email-address-in-javascript

            var emailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

            var validEmail = emailFormat.test(emailaddess);

            return validEmail;
        }

        $scope.validateEditInterpreter = function () {

            $scope.validationMessage = '';

            if ($scope.interpreter.FirstName == undefined || $scope.interpreter.FirstName == "") {
                $scope.validationMessage = "Please Enter a First Name";
            }
            else if ($scope.interpreter.Surname == undefined || $scope.interpreter.Surname == "") {
                $scope.validationMessage = "Please Enter a Surname";
            }
            else if ($scope.interpreter.PostCode == undefined || $scope.interpreter.PostCode == "") {
                $scope.validationMessage = "Please Enter a PostCode";
            }
            else if ($scope.interpreter.Address == undefined || $scope.interpreter.Address == "") {
                $scope.validationMessage = "Please Enter a Valid Address or Select an Address from the Find Address List";
            }
            else if (!$scope.isValidEmail($scope.interpreter.Email)) {
                $scope.validationMessage = "Invalid Interpreter Email Address";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }




        $scope.getInterpreterConfigurationOptions();
        $scope.getInterpreterTitles();
        $scope.getInterpreterNotesById($scope.selectedInterpreter);
        $scope.getInterpreterById($scope.selectedInterpreter);


    }

})();