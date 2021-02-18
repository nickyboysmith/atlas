(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientCoursePaymentCtrl", ClientCoursePaymentCtrl);

    ClientCoursePaymentCtrl.$inject = ["$scope", "$window", "$sce", "ClientRegistrationService", "AcceptCardPaymentFactory", "AcceptCardPaymentService", "OrganisationContactService", "OrganisationSelfConfigurationService"];

    function ClientCoursePaymentCtrl($scope, $window, $sce, ClientRegistrationService, AcceptCardPaymentFactory, AcceptCardPaymentService, OrganisationContactService, OrganisationSelfConfigurationService) {


        /**
         *
         */
        $scope.showContinueButton = false;
        $scope.paymentComplete = false;

        var sessionData = sessionStorage.getItem("registrationDetails");

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
         * Create the system details
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
            CourseFee: ($scope.registrationDetails["BookingDetails"][0].CourseFee).toFixed(2),
            CourseTypeId: $scope.registrationDetails["BookingDetails"][0].Id,
            OrganisationId: $scope.registrationDetails["Login"][0]["OrganisationIds"].Id,
            StartDate:  $scope.registrationDetails["Course"].StartDate
        };


        /**
         * build client object details
         */
        $scope.client = {
            Id: $scope.registrationDetails["Login"][0]["ClientId"],
            UserId: $scope.registrationDetails["Login"][0]["UserId"],
            Name: $scope.registrationDetails["Login"][0]["FullName"],
            PostCode: $scope.registrationDetails["Login"][0]["PostCode"],
        };

        /**
         * build course object details
         */
        $scope.course = $scope.registrationDetails["Course"];


        /**
         * Go back to the main home page
         */
        $scope.restartProcess = function () {
            $window.location.href = "/";
            exit(); // Stops any execution of code whilst processing page load
        };


        /**
         * Object to passs to the take payment screen
         */
        $scope.clientTakePaymentDetail = {
            clientName: $scope.client.Name,
            courseName: $scope.confirmationDetails.DORSCourse,
            isAssignedTo: "client",
            clientId: $scope.client.Id,
            postCode: $scope.client.PostCode
        };

        /**
         * 3D Secure Auth
         */
        $scope.threeDSecure = {
            url: "",
            pareq: "",
            md: "",
            termUrl: "",
            orderReference: "",
            show3D: false
        };

        /**
         * Show the card details fields
         */
        $scope.showPaymentScreen = function () {
            $("#showPaymentInstructions").hide();
            $("#showPaymentScreen").show();
            $("#assignClientButton").remove();
            $("#savePaymentButton").remove();
            $("#paymentAmount").prop("disabled", "disabled");

            /**
             * Set the button to not disabled
             */
            $scope.showContinueButton = true;

            /**
             * Build the assigned client object
             */

            var assignCourses = [];
            assignCourses.push($scope.$$childHead.$parent.course);
    

            var assignedClient = {
                clientId: $scope.client.Id,
                clientName: $scope.confirmationDetails.DisplayName,
                courseName: $scope.confirmationDetails.DORSCourse,
                courses: assignCourses
            };

            /**
             * Add the amout 
             * To the view
             */
            $scope.$$childHead.paymentDetail.Amount = $scope.confirmationDetails.CourseFee;

            /**
             * Call the method to 
             * Update the values 
             */
            $scope.$$childHead.updateAssignedClient(assignedClient);

        };

        /**
         * 
         */
        $scope.buildPaymentObject = function () {

            var secret = AcceptCardPaymentFactory.getSecret($scope.client.UserId);
            var tokenisedDetails = AcceptCardPaymentFactory.hashCard($scope.$$childHead.paymentDetail.Card, secret.key);

            // Save card type to session storage
            $scope.registrationDetails["CardType"] = $scope.$$childHead.paymentDetail.Card.Type;
            sessionStorage.setItem("registrationDetails", JSON.stringify($scope.registrationDetails));
            $scope.$$childHead.paymentDetail.Address.PostCode = $scope.$$childHead.paymentDetail.Address.PostCode;

            /**
             * Create the base payment object
             * This is universally used for all types
             */
            var basePaymentObject = {
                cardSupplier: $scope.$$childHead.paymentDetail.CardSupplier,
                clientName: $scope.$$childHead.paymentDetail.client,
                isAssignedTo: $scope.$$childHead.paymentDetail.isAssignedTo,
                paymentDate: secret.creationDate,
                token: tokenisedDetails,
                amount: $scope.$$childHead.paymentDetail.Amount,
                address: JSON.stringify($scope.$$childHead.paymentDetail.Address),
                organisationId: $scope.confirmationDetails.OrganisationId,
                paymentName: $scope.$$childHead.paymentDetail.Card.HolderName
            };

            /**
             * If a client has been assigned
             */
            if (
               $scope.$$childHead.paymentDetail.isAssignedTo === "client" ||
               $scope.$$childHead.paymentDetail.isAssignedTo === "clientCourse") {
                basePaymentObject = angular.extend(basePaymentObject, {
                    clientId: $scope.$$childHead.paymentDetail.clientId
                });
            }

            /**
             * If a course has been assigned
             */
            if ($scope.$$childHead.paymentDetail.isAssignedTo === "clientCourse") {
                basePaymentObject = angular.extend(basePaymentObject, {
                    courses: $scope.$$childHead.paymentDetail.courses
                });
            }

            return basePaymentObject;

        };


        /**
         * Build the re auth thorization object
         * To send to the api
         */
        $scope.buildCompleteAuthPaymentObject = function (md, paRes, cardType, orderReference) {
            return {
                cardSupplier: "",
                clientName: $scope.confirmationDetails.DisplayName,
                isAssignedTo: "clientCourse",
                clientId: $scope.client.Id,
                userId: $scope.client.UserId,
                organisationId: $scope.confirmationDetails.OrganisationId,
                amount: $scope.confirmationDetails.CourseFee,
                courses: $scope.$$childHead.paymentDetail.courses,
                md: md,
                paRes: paRes,
                cardType: cardType,
                type: "online",
                orderReference: orderReference,
                paymentName: $scope.$$childHead.paymentDetail.Card.HolderName
            };
        };


        /**
         * 
         */
        $scope.completePayment = function () {

            $scope.validationMessage = '';
            $scope.organisationContacts = null;

            ValidateData($scope.$$childHead.paymentDetail.Card, $scope.$$childHead.paymentDetail.Address)

            if ($scope.validationMessage == '' && $scope.$$childHead.creditCardClass == true) {
                $("#cardDetailsContainer").hide();
                $("#showProcessingSpinner").show();


                ClientRegistrationService.processOnlinePayment($scope.buildPaymentObject())
                .then(
                    function successCallback(response) {
                        var paymentRequest = response.data;

                        $("#showProcessingSpinner").hide();

                        if (paymentRequest.Is3DSecureRequest === true) {

                            $scope.threeDSecure = {
                                url: paymentRequest.AcsUrl,
                                pareq: paymentRequest.PaReq,
                                md: paymentRequest.MD,
                                termUrl: paymentRequest.TermUrl,
                                orderReference: paymentRequest.OrderReference,
                                show3D: true
                            };

                            /**
                             * Save ThreeDSecure data to the window
                             */
                            $scope.registrationDetails["3D"] = $scope.threeDSecure;
                            sessionStorage.setItem("registrationDetails", JSON.stringify($scope.registrationDetails));

                        } else if (paymentRequest.Is3DSecureRequest === false) {
                            $scope.showCompletedPaymentMessage();
                        } else {
                            console.log("There has been an error, on a success response");
                        }

                    },
                    function errorCallback(response) {
                        $scope.getOrganisationContacts();
                        if (!response.data.ExceptionMessage == false) {
                            $scope.handleErrorMessage(response.data.ExceptionMessage);
                        } else {
                            if (!response.data == false) {
                                $scope.handleErrorMessage(response.data);
                            } else {
                                $scope.handleErrorMessage(response.statusText);
                            }
                        }
                    }
                );
            }

        };

        /**
         * Close the message 
         * Remove the sessionstorage data
         * ThenRedirect back to the start of the process
         */
        $scope.showCompletedPaymentMessage = function () {
            $("#showProcessingSpinner").hide();
            $("#showPaymentResponse").show();
            $("#show3DSecureIFrameContainer").hide();
            $scope.paymentComplete = true;

            /**
             * Remove session storage 
             */
            sessionStorage.removeItem("registrationDetails");
        };

        /**
         * Get organisation contacts 
         */
        $scope.getOrganisationContacts = function () {
            OrganisationContactService.getOrganisationContacts($scope.confirmationDetails.OrganisationId)
                .then(
                function (response) {
                    $scope.organisationContacts = response.data;
                }
                ,
                function (response) {
                }
            )
        }        

        /**
         * 
         */
        $scope.handleErrorMessage = function (errorMessage) {
            $("#showProcessingSpinner").hide();
            //$("#showPaymentResponse").show();
            $("#cardDetailsContainer").show();

            $scope.validationMessage = errorMessage;
        }

        /**
         * Go to the OrganisationSelfConfiguration table
         * To check whether for MinutesToHoldOnlineUnpaidCourseBookings
         */
        $scope.orgSystemConfig = new Object();
        OrganisationSelfConfigurationService.GetByOrganisation($scope.confirmationDetails.OrganisationId)
            .then(
                function successCallback(response) {
                    if (response.data !== null) {
                        $scope.orgSystemConfig.bookingHeldMinutes = response.data.MinutesToHoldOnlineUnpaidCourseBookings;
                    }
                    else {
                        $scope.orgSystemConfig.bookingHeldMinutes = 15;
                    }
                },
                function errorCallback(response) {
                    $scope.orgSystemConfig.bookingHeldMinutes = 15;
                }
            )


        function receiveMessage(event) {
            if (event.data == "removeTheiFrame") {

                $("#threeDSecureIFrame").remove();
                $("#showProcessingSpinner").show();

                /**
                 * Get the updated registration Details
                 */
                $scope.registrationDetails = JSON.parse(sessionStorage.getItem("registrationDetails"));

                var threeDResponse = $scope.registrationDetails["3DResponse"];
                var PaRes = threeDResponse.PaRes;
                var MD = threeDResponse.MD;
                var cardType = $scope.registrationDetails["CardType"];
                var orderReference = $scope.registrationDetails["3D"].orderReference;

                /**
                 * Build the payment object
                 */
                var reAuthObject = $scope.buildCompleteAuthPaymentObject(MD, PaRes, cardType, orderReference);

                /**
                 * Send the 3D Response Data 
                 * To the web api
                 */
                ClientRegistrationService.completeAuthorization(reAuthObject)
                .then(
                    function (response) {
                        console.log(response);
                        $scope.showCompletedPaymentMessage();
                    },
                    function (reason) {
                        console.log(reason);
                        $scope.handleErrorMessage(response.data);
                    }
                );
            }
        }
        window.addEventListener("message", receiveMessage, false);


        function ValidateData(cardDetails, addressDetails)
        {            
            if (!cardDetails == true)
            {
                concatenateValidationMessage("Please enter card details.");
            }
            else
            {
                if (!cardDetails.HolderName == true)
                {
                    concatenateValidationMessage( "Please enter a card holder name.");
                }

                if (!cardDetails.Number == true)
                {
                    concatenateValidationMessage("Please enter a card number.");
                }

                if (!cardDetails.Type == true)
                {
                    concatenateValidationMessage("Please enter a card type.");
                }

                if (!cardDetails.Expiry == true)
                {
                    concatenateValidationMessage("Please enter a card expiry date month and year.");
                }
                else
                {
                    if (!cardDetails.Expiry.Month == true)
                    {
                        concatenateValidationMessage("Please enter a card expiry month.");
                    }
                    else if (IsValidMonth(cardDetails.Expiry.Month) == false)
                    {
                        concatenateValidationMessage("Please enter a valid card expiry month.");
                    }

                    if (!cardDetails.Expiry.Year == true)
                    {
                        concatenateValidationMessage("Please enter a card expiry year.");
                    }
                    else if (IsValidYear(cardDetails.Expiry.Year) == false)
                    {
                        concatenateValidationMessage("Please enter a valid card expiry year.");
                    }
                }
                    
                if (!cardDetails.Start == false) {
                    if (!cardDetails.Start.Month == true) {
                        concatenateValidationMessage("Please enter a card start month.");
                    }
                    else if (IsValidMonth(cardDetails.Start.Month) == false) {
                        concatenateValidationMessage("Please enter a valid card start month.");
                    }

                    if (!cardDetails.Start.Year == true) {
                        concatenateValidationMessage("Please enter a card start year.");
                    }
                    else if (IsValidYear(cardDetails.Start.Year) == false) {
                        concatenateValidationMessage("Please enter a valid card start year.");
                    }
                }

                if (!cardDetails.IssueNumber == false && cardDetails.IssueNumber < 1)
                {
                    concatenateValidationMessage("Please enter a valid issue number.");
                }

                if (!cardDetails.CV2 == true )
                {
                    concatenateValidationMessage("Please enter a card CVV / CV2.");
                }
                else if (isNaN(cardDetails.CV2) == true || cardDetails.CV2 <= 0)
                {
                    concatenateValidationMessage("Please enter a valid card CVV / CV2.");
                }
            }
        }

        function concatenateValidationMessage(newMessage)
        {
            $scope.validationMessage += $scope.validationMessage != "" ? "\n" : "";
            $scope.validationMessage += newMessage;
        }

        //very basic but works - better than no client side validation which is what we had
        //TODO make start/expiry month drop downs
        function IsValidMonth(month)
        {
            var isValid = false;           

            if (isNaN(month) == false) {
                if (parseInt(month) > 0 && parseInt(month) < 13) {
                    isValid = true;
                }
            }
            return isValid;
        }

        //very basic but works - better than no client side validation which is what we had
        //TODO make start/expiry month drop downs
        function IsValidYear(year) {
            var isValid = false;

            if (isNaN(year) == false) {
                if (parseInt(year) > 1900 && parseInt(year) < 2100) {
                    isValid = true;
                }
            }
            return isValid;
        }


    }



})();