(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddInterpreterLanguageCtrl', AddInterpreterLanguageCtrl);

    AddInterpreterLanguageCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'GetAddressFactory', 'GetAddressService', 'DateFactory', 'OrganisationSelfConfigurationService', 'InterpreterLanguageService'];

    function AddInterpreterLanguageCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, GetAddressFactory, GetAddressService, DateFactory, OrganisationSelfConfigurationService, InterpreterLanguageService) {

       
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.displayNameChanged = false;
        $scope.displayCalendar = false;

        $scope.interpreterTitles = {};
        $scope.selectedTitle = '';

        // Define the interpreter object
        $scope.interpreter = {
            OrganisationId: $scope.organisationId,
            CreatedByUserId: $scope.userId,
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
            Country:"",
            Email: "",
            Languages: [],
            PhoneNumbers: [],
            phoneNumber: "",
            phoneNumberType: ""
        };

      
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
                $scope.interpreter.County = GetAddressFactory.format(theSelectedAddress);
            }

            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];
        }

         $scope.formatDate = function (date) {
             return $filter('date')(date, 'dd-MMM-yyyy');
        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

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
        

        $scope.save = function () {


            if ($scope.validateAddInterpreter()) {


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

                InterpreterLanguageService.saveAdd($scope.interpreter)
                        .then(
                            function (response) {

                                $scope.successMessage = response.data;
                            },
                            function (response) {

                                $scope.validationMessage = response.data;

                            }
                        );
            }

        }


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


        $scope.addPhone = function () {
            if ($scope.interpreter.phoneNumber != undefined && $scope.interpreter.phoneNumber != '' && $scope.interpreter.phoneNumberType != undefined && $scope.interpreter.phoneNumberType != '') {
                var phoneNumber = new Object();
                phoneNumber.PhoneNumber = $scope.interpreter.phoneNumber;
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

        // return the entry in the array based on the value, so we can bind the ddl to the selected array entry
        $scope.getPhoneNumberType = function (index) {
            return $scope.interpreter.PhoneNumbers[index].PhoneType.Type;
        }

        $scope.updatePhoneType = function (item, index) {
            $scope.interpreter.PhoneNumbers[index].PhoneType.Type = item;
        }

        $scope.updatePhoneNumber = function (item, index) {
            $scope.interpreter.PhoneNumbers[index].PhoneNumber = item;
        }

        $scope.isValidEmail = function (emailaddess) {

            //ref
            //http://stackoverflow.com/questions/46155/validate-email-address-in-javascript

            var emailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

            var validEmail = emailFormat.test(emailaddess);

            return validEmail;
        }

        $scope.validateAddInterpreter = function () {

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
            else if ($scope.interpreter.County == undefined || $scope.interpreter.County == "") {
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

    }

})();