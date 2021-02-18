(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddClientDocumentCtrl", AddClientDocumentCtrl);

    AddClientDocumentCtrl.$inject = ["$scope", "activeUserProfile", "ClientService", "ModalService"];

    function AddClientDocumentCtrl($scope, activeUserProfile, ClientService, ModalService) {



        /**
         * 
         */
        if ($scope.$parent.addDocumentClientName) {
            $scope.clientDisplayName = $scope.$parent.addDocumentClientName;
        }

        /**
         * 
         */
        if ($scope.$parent.clientID) {
            $scope.clientId = $scope.$parent.clientID;
        }

        /**
         * 
         */
        if ($scope.$parent.addDocumentMaxSize) {
            $scope.allowedMaximumFileSize = $scope.$parent.addDocumentMaxSize;
        }

        /**
         * String values to pass to directive
         */
        $scope.theLabel = "Client";
        $scope.theLabelValue = $scope.clientDisplayName + " - (Id:" + $scope.clientId + ")";
        $scope.theMaxSize = $scope.allowedMaximumFileSize;

        /**
         * Create form data to send to the web api
         * ?? Put  in a factory
         */
        $scope.covertFormData = function (document) {
            var formData = new FormData();

            if (!document.Description == true)
            {
                document.Description = '';
            }
           
            formData.append("ClientId", $scope.clientId);
            formData.append("Name", document.Name);
            formData.append("Title", document.Title);
            formData.append("Description", document.Description);
            formData.append("FileName", document.FileName);
            formData.append("file", document.File);
            formData.append("UserId", activeUserProfile.UserId);
            formData.append("OrganisationId", activeUserProfile.selectedOrganisation.Id);
            return formData;
        };

        /**
         * 
         */
        $scope.saveFile = function (document) {
            ClientService.uploadDocument($scope.covertFormData(document))
            .then(
                function (response) {
                    $scope.$parent.getTheDocuments($scope.clientId);
                    ModalService.closeCurrentModal("addClientDocumentModal");
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };


    }




})();