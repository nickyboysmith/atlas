(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ClientsMarkedForDeletionCtrl', ClientsMarkedForDeletionCtrl);

    ClientsMarkedForDeletionCtrl.$inject = ['$scope', '$location', '$window', '$http', '$compile', 'AtlasCookieFactory', 'SearchHistoryService', 'activeUserProfile', "ModalService", "ClientService"];

    function ClientsMarkedForDeletionCtrl($scope, $location, $window, $http, $compile, AtlasCookieFactory, SearchHistoryService, activeUserProfile, ModalService, ClientService) {

        $scope.cookieFactory = AtlasCookieFactory;
        $scope.deletedClients = {};
        $scope.itemsPerPage = 10;

        $scope.getClientsMarkedForDeletion = function () {
            ClientService.getClientsMarkedForDeletion(activeUserProfile.selectedOrganisation.Id)
            .then(
                function (response) {
                    $scope.deletedClients = response.data;
                    $scope.deletedClientsTemplate = response.data
                });
        }

        /**
         * Open the client view in a modal when clicked
         */
        $scope.showClientModal = function (clientId) {
            $scope.clientId = clientId;

            ModalService.displayModal({
                scope: $scope,
                cssClass: "clientDetailModal",
                title: "Client Details",
                controllerName: "clientDetailsCtrl",
                filePath: "/app/components/client/cd_view.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.getClientsMarkedForDeletion();
    }
    }) ();