(function () {

    'use strict';

    angular
        .module("app")
        .service("ClientService", ClientService);

    ClientService.$inject = ["$http"];

    function ClientService($http) {

        var clientService = this;

        /**
         * 
         */
        clientService.get = function (clientId) {
            return $http.get(apiServer + "/client/getentry/" + clientId);
        };

        clientService.save = function (client) {
            return $http.post(apiServer + "/client/saveentry/", client)
        };

        clientService.saveProfile = function (client) {
            return $http.post(apiServer + "/client/saveprofileentry/", client)
        };
        /**
        * Get the Client Titles
        */
        clientService.getClientTitles = function () {
            return $http.get(apiServer + "/client/GetTitles");
        };

        /**
        * Get the list of driver licence Types
        */
        clientService.getDriverLicenceTypes = function () {
            return $http.get(apiServer + "/DriverLicenceType/")
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * Create the email reference code
         */
        clientService.createEmailReference = function (client) {
            return $http.post(apiServer + "/client/createEmailReference", client);
        };

        clientService.getClientsByLicence = function (licenceNumber, organisationId) {
            return $http.get(apiServer + "/client/GetClientsByLicence/" + licenceNumber + "/" + organisationId);
        }

        clientService.getClientDORSData = function (clientId) {
            return $http.get(apiServer + "/client/GetClientDORSData/" + clientId);
        }

        /**
         * Get related Course to the client
         */
        clientService.getCourses = function (clientId, organisationId) {
            return $http.get(apiServer + "/client/GetCourses/" + clientId + "/" + organisationId);
        };

        /**
       * Get Client Notes By Id
       */
        clientService.getClientNotesById = function (ClientId) {
            return $http.get(apiServer + "/client/GetClientNotesById/" + ClientId);
        };

        /**
         * Get documents associated 
         * with client and organsaition
         */
        clientService.getDocuments = function(clientId, organisationId) {
            return $http.get(apiServer + "/document/client/" + organisationId + "/" + clientId);
        }

        /**
         * Get the special requirements
         * For a client within an organisation
         */
        clientService.getSpecialRequirements = function (clientId, organisationId) {
            return $http.get(apiServer + "/specialrequirement/" + clientId + "/" + organisationId);
        }

        /**
         * Get the special requirements
         * For an organisation
         */
        clientService.getOrganisationSpecialRequirements = function (clientId, organisationId) {
            return $http.get(apiServer + "/specialrequirement/organisation/" + clientId + "/" + organisationId);
        }

        

        /**
         * Update the special requirements
         */
        clientService.updateSpecialRequirements = function (specialRequirementDetails) {
            return $http.post(apiServer + "/SpecialRequirement", specialRequirementDetails);
        }
        
        /**
         * Add the special requirement to the DB
         */
        clientService.addSpecialRequirement = function (requirement) {
            return $http.post(apiServer + "/SpecialRequirement/Add", requirement);
        }

        /**
         * 
         */
        clientService.uploadDocument = function (document) {
            return $http.post(apiServer + "/DocumentUpload/Client", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            );
        };

        clientService.removeFromCourse = function (clientId, courseId, userId, notes) {
            var params = {
                            clientId: clientId,
                            courseId: courseId,
                            userId: userId,
                            notes: notes
                        };
            return $http.post(apiServer + "/client/removeFromCourse/", params);
        }

        /**
         * Mark the client for deletion
         */
        clientService.deleteClient = function (clientDelete) {
            return $http.post(apiServer + "/client/DeleteClient", clientDelete);
        };

        /**
         * Mark the client for undeletion
         */
        clientService.undeleteClient = function (clientUndelete) {
            return $http.post(apiServer + "/client/UndeleteClient", clientUndelete);
        };

        /**
         * Get clients marked for deletion by Organisation
         */
        clientService.getMarkedClientsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/client/GetMarkedClientsByOrganisation/" + organisationId)
        };
        
        /**
         * Delete clients marked for deletion
         */
        clientService.deleteMarkedClients = function (selectedClients) {
            return $http.post(apiServer + "/client/DeleteMarkedClients", selectedClients);
        };

        clientService.transferToNewCourse = function (clientId, fromcourseId, tocourseId, userId, notes) {
            return $http.get(apiServer + "/client/transferToNewCourse/" + clientId + "/" + fromcourseId + "/" + tocourseId + "/" + userId + "/" + notes);
        }

        /**
         * Save Unique Identifier
         */
        clientService.saveUniqueIdentifier = function (clientIdentifier) {
            return $http.post(apiServer + "/client/saveclientidentifier", clientIdentifier);
        };

        /**
         * Get Client View
         */
        clientService.getClientLock = function (clientId, organisationId, userId) {
            return $http.get(apiServer + "/client/GetClientLock/" + clientId + "/" + organisationId + "/" + userId);
        };

        /**
         * Add Client View
         */
        clientService.addClientLock = function (clientId, userId) {
            return $http.get(apiServer + "/client/AddClientLock/" + clientId + "/" +  userId);
        }; 

        /**
         * Delete Client View
         */
        clientService.removeClientLock = function (Id) {
            return $http.get(apiServer + "/client/RemoveClientLock/" + Id);
        };


        clientService.getDORSSchemeList = function (organisationId) {
            return $http.get(apiServer + "/DORSScheme/GetList/" + organisationId);
        };

        /**
        * Get Client Online Email ChangeRequest
        */
        clientService.getClientOnlineEmailChangeRequest = function (clientId) {
            return $http.get(apiServer + "/client/GetClientOnlineEmailChangeRequest/" + clientId)
        };

        /**
        * Get Client Online Email ChangeRequest
        */
        clientService.cancelEmailChangeRequest = function (clientOnlineEmailChangeRequestId) {
            return $http.get(apiServer + "/client/CancelEmailChangeRequest/" + clientOnlineEmailChangeRequestId)
        };

        /**
        * Get Client Online Email ChangeRequest
        */
        clientService.confirmEmailChangeRequest = function (clientOnlineEmailChangeRequestId, confirmationCode) {
            return $http.get(apiServer + "/client/ConfirmEmailChangeRequest/" + clientOnlineEmailChangeRequestId + "/" + confirmationCode)
        };

        clientService.getPaymentsByClient = function (clientId, organisationId) {
            return $http.get(apiServer + "/Client/getPayments/" + clientId + "/" + organisationId);
        }

        /**
         * Get client bookings
         */
        clientService.getCourseBookings = function (clientId, organisationId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/Client/GetClientBookings";
            return $http.get(endPointUrl + "/" + clientId + "/" + organisationId, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        /**
         * Get client course removals
         */
        clientService.GetCourseRemovals = function (clientId, organisationId) {
            var authToken = sessionStorage.getItem("authToken");
            var endPointUrl = apiServer + "/Client/GetCourseRemovals";
            return $http.get(endPointUrl + "/" + clientId + "/" + organisationId, {
                headers: {
                    "X-Auth-Token": authToken
                }
            });
        };

        clientService.courseClientTransferRequest = function (courseSelected) {
            return $http.post(apiServer + "/client/CourseClientTransferRequest", courseSelected);
        };


        clientService.returnBirthdateFromUkLicenceNumber = function (licenceNumber) {
            return $http.get(apiServer + "/Client/ReturnBirthdateFromUkLicenceNumber/" + licenceNumber);
        }

        clientService.GetByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/Client/getByOrganisation/" + organisationId);
        }

        clientService.sendDocToPrintQueue = function (documentId, clientId, userId, organisationId) {
            return $http.get(apiServer + "/Document/AddDocumentToPrintQueue/" + documentId + "/" + clientId + "/" + userId + "/" + organisationId)
                .then(function (response) {
                    return response.data
                },
                function (response) {
                    return response.data;
                });
        }

        clientService.getClientStatus = function (clientId) {
            return $http.get(apiServer + "/client/getClientStatus/" + clientId);
        }

        clientService.getClientsMarkedForDeletion = function (organisationId) {
            return $http.get(apiServer + "/client/getClientsMarkedForDeletion/" + organisationId);
        };

        clientService.getClientLicences = function (clientid) {
            return $http.get(apiServer + "/client/GetClientLicence/" + clientId);
        };

        clientService.getBasicClientInfo = function (clientId) {
            return $http.get(apiServer + "/Client/GetBasicClientInfo/" + clientId);
        };

        clientService.getClientEmailAddresses = function (clientId) {
            return $http.get(apiServer + "/Client/GetClientEmailAddresses/" + clientId);
        };

        clientService.getCourseInfo = function (clientId) {
            return $http.get(apiServer + "/Client/CourseInformation/" + clientId);
        };

        clientService.getClientLicences = function (clientId) {
            return $http.get(apiServer + "/Client/GetClientLicences/" + clientId);
        };

        clientService.getClientPhoneNumbers = function (clientId) {
            return $http.get(apiServer + "/Client/GetClientPhoneNumbers/" + clientId);
        };
    }
})();