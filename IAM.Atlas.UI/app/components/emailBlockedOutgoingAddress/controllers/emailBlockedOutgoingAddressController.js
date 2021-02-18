(function () {

    'use strict';
    
    angular
        .module('app.controllers')
        .controller('EmailBlockedOutgoingAddressCtrl', EmailBlockedOutgoingAddressCtrl);

    EmailBlockedOutgoingAddressCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', "EmailBlockedOutgoingAddressService"];

    function EmailBlockedOutgoingAddressCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, EmailBlockedOutgoingAddressService) {

        $scope.emailBlockedOutgoingAddressService = EmailBlockedOutgoingAddressService;
        
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.blockedEmails = {};

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

        //Get Blocked Emails 
        $scope.getBlockedEmailsByOrganisation = function (organisationId) {

            $scope.emailBlockedOutgoingAddressService.GetByOrganisation(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.blockedEmails = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Set Selected Blocked Emails 
        $scope.setSelectedEmails = function (Email) {

            Email.isSelected ? Email.isSelected = false : Email.isSelected = true;

        }

        //Delete Blocked Emails 
        $scope.removeBlockedEmails = function () {

            var email = {
                selectedEmails: []
            };

            //Filter out Selected Emails for removal
            var selectedEmails = $filter("filter")($scope.blockedEmails, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedEmails.forEach(function (arrayItem) {
                var x = arrayItem.Id
                email.selectedEmails.push(x);
            });

            $scope.emailBlockedOutgoingAddressService.Delete(email)
                .then(
                    function (response) {
                        // refresh the list 
                        $scope.getBlockedEmailsByOrganisation($scope.organisationId);

                        $scope.successMessage = "Delete Successful";
                        $scope.validationMessage = "";
                    },
                    function (response) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }

        $scope.HasBlockedEmails = function () {

            if ($scope.blockedEmails.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getBlockedEmailsByOrganisation($scope.organisationId);

    }

})();

