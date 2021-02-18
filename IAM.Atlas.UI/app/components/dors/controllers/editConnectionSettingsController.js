(function () {

    'use strict';

    angular
        .module("app")
        .controller("EditConnectionSettingsCtrl", EditConnectionSettingsCtrl);

    EditConnectionSettingsCtrl.$inject = ["$scope", "activeUserProfile", "DorsConnectionSettingsService", "ModalService"];

    function EditConnectionSettingsCtrl($scope, activeUserProfile, DorsConnectionSettingsService, ModalService) {

        /**
         *  Instantiate Organisation List Variable
         */
        $scope.organisationList = [];

        /**
         *
         */
        $scope.getOrganisations = function () {
            DorsConnectionSettingsService.getAllOrganisations(activeUserProfile.UserId)
                .then(
                    function (response) {
                        $scope.organisationList = response;
                    },
                    function (response) {
                        console.log(response);
                    }
                );
        };
        $scope.getOrganisations();

        /**
         * Show a modal based on the Id
         */
        $scope.showEditModal = function (organisation) {

                /**
                 * The organisation Details on the scope
                 */
                $scope.dorsSettingsOrganisation = organisation;

                /**
                 * Call the Modal
                 */
                ModalService.displayModal({
                    scope: $scope,
                    title: "Connection Details",
                    cssClass: "editConnectionDetailsModal",
                    filePath: "/app/components/dors/editConnectionDetails.html",
                    controllerName: "EditConnectionDetailsCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });

            
        };

        /**
         * Show the add modal now 
         */
        $scope.showAddModal = function () {

            /**
             * Call the Modal
             */
            ModalService.displayModal({
                scope: $scope,
                title: "Add DORS Connection",
                cssClass: "addDORSConnectionModal",
                filePath: "/app/components/dors/addDORSConnection.html",
                controllerName: "AddDORSConnectionCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };



    }



})();