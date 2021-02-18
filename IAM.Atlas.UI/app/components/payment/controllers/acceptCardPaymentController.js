(function () {

    'use strict';

    angular
        .module("app")
        .controller("AcceptCardPaymentCtrl", AcceptCardPaymentCtrl);

    AcceptCardPaymentCtrl.$inject = ["$scope", "activeUserProfile", "ClientRegistrationService", "AcceptCardPaymentFactory", "ModalService", "AcceptCardPaymentService", "QuickSearchService", "OrganisationSystemConfigurationService"];

    function AcceptCardPaymentCtrl($scope, activeUserProfile, ClientRegistrationService, AcceptCardPaymentFactory, ModalService, AcceptCardPaymentService, QuickSearchService, OrganisationSystemConfigurationService) {

        $scope.paymentSuccessful = false;

        /**
         * Instantiate payment detail object
         */
        $scope.paymentDetail = {
            isAssignedTo: "empty",
            Address: {},
            CardSupplier: ""
        };

        AcceptCardPaymentService.getPaymentCardTypes()
        .then(
            function (data) {
                $scope.cardTypes = data;
            },
            function (data) {
                console.log(data);
            }
        );

        $scope.CardTypeWhilieShowHide = 'Hide';

        AcceptCardPaymentService.getPaymentCardValidationTypes()
        .then(
            function (data) {
                $scope.cardValidationTypes = data;
            },
            function (data) {
                console.log(data);
                }
        );

        /**
         * 
         */
        if ($.isEmptyObject(activeUserProfile)) {
            var theOrganisationId = $scope.$parent.confirmationDetails.OrganisationId;
        } else {
            var theOrganisationId = activeUserProfile.selectedOrganisation.Id;
        }

        
        /**
         * Get the payment provider name
         * & If exists add to the DOM
         */
        ClientRegistrationService.getPaymentProvider(theOrganisationId)
        .then(
            function (response) {
                var paymentName = response.data[0].Name;
                var classToAdd = paymentName.replace(/ +/g, "");
                var check = setInterval(function () {
                    var element = document.getElementById('paymentProvider');
                    if (element !== null) {
                        var buildImgString = "/app_assets/images/payment-icons/providers/" + classToAdd + ".png";
                        var img = "<img class='provider' src='" + buildImgString + "'>";
                        $("#paymentProvider").show();
                        $("#organisation").html(img);
                        clearInterval(check);
                    }
                }, 500);
            },
            function (response) {
                console.log(response);
            }
        );



        /**
         * Get ShowPaymentCardSupplier
         */
        OrganisationSystemConfigurationService.getByOrganisationForClientRegistration(theOrganisationId)
            .then(
                function (data) {
                    if (data) {
                        $scope.showPaymentCardSupplier = data.ShowPaymentCardSupplier;
                    }
                },
                function (data) {
                    $scope.showPaymentCardSupplier = true;
                }
            );

         /**
         * if the property exists on the parent
         * add the details to the modal
         */
        if ($scope.$parent.clientTakePaymentDetail !== undefined) {

            var takePaymentDetail = $scope.$parent.clientTakePaymentDetail;

            $scope.paymentDetail.isAssignedTo = takePaymentDetail.isAssignedTo;
            $scope.paymentDetail.client = takePaymentDetail.clientName;
            $scope.paymentDetail.from = takePaymentDetail.clientName;
            $scope.paymentDetail["clientId"] = takePaymentDetail.clientId;
            $scope.paymentDetail.course = takePaymentDetail.courseName;
            $scope.paymentDetail.courses = takePaymentDetail.courses;
            $scope.paymentDetail.Amount = takePaymentDetail.amount;

            /**
             * If the card is undefined
             * Then create a new card object then add the property
             * To the object
             */
            if ($scope.paymentDetail["Card"] === undefined) {
                $scope.paymentDetail["Card"] = {};
                //$scope.paymentDetail["Card"]["HolderName"] = takePaymentDetail.clientName;
            }
            
        };


        /**
         * Assign a client
         * To the current payment about to be recorded
         */
        $scope.assignClient = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Assign Client",
                cssClass: "recordPaymentAssignClientModal",
                filePath: "/app/components/client/findSingle.html",
                controllerName: "FindSingleClientCtrl",
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
         * Update the payment 
         * With the client object
         * 
         * Check to see where we should assign the client to [client/course]
         */
        $scope.updateAssignedClient = function (assignedClient) {

            /**
             * Check where we should assign user to
             */
            if (assignedClient.courses.length === 0) {
                $scope.paymentDetail.isAssignedTo = "client";
            } else {
                $scope.paymentDetail.isAssignedTo = "clientCourse";
            }

            /**
             * add the names to the paymentDetail object
             */

            if ($scope.paymentDetail.Card == undefined) {
                $scope.paymentDetail.Card = new Object();
            }

            $scope.paymentDetail.client = assignedClient.clientName;
            //$scope.paymentDetail.Card.HolderName = assignedClient.clientName;
            //$scope.paymentDetail.from = assignedClient.clientName;
            $scope.paymentDetail.course = assignedClient.courseName;
            $scope.paymentDetail.clientId = assignedClient.clientId;

            if ($scope.paymentDetail.Address == undefined || $scope.paymentDetail.Address.PostCode == undefined || $scope.paymentDetail.Address.PostCode == "") {
                $scope.paymentDetail.Address.PostCode = assignedClient.postCode;
            }

            /**
            * Add new properties to the paymentDetail object
            */
            $scope.paymentDetail["clientId"] = assignedClient.clientId;
            $scope.paymentDetail["courses"] = assignedClient.courses;

        };
        
        /**
         * 
         */
        $scope.buildPaymentObject = function () {

            var secret = AcceptCardPaymentFactory.getSecret(activeUserProfile.UserId);
            var tokenisedDetails = AcceptCardPaymentFactory.hashCard($scope.paymentDetail.Card, secret.key);

            $scope.paymentDetail.Address.PostCode = $scope.paymentDetail.Address.PostCode;

            /**
             * Create the base payment object
             * This is universally used for all types
             */
            var basePaymentObject = {
                cardSupplier: $scope.paymentDetail.CardSupplier,
                clientName: $scope.paymentDetail.client,
                isAssignedTo: $scope.paymentDetail.isAssignedTo,
                paymentDate: secret.creationDate,
                token: tokenisedDetails,
                amount: $scope.paymentDetail.Amount,
                address: JSON.stringify($scope.paymentDetail.Address),
                organisationId: activeUserProfile.selectedOrganisation.Id,
                courses: $scope.paymentDetail.courses
            };

            /**
             * If a client has been assigned
             */
            if (
                $scope.paymentDetail.isAssignedTo === "client" ||
                $scope.paymentDetail.isAssignedTo === "clientCourse") {
                basePaymentObject = angular.extend(basePaymentObject, {
                    clientId: $scope.paymentDetail.clientId
                });
            }

            /**
             * If a course has been assigned
             */
            if ($scope.paymentDetail.isAssignedTo === "clientCourse") {
                basePaymentObject = angular.extend(basePaymentObject, {
                    courses: $scope.paymentDetail.courses
                });
            }

            return basePaymentObject;

        };

        /**
         * Call the web api to get results based on the search content
         */
        $scope.getSearchableItems = function (searchContent) {
            /**
             * Set the search content
             * To a property on the scope
             */
            $scope.searchContent = searchContent;

            /**
             * Return the related content
             */
            return AcceptCardPaymentService.getCardSuppliers($scope.searchContent);
        }

        /**
         * When the user selects a card supplier 
         * From the list
         */
        $scope.selectedItem = function (card) {
            $scope.paymentDetail.CardSupplier = card.Name;
        };

        /**
         * Validate Credit card type
         */
        //$scope.validateCreditCardNumber = function () {
        //    $("#ccNumber").validateCreditCard(function (result) {
        //        var cards = {
        //            amex: "AMEX",
        //            discover: "DISCOVER",
        //            diners_club_carte_blanche: "DINERS",
        //            diners_club_international: "DINERS",
        //            jcb: "JCB",
        //            laser: "",
        //            maestro: "MAESTRO",
        //            mastercard: "MASTERCARD",
        //            visa: "VISA",
        //            electron: "ELECTRON",
        //        };            
        //        if (
        //            result.valid === true &&
        //            result.luhn_valid === true &&
        //            result.length_valid === true
        //            ) 
        //        {
        //            $scope.creditCardClass = true;
        //            $scope.paymentDetail.Card.Type = cards[result.card_type.name];
        //            $scope.creditCardValidMessage = "Card Type: " + result.card_type.displayname;
        //        } else {
        //            $scope.creditCardClass = false;
        //            $scope.creditCardValidMessage = "Unrecognised Card. Please Check the Card Number Entered.";
        //        }
        //    });
        //};

        $scope.validateCreditCardNumber = function () {
            if ($scope.paymentDetail != null || $scope.paymentDetail != undefined) {
                if ($scope.paymentDetail.Card != null || $scope.paymentDetail.Card != undefined) {
                    var creditCardNumber = $scope.paymentDetail.Card.Number;
                    $scope.creditCardValidMessage = '';
                    $scope.creditCardValidationTypeName = 'OTHER';
                    $scope.CardTypeWhilieShowHide = 'Hide';
                    if (creditCardNumber != null || creditCardNumber != undefined) {
                        $scope.CardTypeWhilieShowHide = 'Show';
                        $scope.creditCardClass = false;
                        $scope.cardValidationTypes.forEach(function (validationType) {
                            if (
                                creditCardNumber.indexOf(validationType.IssuerIdentificationCharacters, 0) == 0
                                && creditCardNumber.length == validationType.ValidLength
                                ) {
                                $scope.creditCardValidationTypeName = validationType.Name;
                                $scope.creditCardValidationTypeId = validationType.Id;
                                $scope.creditCardValidMessage = 'Card Type: ' + validationType.Name;
                                $scope.creditCardClass = true;
                            }
                        });
                        $scope.CardTypeWhilieShowHide = 'Hide';
                    }
                }
            }
        };

        $scope.validateCreditCardStartDate = function () {
            var monthValidate = "^(0?[1-9]|1[012])$";
            var yearValidate = "/^(19[5-9]d|20[0-4]d|2050)$/";
            var currentDate = new Date();
            var currentYear = currentDate.getFullYear();
            var currentMonth = currentDate.getMonth();
            $scope.StartDateMessage = '';
            
            if ($scope.paymentDetail != undefined && $scope.paymentDetail != null) {
                if ($scope.paymentDetail.Card != undefined && $scope.paymentDetail.Card != null) {
                    if ($scope.paymentDetail.Card.Start != null && $scope.paymentDetail.Card.Start != undefined) {
                        var startMonth = $scope.paymentDetail.Card.Start.Month;
                        var startYear = $scope.paymentDetail.Card.Start.Year;
                        if (startMonth != null && startMonth != undefined) {
                            if (!startMonth.match(monthValidate)) {
                                $scope.StartDateMessage = '*Please, Enter Months in between 1 to 12*... *INVALID*';
                            }
                        }

                        if (startYear != null && startYear != undefined) {
                            if (startYear > currentYear) {
                                $scope.StartDateMessage = '*Your Start Year is Set in the Future*... *INVALID*';
                            }
                        }
                        if (startMonth != null && startMonth != undefined && startYear != null && startYear != undefined) {
                            if (startYear == currentYear && startMonth > currentMonth) {
                                $scope.StartDateMessage = '*Your Start Month/Year is Set in the Future*... *INVALID*';
                            }
                        }
                    }
                }
            }
        };

        $scope.validateCreditCardExpiryDate = function () {
            var monthValidate = "^(0?[1-9]|1[012])$";
            var yearValidate = "/^(19[5-9]d|20[0-4]d|2050)$/";
            var currentDate = new Date();
            var currentYear = currentDate.getFullYear();
            var currentMonth = currentDate.getMonth() + 1;
            $scope.ExpiryDateMessage = '';

            if ($scope.paymentDetail != undefined && $scope.paymentDetail != null) {
                if ($scope.paymentDetail.Card != undefined && $scope.paymentDetail.Card != null) {
                    if ($scope.paymentDetail.Card.Expiry != null && $scope.paymentDetail.Card.Expiry != undefined) {
                        var startMonth = $scope.paymentDetail.Card.Expiry.Month;
                        var startYear = $scope.paymentDetail.Card.Expiry.Year;
                        if (startMonth != null && startMonth != undefined) {
                            if (!startMonth.match(monthValidate)) {
                                $scope.ExpiryDateMessage = '*Please, Enter Months in between 1 to 12*... *INVALID*';
                            }
                        }

                        if (startYear != null && startYear != undefined) {
                            if (Number(startYear) < currentYear) {
                                $scope.ExpiryDateMessage = '*Your Expiry Year is Set in the Past*... *INVALID*';
                            }
                        }
                        if (startMonth != null && startMonth != undefined && startYear != null && startYear != undefined) {
                            if (Number(startYear) == currentYear && Number(startMonth) < currentMonth) {
                                $scope.ExpiryDateMessage = '*Your Expiry Month/Year is Set in the Past*... *INVALID*';
                            }
                        }
                    }
                }
            }
        };

        $scope.validateCreditCardCVNumber = function () {
            var validateCV = "^[0-9]{3,4}$";
            $scope.CreditCardCVMessage = '';

            if ($scope.paymentDetail != undefined && $scope.paymentDetail != null) {
                if ($scope.paymentDetail.Card != undefined && $scope.paymentDetail.Card != null) {
                    if ($scope.paymentDetail.Card.CV2 != null && $scope.paymentDetail.Card.CV2 != undefined) {
                        var cvNumber = $scope.paymentDetail.Card.CV2;
                        if(!cvNumber.match(validateCV)) {
                            $scope.CreditCardCVMessage = '*Invalid CV Number Entered.*... *INVALID*';
                        }
                    }
                }
            }
        };

        $scope.validateCreditCardAmount = function () {
            $scope.CreditCardAmountMessage = '';

            if ($scope.paymentDetail != undefined && $scope.paymentDetail != null) {
                if ($scope.paymentDetail.Amount != undefined && $scope.paymentDetail.Amount != null) {
                    var ccAmount = $scope.paymentDetail.Amount;
                    if (isNaN(ccAmount) || Number(ccAmount) <= 0) {
                        $scope.CreditCardAmountMessage = '*Invalid Amount Entered.*... *INVALID*';
                    }
                }
            }
        };

            /**
             * Process Payment
             */
        $scope.processPayment = function () {

            $("#cardDetailsContainer").hide();
            $("#showProcessingSpinner").show();
            $scope.validationMessage = '';
            $scope.actualResponse = '';

            /**
             * 
             */
            AcceptCardPaymentService.processTelephonePayment($scope.buildPaymentObject())
            .then(
                function (data) {
                    var successResponse = data;
                    if (successResponse.PaymentId) {
                        // refresh client details if exists...
                        if ($scope.loadClientDetails && $scope.clientId) {
                            $scope.loadClientDetails($scope.clientId);
                        }
                        $("#showProcessingSpinner").hide();
                        $scope.validationMessage == '';
                        $scope.paymentSuccessful = true;
                    }
                    else
                    {
                        $("#cardDetailsContainer").show();
                        $("#showProcessingSpinner").hide();
                        if (typeof successResponse === 'string' || successResponse instanceof String) {
                            $scope.actualResponse = successResponse;
                            $scope.validationMessage = successResponse;
                        } else {
                            $scope.validationMessage = "An error occurred. Please contact support.";
                        }
                    }
             },
                function (data) {
                    $("#cardDetailsContainer").show();
                    $("#showProcessingSpinner").hide();
                    if (data) {
                        if (!data.ExceptionMessage == false) {
                            $scope.validationMessage = data.ExceptionMessage;
                        } else {
                            $scope.validationMessage = data;
                    }
                }
        }
            );
        };
    }

})();