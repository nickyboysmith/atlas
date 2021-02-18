(function () {
    'use strict';
    angular
        .module('app')
        .controller('ClientsWithoutEmailsCtrl', ['$scope', '$filter', 'activeUserProfile', 'DateFactory', 'ModalService', ClientsWithoutEmailsCtrl]);

    function ClientsWithoutEmailsCtrl($scope, $filter, activeUserProfile, DateFactory, ModalService) {

        $scope.clientsWithoutEmailsCollection = $scope.clientsWithoutEmails;

        $scope.formatDate = function (date) {
            if (date) {
                return DateFactory.formatDateddMONyyyy(DateFactory.parseDate(date));
            }
        }

        $scope.openClientModal = function (clientId) {
            /**
             * Create Modal Buttons Object
             */
            var modalDetails = {
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            };

            $scope.clientId = clientId;
            modalDetails = angular.extend(modalDetails, {
                scope: $scope,
                title: "Client Details",
                cssClass: "clientDetailModal",
                filePath: "/app/components/client/cd_view.html",
                controllerName: "clientDetailsCtrl",
            });

            /**
             * Fire the modal
             */
            ModalService.displayModal(modalDetails);
        };
    }
})();