(function () {
    'use strict';

    angular
        .module('app')
        .controller('addClientCtrl', ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'GetAddressFactory', 'GetAddressService', 'DateFactory', 'ReferringAuthorityService', 'ClientService', 'OrganisationSystemConfigurationService', 'OrganisationSelfConfigurationService', 'DorsService', 'StringService', "GenderService", "ModalService", "EmailService" , addClientCtrl]);

    function addClientCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, GetAddressFactory, GetAddressService, DateFactory, ReferringAuthorityService, ClientService, OrganisationSystemConfigurationService, OrganisationSelfConfigurationService, DorsService, StringService, GenderService, ModalService, EmailService) {

        $scope.userService = UserService;
        $scope.selectedDate = new Date();

        $scope.displayNameChanged = false;
        $scope.displayCalendar = false;
        $scope.displayDORSExpiryCalendar = false;
        $scope.displayDORSRefferalCalendar = false;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.client = new Object();
        $scope.client.phoneNumbers = new Array();
        $scope.client.UKLicence = true;
        $scope.client.insertedClientId = 0;

        $scope.clientTitles = {};
        $scope.client.genders = {};
        $scope.selectedTitle = '';
        $scope.client.showDeletionRow = false;

        $scope.phoneNumber = '';
        $scope.phoneNumberType = {};

        $scope.showPhotoCardsExpiry = false;

        $scope.referringAuthorities = [];
        $scope.client.isDORSClient = true;

        $scope.AllowManualEditingOfClientDORSData = false;
        $scope.client.DataValidatedAgainstDORS = false;
        $scope.checkingDORS = false;
        $scope.clientAdded = false;

        $scope.DOBDiffersFromLicence = true;

        // capitalize sentences first time only flags
        $scope.capitalizeFirstNameFlag = true;
        $scope.capitalizeSurnameFlag = true;
        $scope.capitalizeOtherNameFlag = true;

        $scope.client.EmailCourseReminders = false;
        $scope.client.SMSCourseReminders = false;
        $scope.client.isMysteryShopper = false;

        /**
         * Check to see
         * If the client Id was set on the parent scope
         * If it was set the name & client Id on current scope
         */
        if ($scope.$parent.clientId !== undefined) {
            $scope.client.Id = $scope.$parent.clientId;
            $scope.client.displayName = $scope.$parent.name;
        }

        //$scope.postcodePopulate = function () {
        //    $scope.client.postcode = $scope.postcodeAddressLookup;
        //}

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy');
        }


        $scope.checkDOBAgainstLicence = function () {
            if ($scope.displayDOBCalendar === false) {
                $scope.client.DOBDiffersFromLicence = false;
                if (!$scope.client.birthdateFromUkLicenceNumber === false && !$scope.client.DateOfBirth === false && $scope.client.birthdateFromUkLicenceNumber !== $scope.client.DateOfBirth) {
                    $scope.client.DOBDiffersFromLicence = true;
                }
            }
        }

        $scope.populateFromLicence = function () {
            if ($scope.client.licenceNo !== undefined && $scope.client.licenceNo.length === 16) {
               if ($scope.client.surname === undefined || $scope.client.surname.length === 0) {
                    $http.get(apiServer + '/Client/GetSurnameFromLicenceNumber/' + $scope.client.licenceNo)
                        .then(
                            function (response) {
                                $scope.client.surname = response.data;
                            },
                            function (response) {
                            }
                        );
                }
                if ($scope.client.firstName === undefined || $scope.client.firstName.length === 0) {
                    $scope.client.firstName = $scope.client.licenceNo.substr(11,1);
                }

                ClientService.returnBirthdateFromUkLicenceNumber($scope.client.licenceNo)
                .then(
                    function successCallback(response) {
                        $scope.client.birthdateFromUkLicenceNumber = $filter('date')(response.data, 'dd-MMM-yyyy');

                        if (!$scope.client.DateOfBirth === true) {
                            $scope.client.DateOfBirth = $scope.client.birthdateFromUkLicenceNumber;
                        }
                        $scope.checkDOBAgainstLicence();
                    },
                    function errorCallback(response) {
                        //TODO: do we care if the call fails
                    }
                );
            }
        }

        $scope.emailCourseReminderCheckbox = function () {
            if ($scope.client.email === $scope.client.confirmEmail && $scope.client.email !== undefined && $scope.client.email.length > 0) {
                $scope.client.EmailCourseReminders = true
            } else {
                $scope.client.EmailCourseReminders = false
            }
        }

        $scope.smsCourseReminderCheckbox = function () {
            if ($scope.client.phoneNumberType === "Mobile" && $scope.client.phoneNumber !== undefined && $scope.client.phoneNumber.length === 11) {
                $scope.client.SMSCourseReminders = true
            } else {
                $scope.client.SMSCourseReminders = false
            }
        }


        $scope.displayName = function (selectedTitle) {
            if (!$scope.displayNameChanged) {

                $scope.selectedTitle = selectedTitle;

                if ($scope.selectedTitle === undefined) {
                    $scope.selectedTitle = '';
                }
                if ($scope.client.firstName === undefined) {
                    $scope.client.firstName = '';
                }
                if ($scope.client.surname === undefined) {
                    $scope.client.surname = '';
                }

                if ($scope.selectedTitle === 'Other') {
                    if ($scope.client.otherTitle === undefined) {
                        $scope.client.otherTitle = '';
                    }
                    if ($scope.client.otherTitle !== '') {
                        $scope.client.displayName = $scope.client.otherTitle + " " + $scope.client.firstName + " " + $scope.client.surname;
                    } else {
                        $scope.client.displayName = $scope.client.firstName + " " + $scope.client.surname;
                    }
                }
                else {
                    if ($scope.selectedTitle !== '') {
                        $scope.client.displayName = $scope.selectedTitle + " " + $scope.client.firstName + " " + $scope.client.surname;
                    } else {
                        $scope.client.displayName = $scope.client.firstName + " " + $scope.client.surname;
                    }
                }
            }
        }


        $scope.addPhone = function () {
            if ($scope.client.phoneNumber !== undefined && $scope.client.phoneNumber !== '' && $scope.client.phoneNumberType !== undefined && $scope.client.phoneNumberType !== '') {
                var phoneNumber = new Object();
                phoneNumber.number = $scope.client.phoneNumber;
                phoneNumber.type = $scope.client.phoneNumberType;
                $scope.client.phoneNumbers.push(phoneNumber);
                $scope.client.phoneNumber = '';
                $scope.client.phoneNumberType = '';
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
        $scope.datepickerOptions = {
            datepickerMode: "'day'"
            , minMode: "'day'"
            , maxMode: "'year'"
            , minDate: "minDate"
            , showWeeks: "false"
            , startingDay: 0
            , formatDay: 'dd'
            , formatMonth: 'MMMM'
            , formatYear: 'yyyy'
        }

        $scope.datepickerFormat = "dd MMMM yyyy";

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


        /**
            * Get client genders
        */
        $scope.getGenders = function () {
            GenderService.get()
            .then(
                function (response) {
                    $scope.genders = response.data;
                },
                function (response) {
                }
            );
        }


        $scope.getClientConfigurationOptions = function () {
            OrganisationSelfConfigurationService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
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

        //if ($scope.client.phoneNumber != null && $scope.client.phoneNumber != "") {
        //    $scope.client.
        //}

        //$scope.selectedGenderId = $scope.client.GenderId;
        //$scope.client.Gender = $scope.findGenderName($scope.selectedGenderId);

        //Routing AC2017-07-12
        $scope.addClient = function () {

            var company = angular.element(document.querySelector('#company'));
            var address1 = angular.element(document.querySelector('#address1'));
            var address2 = angular.element(document.querySelector('#address2'));
            var town = angular.element(document.querySelector('#town'));
            //var county = angular.element(document.querySelector('#county'));

            // we are adding a new client so ensure the client Id is 0
            $scope.client.Id = 0;
            $scope.client.company = company[0].value;
            $scope.client.address1 = address1[0].value;
            $scope.client.address2 = address2[0].value;
            $scope.client.town = town[0].value;


            // if the title is other, set the title to the contents of the 'other' text
            if ($scope.selectedTitle === 'Other') {
                if (angular.isDefined($scope.client.otherTitle)) {
                    $scope.client.title = $scope.client.otherTitle;
                }
                else {
                    $scope.client.title = $scope.selectedTitle;
                }
            }
            else {
                $scope.client.title = $scope.selectedTitle;
            }

            //$scope.client.county = county[0].value;
            $scope.client.organisationId = activeUserProfile.selectedOrganisation.Id;

            // setting up parameters for adding a client to a course
            $scope.client.addedByUserId = activeUserProfile.UserId;
            if ($scope.addClientToCourseId) {
                $scope.client.addClientToCourseId = $scope.addClientToCourseId;
            }

            //allow for manually added clients not attached to any course
            if ($scope.course) {
                if ($scope.course.courseTypeId) {
                    $scope.client.courseTypeId = $scope.course.courseTypeId;
                }
            }

            $scope.validationMessage = "";
            validateForm();

            if ($scope.validationMessage === "") {


                $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

                $http.post(apiServer + '/client/ClientReturnData', $scope.client)
                .then(function (response, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    var data = response.data;
                    //console.log(data.Status.toLowerCase().indexOf("success"));
                    //console.log(data);
                    if (data.Status === "success") {

                        $scope.successMessage = "Client successfully added.";
                        $scope.clientAdded = true;
                        $scope.client.insertedClientId = data.ClientId;
                        /**
                         * Close the modal
                         * & pass the message back to the previous modal
                         */
                        if ($scope.$parent.closeTheActiveModal !== undefined) {
                            $scope.$parent.printSuccessMessage("Updated " + $scope.client.DisplayName + "'s Client details.");
                            $scope.successMessage = "Updated " + $scope.client.DisplayName + "'s Client details.";
                            $scope.$parent.cancelAddUser($scope.$parent.closeTheActiveModal);
                        }
                        else {

                            // Close Add Client Form
                            $('button.close').last().trigger('click');

                            // Open Client Details Form
                            $scope.clientId = $scope.client.insertedClientId;
                            ModalService.displayModal({
                                scope: $scope,
                                title: "Client Details",
                                closable: true,
                                filePath: "/app/components/client/cd_view.html",
                                controllerName: "clientDetailsCtrl",
                                cssClass: "clientDetailModal",
                                buttons: {
                                    label: 'Close',
                                    cssClass: 'closeModalButton',
                                    action: function (dialogItself) {
                                        dialogItself.close();
                                    }
                                }
                            });
                        }
                           
                        $scope.showSuccessFader = true;
                        $scope.feedbackSent = true;
                    }
                    else if (data.Status === "addedToCourse") {
                        $scope.successMessage = "Client successfully added to the course";
                        $scope.refreshClients($scope.addClientToCourseId)
                            .then(
                                function successCallback(response) {
                                    $('button.close').last().trigger('click');
                                }
                            );
                    }
                    else {
                        $scope.showSuccessFader = false;
                        $scope.validationMessage = "An error occurred please contact Atlas Support (AC2017-07-12).";
                        }
                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    if (!data === false) {
                        $scope.validationMessage = data.Status;
                    }
                    else {
                        $scope.validationMessage = "Unable to save please contact the administrator.";
                    }
                });
            } else {
                $scope.showSuccessFader = false;
            }
        }

        $scope.addNote = function (insertedClientId) {
            // open client details Modal
            $scope.clientId = $scope.client.insertedClientId;
            if ($scope.client.displayName === undefined || $scope.client.displayName.length === 0) {
                $scope.displayName();
            }
            ModalService.displayModal({
                scope: $scope,
                title: "Add Client Note",
                cssClass: "addClientNoteModal",
                filePath: "/app/components/client/addNote.html",
                controllerName: "addClientNoteCtrl"
            });
        }

        $scope.bookCourse = function () {

            $scope.clientId = $scope.client.insertedClientId;

            ModalService.displayModal({
                scope: $scope,
                title: "Available Courses - For Client",
                cssClass: "availableCoursesForClientModal",
                filePath: "/app/components/client/availableCourses.html",
                controllerName: "clientAvailableCoursesCtrl"
            });
        };

        $scope.editClient = function (insertedClientId) {

            $scope.clientId = $scope.client.insertedClientId;

            ModalService.displayModal({
                scope: $scope,
                title: "Client Details",
                filePath: "/app/components/client/edit.html",
                controllerName: "editClientCtrl"
            })

        };

        $scope.deleteClient = function () {

            $scope.clientId = $scope.client.insertedClientId;
            $scope.clientName = $scope.client.displayName;

            /**
             * Object to pass to the take payment screen
             */
            $scope.clientDeleteDetail = {
                clientName: $scope.clientName,
                clientId: $scope.clientId
            };

            ModalService.displayModal({
                scope: $scope,
                title: "Delete Client",
                cssClass: "clientDeleteConfirmationModal",
                filePath: "/app/components/client/deleteConfirmation.html",
                controllerName: "deleteClientConfirmationCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.takePayment = function () {

            $scope.clientId = $scope.client.insertedClientId;
            $scope.clientName = $scope.client.displayName;

            // find the most relevant course for this payment...
            // also ensure that the client hasn't been removed from the course and that there is an amount outstanding
            var courseName = "";
            var amountOutstanding = "";
            var courseId = "";
            $http.get(apiServer + '/Client/CourseInformation/' + $scope.clientId)
            .then(
                function (response) {
                    $scope.client.CourseInformation = response.data;

                    if (angular.isDefined($scope.client.CourseInformation)) {

                        courseName = $scope.client.CourseInformation.Reference;
                        amountOutstanding = $scope.client.CourseInformation.AmountOutstanding;
                        courseId = $scope.client.CourseInformation.Id;
                    };



                    //if ($scope.client && $scope.client.CourseInformation) {
                    //    var sortedCourses = ($scope.client.CourseInformation).sort(function (a, b) {
                    //        return a.CourseDate - b.CourseDate;
                    //    });
                    //    for (var i = 0; i < sortedCourses.length; i++) {
                    //        if (sortedCourses[i].AmountOutstanding != "0.00" && (sortedCourses[i].ClientRemoved == false)) {
                    //            courseName = sortedCourses[i].Reference;
                    //            amountOutstanding = sortedCourses[i].AmountOutstanding;
                    //            courseId = sortedCourses[i].Id;
                    //            break;
                    //        }
                    //    }
                    //}



                    /**
                     * This object orginiates from the 
                     * Controller: AcceptPaymentCardCtrl
                     * File: /app/components/payment/controllers/acceptCardPaymentController
                     * Line: 233 - (As of 04/05/16)
                     * Full properties that can be set are in the file as mentioned above
                     */
                    var courses = [{ CourseId: courseId }];

                    // Mile's code uses this 'isAssignedTo' param to determine what you are paying for...
                    var isAssignedTo = "client";
                    if (courseId !== "") {
                        isAssignedTo = "clientCourse";
                    }

                    /**
                     * Object to passs to the take payment screen
                     */
                    $scope.clientTakePaymentDetail = {
                        clientName: $scope.clientName,
                        courseName: courseName,
                        isAssignedTo: isAssignedTo,
                        clientId: $scope.clientId,
                        amount: amountOutstanding,
                        courses: courses
                    };

                    $scope.validationMessage = "";  // avoids it from being displayed in the subsequent modal on open

                    ModalService.displayModal({
                        scope: $scope,
                        title: "Take Card Payment",
                        cssClass: "acceptCardPaymentModal",
                        filePath: "/app/components/payment/acceptCard.html",
                        controllerName: "AcceptCardPaymentCtrl",
                        buttons: {
                            label: 'Close',
                            cssClass: 'closeModalButton',
                            action: function (dialogItself) {
                                dialogItself.close();
                            }
                        }

                    });
                },
                function (response) {
                    $scope.validationMessage = "An error occurred - please retry."
                }
            );



        };



        $scope.enterPayment = function () {

            $scope.clientId = $scope.client.insertedClientId;
            $scope.clientName = $scope.client.displayName;

            var courseName = "";
            var amountOutstanding = "";
            var courseId = "";

            $http.get(apiServer + '/Client/CourseInformation/' + $scope.clientId)
            .then(
                function (response) {
                    $scope.client.CourseInformation = response.data;

                    if ($scope.client.CourseInformation !== undefined) {
                        courseName = $scope.client.CourseInformation.CourseType;
                        amountOutstanding = $scope.client.CourseInformation.AmountOutstanding;
                        courseId = $scope.client.CourseInformation.Id;

                        $scope.successfulPayment = {
                            clientName: $scope.clientName,
                            courseName: courseName,
                            isAssignedTo: "clientCourse",
                            clientId: $scope.clientId,
                            amount: amountOutstanding,
                            courses: courses
                        };
                    }

                    ModalService.displayModal({
                        scope: $scope,
                        title: "Enter Payment Transaction",
                        cssClass: "recordPaymentModal",
                        filePath: "/app/components/payment/record.html",
                        controllerName: "RecordPaymentCtrl",
                        buttons: {
                            label: 'Close',
                            cssClass: 'closeModalButton',
                            action: function (dialogItself) {
                                dialogItself.close();
                            }
                        }
                    });
                },
                function (response) {
                    $scope.validationMessage = "An error occurred please try again.";
                }
            );

            /**
             * This object originates from the 
             * Controller: AcceptPaymentCardCtrl
             * File: /app/components/payment/controllers/acceptCardPaymentController
             * Line: 233 - (As of 04/05/16)
             * Full properties that can be set are in the file as mentioned above
             */
            var courses = [{ CourseId: courseId }];
        };

        $scope.cancelDeletion = function (clientId) {

            $scope.clientUndeleteDetail = {
                userId: activeUserProfile.UserId,
                id: clientId
            };

            ClientService.undeleteClient($scope.clientUndeleteDetail).then
           (
               function successFunction(response) {
                   if (response.data) {
                       if (response.data === "success") {
                           $scope.client.showDeletionRow = false;
                           $scope.successMessage = "Client no longer marked for deletion"
                       }
                       else {
                           //$scope.errorMessage = "Delete Failed";
                           //$scope.hideErrorMessage = false;
                       }
                   }
               }
               ,
               function failedFunction() {
                   //$scope.errorMessage = "Delete Failed";
                   //$scope.hideErrorMessage = false;
               }
            );
        }

        // validate licence is a UK licence
        $scope.isUKLicence = function (licence) {
            var regex = /[a-zA-Z0-9]{5}\d[0156]\d([0][1-9]|[12]\d|3[01])\d[a-zA-Z0-9]{3}[a-zA-Z]{2}/;
            return regex.test(licence);
        }

        function validateForm() {
            $scope.validationMessage = '';
            if ($scope.client.licenceNo === undefined) {
                if ($scope.client.UKLicence === true) {
                    if ($scope.client.licenceNo) {
                        if ($scope.client.licenceNo.length < 5) {
                            $scope.validationMessage = "Non-UK licences must have at least 5 characters.";
                        }
                    }
                    else {
                        $scope.validationMessage = "Please enter a licence number.";
                    }
                }
            }
            if ($scope.client.UKLicence === true && !$scope.isUKLicence($scope.client.licenceNo)) {
                $scope.validationMessage = "UK Licence number is not in the valid format.";
            }
            if ($scope.client.firstName === undefined || $scope.client.firstName === "") {
                $scope.validationMessage = "Please enter a First Name";
            }
            else if ($scope.client.surname === undefined || $scope.client.surname === "") {
                $scope.validationMessage = "Please enter a Surname";
            }
            else if ($scope.client.email !== $scope.client.confirmEmail) {
                $scope.validationMessage = "Your email addresses don't match";
            }
            else if ($scope.client.isMysteryShopper == true) {
                if ($scope.client.DORSExpiryDate === undefined) {
                    $scope.validationMessage = "Mystery Shopper: You must supply a DORS Expiry Date";
                }
                else if ($scope.client.DORSExpiryDate.length < 1) {
                        $scope.validationMessage = "Mystery Shopper: You must supply a DORS Expiry Date";
                }
                else if ($scope.client.DORSSchemeId === undefined) {
                    $scope.validationMessage = "Mystery Shopper: You must select a DORS Scheme";
                }
                else if ($scope.client.DORSSchemeId < 1) {
                    $scope.validationMessage = "Mystery Shopper: You must select a DORS Scheme";
                }
            }
            // if an Email Address is entered check that it is in the correct format (an Email Address is not mandatory).
            else if ($scope.client.email) {
                if ($scope.client.email.length > 0) {
                    if (!EmailService.validate($scope.client.email)) {
                        $scope.validationMessage = "Email address not in recognised format.";
                    }
                }
            }
            if ($scope.client.county) {        // @TODO: somehow client.county is the address this needs looking at
                if ($scope.client.county.length == 0) {
                    $scope.validationMessage = "Please enter an address.";
                }
            }
            else {
                $scope.validationMessage = "Please enter an address.";
            }
            if ($scope.validationMessage.length > 0) {
                $scope.validationMessage = $scope.validationMessage;
            }
        }


        // return the entry in the array based on the value, so we can bind the ddl to the selected array entry
        $scope.getPhoneNumberType = function (index) {
            return $scope.client.phoneNumbers[index].type;
        }

        /**
         * Get the search content from the Web API
         * @param {object} searchContent
         * @returns {object} Organisation Users
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

        $scope.selectedUser = function (user) {

            $scope.userService.isAssignedToClient(user.Id)
                .then(function (data) {
                    if (data === true) {
                        $scope.validationMessage = "This User is already bound to a Client's Details.";
                        $('#userText').val('');
                    }
                    else {
                        $scope.validationMessage = "";
                        $('#clientTitle').focus();

                        //Make the Display Name the same as the Login Id
                        $scope.client.displayName = user.LoginId;

                        //Filter out any titles and assign the first word as the first name and last as surname
                        var loginText = user.LoginId;
                        loginText = loginText.replace(/(Mr |Dr |Rev |Mrs |Ms |Miss )/gi, '');
                        var loginTextValues = loginText.split(" ");
                        $scope.client.firstName = loginTextValues[0];
                        $scope.client.surname = loginTextValues[loginTextValues.length - 1];
                        $scope.client.userId = user.Id;
                    }
                }, function() {
                });
        }

        /**
         * Get the address choices
         */
        $scope.getAddressChoices = function () {

            //GetAddressService.getAddress($scope.trainer.Address.Postcode)
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

                }, function(response) {
                    alert("There was an issue retrieving your address");
                });
        }

        /**
         * Merge the address to enter in to the text field
         */
        $scope.selectAddress = function (theSelectedAddress) {

            //if (theSelectedAddress) {
            //    $scope.trainer.Address.Address = GetAddressFactory.format(theSelectedAddress);
            //}
            if (theSelectedAddress) {
                $scope.client.county = GetAddressFactory.format(theSelectedAddress);
            }


            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];
        }

        $scope.getReferringAuthorities = function () {
            ReferringAuthorityService.getByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        if (response.data) {
                            $scope.referringAuthorities = response.data;
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.getDORSSchemes = function () {
            ClientService.getDORSSchemeList(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        if (response.data) {
                            $scope.DORSSchemes = response.data;
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.toggleDORSExpiryCalendar = function () {
            if ($scope.AllowManualEditingOfClientDORSData === true || $scope.client.isMysteryShopper === true) {
                $scope.displayDORSExpiryCalendar = !$scope.displayDORSExpiryCalendar;
            }
        }

        $scope.toggleDORSRefferalCalendar = function () {
            if ($scope.AllowManualEditingOfClientDORSData === true || $scope.client.isMysteryShopper === true) {
                $scope.displayDORSRefferalCalendar = !$scope.displayDORSRefferalCalendar;
            }
        }

        $scope.checkAllowManualEditingOfClientDORSData = function () {
            OrganisationSystemConfigurationService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        if (response.data) {
                            $scope.AllowManualEditingOfClientDORSData = response.data.AllowManualEditingOfClientDORSData;
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.CheckDORS = function () {
            $scope.checkingDORS = true;
            $scope.DORSCheckStatusMessage = "";
            if ($scope.client.licenceNo && $scope.client.licenceNo !== "") {

                DorsService.getClientStatuses($scope.client.licenceNo, activeUserProfile.selectedOrganisation.Id)
                    .then(
                        function successCallback(response) {
                            if (response.data) {
                                if (response.data.length === 0) {
                                    $scope.checkingDORS = false;
                                    $scope.DORSCheckStatusMessage = "Client Details Not Found in DORS. Ensure the Client Licence Number is valid";
                                }
                                else {
                                    $scope.checkingDORS = false;
                                    if (response.data.length > 1) {
                                        $scope.DORSCheckStatusMessage = "Multiple Booking Pending DORS Statuses found. Selected the one that is expiring soonest.";
                                    }
                                    var bookingPendingStatusArray = $filter('filter')(response.data, { AttendanceStatus: 'Booking Pending' });
                                    if (bookingPendingStatusArray.length > 0) {


                                        // sort the array
                                        bookingPendingStatusArray = bookingPendingStatusArray
                                                                        .sort(function (a, b) {
                                                                            var sortResult = 0;
                                                                            if (a.ExpiryDate >= b.ExpiryDate) {
                                                                                sortResult = 1;
                                                                            }
                                                                            else if (a.ExpiryDate < b.ExpiryDate) {
                                                                                sortResult = -1;
                                                                            }
                                                                            return sortResult;
                                                                        });
                                        var soonestExpiringBookingPending = bookingPendingStatusArray[0];
                                        // traverse the sorted array and find the status that is nearest to expiry and in the future
                                        // this may not be needed
                                        var today = new Date();
                                        for (var i = 0; i < bookingPendingStatusArray.length; i++) {
                                            if (bookingPendingStatusArray[i].ExpiryDate === null) {
                                                break;
                                            }
                                            var currentExpiryDate = DateFactory.parseDate(bookingPendingStatusArray[i].ExpiryDate);
                                            if (currentExpiryDate > today) {
                                                //found it
                                                soonestExpiringBookingPending = bookingPendingStatusArray[i];
                                                break;
                                            }
                                        }
                                        // now set the params in the form
                                        $scope.client.DORSAttendanceReference = soonestExpiringBookingPending.AttendanceId;
                                        $scope.client.DORSAttendanceStatus = soonestExpiringBookingPending.AttendanceStatus;
                                        $scope.client.DORSAttendanceStatusIdentifier = soonestExpiringBookingPending.AttendanceStatusId;
                                        var filteredDORSSchemeArray = $filter('filter')($scope.DORSSchemes, { DORSSchemeIdentifier: soonestExpiringBookingPending.SchemeId });
                                        if (filteredDORSSchemeArray) {
                                            if (filteredDORSSchemeArray.length > 0) {
                                                $scope.client.DORSSchemeId = filteredDORSSchemeArray[0].Id;
                                            }
                                        }

                                        // @TODO: 2 lines below: we don't get this info from the lookupstatus call... do we?
                                        // $scope.client.ReferringAuthorityId = ;
                                        // $scope.client.DORSRefferalDate = ;
                                        $scope.client.DORSExpiryDate = DateFactory.formatDateSlashes(DateFactory.parseDate(soonestExpiringBookingPending.ExpiryDate));
                                        $scope.client.DataValidatedAgainstDORS = true;
                                    }
                                    else {
                                        $scope.DORSCheckStatusMessage = "No Booking Pending Client Details Found in DORS.";
                                    }
                                }
                                var s = 1;
                            }
                        },
                        function errorCallback(response) {

                        }
                    );
            }
            else {
                $scope.checkingDORS = false;
                $scope.DORSCheckStatusMessage = "Please enter a licence number before performing a DORS check.";
            }
        }

        $scope.DORSEdited = function () {
            $scope.client.DataValidatedAgainstDORS = false;
        }

        // initialisations
        $scope.getClientConfigurationOptions();
        $scope.getClientTitles();
        $scope.getDriverLicenceTypes();
        $scope.getGenders();
        $scope.getReferringAuthorities();
        $scope.getDORSSchemes();
        $scope.checkAllowManualEditingOfClientDORSData();

        $scope.capitalizeFirstName = function (inputtedString) {
            if ($scope.capitalizeFirstNameFlag === true && !(inputtedString === undefined || inputtedString === null)) {
                $scope.client.firstName = StringService.Capitalize(inputtedString.trim());
                $scope.capitalizeFirstNameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        $scope.capitalizeSurname = function (inputtedString) {
            if ($scope.capitalizeSurnameFlag === true && !(inputtedString === undefined || inputtedString === null)) {
                $scope.client.surname = StringService.Capitalize(inputtedString.trim());
                $scope.capitalizeSurnameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        $scope.capitalizeOtherNames = function (inputtedString) {
            if ($scope.capitalizeOtherNameFlag === true && !(inputtedString === undefined || inputtedString === null)) {
                $scope.client.otherNames = StringService.Capitalize(inputtedString.trim());
                $scope.capitalizeOtherNameFlag = false;
                $scope.displayName($scope.selectedTitle);
            }
        }

        UserService.isMysteryShopperAdministrator(activeUserProfile.UserId)
        .then(
            function (data) {
                if (data === true) {
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

    }
})();