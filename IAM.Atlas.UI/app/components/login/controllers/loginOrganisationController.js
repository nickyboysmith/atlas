(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('LoginOrganisationCtrl', LoginOrganisationCtrl);


    LoginOrganisationCtrl.$inject = ['$scope', "$window", "$location", "AuthenticationService", "AuthenticationFactory", "AtlasCookieFactory", "ModalService", "organisationRoute", "systemStatus"];

    function LoginOrganisationCtrl($scope, $window, $location, AuthenticationService, AuthenticationFactory, AtlasCookieFactory, ModalService, organisationRoute, systemStatus) {
        $scope.errorMessage = '';
        $scope.cookiesAllowed = false;
        $scope.privacyNotice = false;
        $scope.licenceNumberValid = true;
        $scope.organisationDisplayName = "";
        $scope.organisationId = 0;
        $scope.clientApplicationDescription = "Driver / Rider Improvement Schemes"; //Default Application Description
        $scope.clientWelcomeMessage = "Welcome to the On Road Course Booking";      //Default Welcome Message
        $scope.licence = {};
        $scope.licence.licenceNumber = "";
        $scope.bookingAttempt = {};

        $scope.systemStatus = {};

        $scope.systemStatus = systemStatus.data[0];

        $scope.linkEnabled = !$scope.systemStatus.OnlineBookingBlocked;
        
        /**
         * Set the Title
         */
        $scope.$root.title = 'Atlas | Sign In';

        /**
         * Create the empty login object
         */
        $scope.login = {};

        /**
         * Create the user details object
         */
        $scope.user = {};

        /**
         * Fill username if exists
         */
        $scope.username = AtlasCookieFactory.getCookie("username");
        if ($scope.username) {
            $scope.login.user = $scope.username;
        }

        /**
        * Get the privacynotice flag
        */
        $scope.privacyNotice = AtlasCookieFactory.getCookie("privacynotice");

        /**
        * Open PrivacyNotice.pdf in new browser window
        */
        $scope.openPrivacyNoticePdf = function () {
            
            if ($scope.linkEnabled === true) {
                window.open("/app/documents/general/PrivacyNotice.pdf");
            }
            
        }


        $scope.loginEnabled = function () {

            if ($scope.cookiesAllowed && $scope.privacyNotice) {
                return false;
            }
            else { return true; }


        }

        /*
         * Handle cookie acceptance
         */

        $scope.cookiesEnabled = function () {

            $scope.cookiesAllowed = $scope.booleanConvert(AtlasCookieFactory.getCookie("acceptCookies"));
            return $scope.cookiesAllowed;
        }

        $scope.storeCookiePreference = function () {
            var newValue = $scope.cookiesAllowed;
            AtlasCookieFactory.createCookie("acceptCookies", newValue, { expires: 30 });
        }

        $scope.privacyNotice = function () {
            $scope.privacyNotice = $scope.booleanConvert(AtlasCookieFactory.getCookie("privacynotice"));
            return $scope.privacyNotice;
        }

        $scope.storePrivacyAcceptance = function () {
            var newValue = $scope.privacyNotice;
            AtlasCookieFactory.createCookie("privacynotice", newValue, { expires: 30 });
        }

        $scope.booleanConvert = function (bool) {
            if (bool === "true") {
                return true;
            }
            else {
                return false;
            }
        }

        


        /**
         * Log in the user based upon the response
         */
        $scope.logUserIn = function () {

            $scope.path = AuthenticationFactory.getLocation($location);

            if ($scope.path === "/trainer") {
                $scope.login.path = "trainer";
            } else if ($scope.path === "/admin") {
                $scope.login.path = "organisation";
            } else if ($scope.path === "" || $scope.path === "/") {
                $scope.login.path = "client";
            }


            /**
             * 
             */
            AuthenticationService.loginOrganisationUser($scope.login)
                .then(function successCallback(response) {

                    /**
                     * If the object is empty
                     * That means that there has been an error
                     */
                    if (response.data.length === undefined) {
                        //$scope.systemStatus = "down";
                        $scope.systemStatus.SystemColour = "red";
                        $scope.systemStatus.SystemStatusMessage = "Invalid username or password";
                    }

                    /**
                     * If the object isn't empty
                     * That means that the user details have been authenticated
                     */
                    if (response.data.length) {

                        //In case the account is locked
                        if (response.data.indexOf("accountlocked") !== -1) {
                            //$scope.systemStatus = "down";
                            $scope.systemStatus.SystemColour = "red";
                            $scope.systemStatus.SystemStatusMessage = "There is an issue with your account. Please contact an Administrator";
                            return;
                        }

                        $scope.response = angular.copy(response.data);
                        $scope.authToken = response.headers("X-Auth-Token");


                        /**
                         * Check the org id object here
                         */
                        if ($scope.response[0]["OrganisationIds"].length === undefined) {
                            $scope.response[0]["OrganisationIds"] = [
                                {
                                    Id: $scope.response[0]["OrganisationIds"]["Id"],
                                    Name: $scope.response[0]["OrganisationIds"]["Name"]
                                }
                            ];

                            if ($scope.login.path === "client") {

                                angular.extend($scope.response[0]["OrganisationIds"], {
                                    "AppName": response.data[0]["OrganisationIds"].AppName 
                                });
                            }
                        }

                        /**
                         * If only one organisation by pass modal
                         */
                        if ($scope.response[0]["OrganisationIds"].length === 1) {
                            $scope.selectedOrganisation = $scope.response[0]["OrganisationIds"][0];
                            $scope.processLogin();
                        }

                        /**
                         * If more than one org 
                         * Show modal allow user to choose organisation
                         */
                        if ($scope.response[0]["OrganisationIds"].length !== 1) {
                            ModalService.displayModal({
                                scope: $scope,
                                title: "Choose your organisation",
                                cssClass: "chooseOrganisationModal",
                                filePath: "/app/components/login/chooseOrganisation.html",
                                controllerName: "ChooseOrganisationCtrl"
                            });
                        }
                    }
                }, function errorCallback(response) {
                    //$scope.systemStatus = "down";
                    $scope.systemStatus.SystemColour = "red";
                    $scope.systemStatus.SystemStatusMessage = "Invalid username or password";
                });
            //.error(function (response) {
            //    //$scope.systemStatus = "down";
            //    $scope.systemStatus.SystemColour = "red";
            //    $scope.systemStatus.SystemStatusMessage = "Invalid username or password";
            //});

        };

        $scope.enterSubmitForm = function (keyEvent) {
            if (keyEvent.which === 13) {
                $scope.logUserIn();
            }
        }

        $scope.showPasswordRequestModal = function () {

            if ($scope.linkEnabled === true) {

                ModalService.displayModal({
                    scope: $scope,
                    title: "Password Reset Request",
                    cssClass: "passwordResetModal",
                    filePath: "/app/components/changepassword/request.html",
                    controllerName: "ChangePasswordRequestCtrl"
                });
            }
        }

        $scope.showCookiePolicy = function () {

            if ($scope.linkEnabled === true) {
                
                ModalService.displayModal({
                    scope: $scope,
                    title: "Atlas Cookie Policy",
                    cssClass: "cookiePolicyModal",
                    filePath: "/app/components/login/cookiePolicy.html",
                    controllerName: "ShowCookieCtrl"
                });

            }
        }

        $scope.processLogin = function () {


            /**
             * Set User Cookie
             */
            AtlasCookieFactory.createCookie(
                "userSession",
                $scope.response[0]["cookie"],
                {
                    path: $scope.path
                });

            /**
             * Set Username Cookie
             */
            if ($scope.rememberMe) {
                AtlasCookieFactory.createCookie(
                    "username",
                    $scope.login.user,
                    {
                        path: $scope.path,
                        expires: 30
                    });
            }

            /**
             * Set PrivacyNotice Cookie
             */
            if ($scope.privacyNotice) {
                AtlasCookieFactory.createCookie(
                    "privacynotice",
                    $scope.response[0]["PrivacyNotice"],
                    {
                        path: $scope.path
                        //expires: 30
                    });
            }

            /**
             * Add the user details
             * to the scope
             */
            $scope.user.details = $scope.response[0];
            $scope.user.details["selectedOrganisation"] = $scope.selectedOrganisation;
            console.log($scope.user.details);

            delete $scope.user.details.cookie;

            /**
             * Set the details on the window
             */
            sessionStorage.setItem("userDetails", JSON.stringify($scope.user.details));

            /**
             * Set the token on the window
             */
            sessionStorage.setItem("authToken", $scope.authToken);

            /**
             * If the path is empty 
             * Then set to redirect to the home login
             */
            if ($scope.path === "") {
                $scope.path = "/";
            }

            /**
             * Send to the admin page
             */
            $window.location.href = $scope.path;
        }

        /*
         *Check the format of the user's licence, if correct, proceed to check, otherwise display error
         */
        $scope.checkLicence = function () {
            $scope.licenceNumberValid = true;
            if ($scope.licenceUKFormatCorrect($scope.licence.licenceNumber) || $scope.licenceNonUKFormatCorrect($scope.licence.licenceNumber)) {
                $scope.recordBookingAttempt($scope.licence.licenceNumber);
                $scope.checkResult = "";
                $scope.licence.organisationId = $scope.organisationId;
                AuthenticationService.checkUserLicence($scope.licence)
                .then(
                    function (response) {
                        $scope.result = response.data;
                        //Verify that the result exists
                        if ($scope.result) {
                            //...and that checkResult exists
                            if ($scope.result.checkResult !== null) {
                                switch ($scope.result.checkResult) {
                                    case 0: // Open the relevant course options modal, 
                                        //Check sessionStorage is available and that EligibleCoures is available
                                        if ($scope.sessionStorageAvailable() && $scope.result.EligibleCourseSchemes) {
                                            sessionStorage.organisationName = $scope.organisationDisplayName;
                                            sessionStorage.systemName = $scope.clientApplicationDescription;
                                            sessionStorage.licenceNumber = $scope.licence.licenceNumber;
                                            sessionStorage.ukLicence = $scope.licenceUKFormatCorrect($scope.licence.licenceNumber);
                                            if ($scope.result.EligibleCourseSchemes.length === 1) {
                                                sessionStorage.courseOptions = JSON.stringify($scope.result.EligibleCourseSchemes[0]);
                                                $scope.showSingleCourseOption();
                                            }
                                            else {
                                                sessionStorage.courseOptions = JSON.stringify($scope.result.EligibleCourseSchemes);
                                                $scope.showMultipleCourseOptions();
                                            }
                                        } else {
                                            $scope.errorMessage = 'Please use a browser that supports local storage (cookies) before proceeding'
                                        }
                                        break;
                                    case 1: // The user is not on DORS: But they are on the system: invite them to log in
                                        $scope.showLoginInvitation();
                                        break;
                                    case 2: // The user is not on DORS and has never been in the system: show them the contacts page
                                        sessionStorage.organisationId = $scope.organisationId;
                                        $window.location.href = "/login/organisationcontacts";
                                        break;
                                    default:
                                }
                            } else {
                                $scope.errorMessage = 'An error occurred whilst checking your licence number, please inform your provider'
                            }
                        } else {
                            $scope.errorMessage = 'An error occurred whilst checking your licence number, please inform your provider'
                        }
                    }
                    ,
                    function (response) {
                        // BEGIN TODO 
                        //Log and Persist the Data Error Message.
                        //if(response.data.ExceptionMessage){
                        //    $scope.errorMessage = response.data.ExceptionMessage;
                        //}
                        //else {
                        //    $scope.errorMessage = response.data.Message;
                        //}
                        // END TODO
                        $scope.errorMessage = 'The System is currently busy. Please retry again in a few minutes.';
                    }
                )
            }
            else {
                //The licence number is does not have a valid format
                $scope.licenceNumberValid = false;
            }
        };

        $scope.sessionStorageAvailable = function () {
            var test = 'test';
            try {
                sessionStorage.setItem(test, test);
                sessionStorage.removeItem(test);
                return true;
            } catch (e) {
                return false;
            }
        }

        $scope.licenceNonUKFormatCorrect = function (licenceNumber) {
            //for non-UK licence numbers, minimum 5 characters long
            try {
                return licenceNumber.length > 4;                
            }
            catch (err) {
                return false;
            }
        }

        $scope.licenceUKFormatCorrect = function (licenceNumber) {
            try {
                var LicenceNumber = licenceNumber.replace(/ /g, "").toUpperCase();
                var r = new RegExp("^[A-Z][A-Z0-9]{4}" +
                                "[0-9]{6}" +
                                "[A-Z0-9]{5}$");
                if (r.test(LicenceNumber)) {
                    var monthDigit1 =
                        (LicenceNumber.charAt(6) === "5") ? "0" :
                            (LicenceNumber.charAt(6) === "6") ? "1" : LicenceNumber.charAt(6);
                    var dateString = "20" + LicenceNumber.charAt(10) + LicenceNumber.charAt(5) +
                        "/" +
                        monthDigit1 + LicenceNumber.charAt(7) +
                        "/" +
                        LicenceNumber.charAt(8) + LicenceNumber.charAt(9);

                    if (isNaN(Date.parse(dateString))) {
                        return false;
                    }
                    var licenceValidity = (Date.parse(dateString) > 0);

                    if (licenceValidity === true) {
                        return true;
                    }
                } else {
                    return false;
                }
            }
            catch (err) {
                return false;
            }
        }

        $scope.showLicenceGuide = function () {

            if ($scope.linkEnabled === true) {
                $window.open('/app/documents/general/WhereToFindYourLicenceNumber.pdf', 'How to Find My Licence Number', 'width=700,height=400');
            }
        };

        $scope.showPrivacyNotice = function () {
            $window.open('/app/documents/general/PrivacyNotice.pdf', 'Privacy Notice', 'width=700,height=400');
        };

        $scope.showSingleCourseOption = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Booking",
                cssClass: "viewSingleCourseOptionModal",
                filePath: "/app/components/login/viewSingleCourseOption.html",
                controllerName: "ViewCourseOptionsCtrl"
            });
        };

        $scope.showMultipleCourseOptions = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Booking",
                cssClass: "viewMultipleCourseOptionsModal",
                filePath: "/app/components/login/viewMultipleCourseOptions.html",
                controllerName: "ViewCourseOptionsCtrl"
            });
        };

        $scope.showLoginInvitation = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Please Log In To Your Account",
                cssClass: "loginInvitationModal",
                filePath: "/app/components/login/loginInvitation.html",
                controllerName: "LoginInvitationCtrl"
            });
        };

        $scope.retrieveOrganisationSpecificContent = function () {
            if ((organisationRoute !== undefined) && !(jQuery.isEmptyObject(organisationRoute))) {
                $scope.organisationDisplayName = organisationRoute[0].DisplayName;
                $scope.clientApplicationDescription = organisationRoute[0].ApplicationDescription;
                $scope.clientWelcomeMessage = organisationRoute[0].WelcomeMessage;
                $scope.organisationId = organisationRoute[0].OrganisationId;
            }
        }

        $scope.recordBookingAttempt = function (licence) {
            AuthenticationService.recordBookingAttempt(licence)
        }

        $scope.privacyNotice();
        $scope.cookiesEnabled();
        $scope.retrieveOrganisationSpecificContent();

        $scope.disableClientView = function () {

            return !$scope.linkEnabled;
           
        }

        
    }

    

})();

