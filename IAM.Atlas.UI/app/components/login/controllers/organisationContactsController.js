(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('OrganisationContactsCtrl', OrganisationContactsCtrl);

    OrganisationContactsCtrl.$inject = ['$scope', 'ModalService', 'OrganisationContactService'];

    function OrganisationContactsCtrl($scope, ModalService, OrganisationContactService) {
        $scope.contacts = {};

        $scope.showOrganisationContactsMessage = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Your Local Contacts",
                cssClass: "organisationContactsModal",
                filePath: "/app/components/login/viewOrganisationContacts.html",
                controllerName: "ViewOrganisationContactsCtrl"
            });
        }

        $scope.getOrganisationContacts = function () {

            OrganisationContactService.getOrganisationContacts(sessionStorage.organisationId)
            .then(
                    function (response) {
                        $scope.contacts = response.data;
                    }
                    ,
                    function(response){

                    }
                  )
        }

        $scope.getSystemControlSettings = function () {
            OrganisationContactService.GetClientRegistrationSystemControlData()
                .then(
                    function successCallback(response) {
                        $scope.NonAtlasAreaInfo = response.data.NonAtlasAreaInfo;
                        $scope.NonAtlasAreaLink = response.data.NonAtlasAreaLink;
                        $scope.NonAtlasAreaLinkTitle = response.data.NonAtlasAreaLinkTitle;

                        /* if we don't have a title but do have a link show the link as the title */
                        if (!$scope.NonAtlasAreaLinkTitle == true && !$scope.NonAtlasAreaLink == false) {
                            $scope.NonAtlasAreaLinkTitle = $scope.NonAtlasAreaLink;
                        }

                    },
                    function errorCallback(response) {
                    }
                );
        }

        $scope.showRow = function (row) {
            if (row == '' || row == null) {
                return false;
            } else {
                return true;
            }
        }
        
        $scope.showOrganisationContactsMessage();
        $scope.getOrganisationContacts();
        $scope.getSystemControlSettings();
    }
})();

