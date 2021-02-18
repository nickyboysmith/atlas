(function () {

    'use strict';

    angular
    .module("app")
    .service("ClientRegistrationService", ClientRegistrationService);

    ClientRegistrationService.$inject = ["$http"];

    function ClientRegistrationService($http) {

        var clientRegisterService = this;

        clientRegisterService.registerNewClient = function (newClient) {
            return $http.post(apiServer + "/client/newregistration", newClient);
        };

        /**
         * Use the auth token
         * Add to the headers
         * Udate the client confirmation
         */
        clientRegisterService.confirmRegistration = function (confirmationDetails) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/Client/NewRegistration/Confirmation";
            return $http.post(endPointUrl, confirmationDetails, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Get the special requirements
         * For an organisation
         */
        clientRegisterService.getOrganisationSpecialRequirements = function (clientId, organisationId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/specialrequirement/organisation/";
            return $http.get(endPointUrl + clientId + "/" + organisationId, {
                    headers: {
                            "X-Auth-Token": authToken
                }
            });
        }

        /**
         * Save the special requirements for a client
         */
        clientRegisterService.saveClientSpecialRequirements = function (requirements) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/Client/NewRegistration/SpecialRequirements";
            return $http.post(endPointUrl, requirements, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        }

        /**
         * Get the available courses for a client
         */
        clientRegisterService.getAvailableCourses = function (courseDates) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/Client/NewRegistration/GetCourses";
            return $http.post(endPointUrl, courseDates, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Get online terms
         */
        clientRegisterService.getOnlineTerms = function (organisationId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/document/Terms";
            return $http.get(endPointUrl + "/" + organisationId, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };
        
        /**
         * Get client address
         */
        clientRegisterService.getClientAddress = function (clientId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/client/Address";
            return $http.get(endPointUrl + "/" + clientId, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * save the course booking
         */
        clientRegisterService.saveCourseBooking = function (courseBookingDetails) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/CourseBooking";
            return $http.post(endPointUrl, courseBookingDetails, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Process online course payments
         * Add the type to the request
         * 
         */
        clientRegisterService.processOnlinePayment = function (paymentDetail) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/CourseBooking/Payment";
            paymentDetail = angular.extend(paymentDetail, { type: "online" });
            return $http.post(endPointUrl, paymentDetail, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Process the payment after the 3d Secure
         */
        clientRegisterService.completeAuthorization = function (paymentDetail) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/CourseBooking/Payment/AuthorizationCompletion";
            return $http.post(endPointUrl, paymentDetail, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Get the payment Provider details for the org
         */
        clientRegisterService.getPaymentProvider = function (OrganisationId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/paymentprovider/getPaymentProvidersByOrganisation/" + OrganisationId;
            return $http.get(endPointUrl, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        clientRegisterService.updateClientOnlineBookingState = function (clientId, courseId) {
            return $http.post(apiServer + "/ClientOnlineBookingState/UpdateCourseBookedStatus/" + clientId + "/" + courseId);
        };

    }

})()