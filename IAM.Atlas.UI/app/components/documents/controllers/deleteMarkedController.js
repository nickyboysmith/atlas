(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('DeleteMarkedDocumentsCtrl', DeleteMarkedDocumentsCtrl);

    DeleteMarkedDocumentsCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', "DocumentService"];

    function DeleteMarkedDocumentsCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, DocumentService) {

        $scope.documentService = DocumentService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.markedDocuments = {};

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

        //Get Marked Documents
        $scope.getMarkedDocumentsByOrganisation = function (organisationId) {

            $scope.documentService.getMarkedDocumentsByOrganisation(organisationId)
                .then(
                    function (data) {
                        console.log("Success");
                        console.log(data);
                        $scope.markedDocuments = data;
                    },
                    function (data) {
                        console.log("Error");
                        console.log(data);
                    }
                );
        }

        //Set Marked Documents
        $scope.setMarkedDocuments = function (Document) {

            Document.isSelected ? Document.isSelected = false : Document.isSelected = true;

        }

        //Remove Marked Documents
        $scope.removeMarkedDocuments = function () {

            var document = {
                selectedDocuments: [],
                userId: ""
            };

            //Filter out Selected Clients for removal
            var selectedDocuments = $filter("filter")($scope.markedDocuments, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedDocuments.forEach(function (arrayItem) {
                var x = arrayItem.Id
                document.selectedDocuments.push(x);
            });

            document.userId = $scope.userId;

            $scope.documentService.deleteMarkedDocuments(document)
                .then(
                    function (data) {

                        $scope.successMessage = "Successful Removal of Delete Flag(s)";
                        $scope.validationMessage = "";
                        // refresh the list 
                        $scope.getMarkedDocumentsByOrganisation($scope.organisationId);
                    },
                    function (data) {
                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );

        }

        $scope.HasMarkedDocuments = function () {

            if ($scope.markedDocuments.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getMarkedDocumentsByOrganisation($scope.organisationId);

    }

})();

