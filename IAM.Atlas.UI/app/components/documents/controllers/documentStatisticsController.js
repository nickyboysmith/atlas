(function () {

    'use strict';

    angular
        .module("app")
        .controller("DocumentStatisticsCtrl", DocumentStatisticsCtrl);

    DocumentStatisticsCtrl.$inject = ["$scope", "activeUserProfile", "ModalService", "DocumentService", "UserService"];

    function DocumentStatisticsCtrl($scope, activeUserProfile, ModalService, DocumentService, UserService) {

        $scope.documentStats = {};
        $scope.organisationDocumentStats = {};
        $scope.selectedOrganisationId = {};

        $scope.getStatistics = function () {
            DocumentService.getDocumentSystemStatistics()
                .then(
                    function successCallback(response) {
                        $scope.documentStats = response;
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.getOrganisationStatistics = function (organisationId) {
            DocumentService.getDocumentOrganisationStatistics(organisationId)
                .then(
                    function successCallback(response) {
                        $scope.organisationDocumentStats = response;
                    },
                    function errorCallback(response) {

                    }
                );
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {
            UserService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                $scope.selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
                UserService.checkSystemAdminUser(userId)
                    .then(function (data) {
                        $scope.isAdmin = data;
                        $scope.getOrganisationStatistics($scope.selectedOrganisationId);
                    });
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getSelectedOrganisationId = function () {
            var selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
            return selectedOrganisationId;
        }

        $scope.GetSize = function (sizeInBytes) {
            var size = "";
            if (sizeInBytes > 1000000) {
                size = (sizeInBytes / 1000000).toFixed(2) + "Gb";
            }
            else if (sizeInBytes > 1000) {
                size = (sizeInBytes / 1000) + "Mb";
            }
            else if (sizeInBytes >= 0) {
                size = sizeInBytes + "Kb";
            }
            return size;
        }

        $scope.manageDocuments = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Document Management",
                closable: true,
                filePath: "/app/components/organisation/documents.html",
                controllerName: "OrganisationDocumentsCtrl",
                cssClass: "OrganisationDocumentManagementModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.getStatistics();
        $scope.getOrganisations(activeUserProfile.UserId);
    }

})();