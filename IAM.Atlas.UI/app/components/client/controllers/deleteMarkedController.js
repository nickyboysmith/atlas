(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('DeleteMarkedClientsCtrl', DeleteMarkedClientsCtrl);

    DeleteMarkedClientsCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', "ClientService"];

    function DeleteMarkedClientsCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ClientService) {

        $scope.clientService = ClientService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.markedClients = {};

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        //Get Marked Clients
        $scope.getMarkedClientsByOrganisation = function (organisationId) {

            $scope.clientService.getMarkedClientsByOrganisation(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.markedClients = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Set Marked Clients
        $scope.setMarkedClients = function (Client) {

            Client.isSelected ? Client.isSelected = false : Client.isSelected = true;
        }

        //Remove Marked Clients
        $scope.removeMarkedClients = function () {

            var client = {
                selectedClients: [],
                userId: ""
            };

            //Filter out Selected Clients for removal
            var selectedClients = $filter("filter")($scope.markedClients, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedClients.forEach(function (arrayItem) {
                var x = arrayItem.Id
                client.selectedClients.push(x);
            });

            client.userId = $scope.userId;

            $scope.clientService.deleteMarkedClients(client)
                .then(
                    function (response) {
                        $scope.successMessage = "Delete Successful";
                        $scope.validationMessage = "";
                        // refresh the list 
                        $scope.getMarkedClientsByOrganisation($scope.organisationId);
                    },
                    function (response) {
                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );

        }

        $scope.HasMarkedClients = function () {

            if ($scope.markedClients.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getMarkedClientsByOrganisation($scope.organisationId);

    }

})();

