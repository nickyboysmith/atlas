(function () {

    'use strict';

    angular
        .module("app")
        .controller("AssignMeterUsersCtrl", AssignMeterUsersCtrl);

    AssignMeterUsersCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "DashBoardMeterService", "UserService", "ModalOptionsFactory", "ModalService"];

    function AssignMeterUsersCtrl($scope, $filter, activeUserProfile, DashBoardMeterService, UserService, ModalOptionsFactory, ModalService) {

        $scope.selectedMeter = {};

        /**
         * If userAdmin
         */
        $scope.isAdmin;

        /**
         * Instantiate the scope property
         * Default the showOrganisationDropdown to false
         */
        $scope.showOrganisationDropdown = false;

        /**
         * Instantiate the scope property
         * Default the showMeterList to false
         */
        $scope.showMeterList = false;
        $scope.meterList = [];

        /**
         * Instantiate an empty array of objetcs
         * For the meter collection to copy the meter List Array
         */
        $scope.meterCollection = [];

        /**
         * Instatiate slectedOrganisation scope on the property
         * Create id property on the Id to use for users who arent sysadmins
         * 
         */
        $scope.selectedOrganisation = {
            id: ""
        };

        $scope.successMessage = "";

        /**
         * Check user 
         */
        UserService.getOrganisationIds(activeUserProfile.UserId)
            .then(
                function (response) {
                    $scope.selectedOrganisation.id = activeUserProfile.selectedOrganisation.Id;
                    if (response.length == 0) {
                    }
                    else if (response.length == 1) {
                        $scope.selectedOrganisation.id = activeUserProfile.selectedOrganisation.Id;
                        $scope.selectedOrganisation = $filter('filter')($scope.organisationList, { id: activeUserProfile.selectedOrganisation.Id })[0];
                        $scope.getMeterList($scope.selectedOrganisation);
                    }
                    else {
                        $scope.showOrganisationDropdown = true;
                        $scope.organisationList = response;
                        $scope.selectedOrganisation = $filter('filter')($scope.organisationList, {id: activeUserProfile.selectedOrganisation.Id})[0];
                        $scope.getMeterList($scope.selectedOrganisation);
                    }
                },
                function (reason) {
                }
            );


        /**
         * Get the meter list 
         * Then assign to the property meterList
         */
        $scope.getMeterList = function (organisation) {

            $scope.meterList = [];
            $scope.meterCollection = $scope.meterList;

            DashBoardMeterService.GetMetersByOrganisation(organisation.id)
            .then(
                function (response) {
                    if (response.length > 0) {
                        /**
                         * Put the meter list in a scope property
                         */
                        $scope.meterList = response;
                        $scope.meterCollection = $scope.meterList;

                        /**
                         * Fill the meterCollection with the meterList
                         */
                        //angular.forEach($scope.meterList, function (meter, index) {
                        //    $scope.meterCollection.push(meter);
                        //});
                        $scope.showMeterList = true;
                    }
                },
                function (reason) {
                }
            );
        };

        /**
         * Get the meter list
         * For the selected organisation
         */
        $scope.getMeterForTheOrganisation = function (organisation) {
            /**
             * Set the organisation on the scope property selectedOrganisation
             */
            $scope.selectedMeter = {};
            $scope.selectedOrganisation = organisation;
            $scope.getMeterList(organisation);
        };

        /**
         * Update the meter's organisation-wide availability
         */
        $scope.updateOrganisationMeterSetting = function (organisationMeter) {
            $scope.clearSuccessMessage();
            organisationMeter.OrganisationId = $scope.selectedOrganisation.id;
            organisationMeter.userId = activeUserProfile.UserId;
            DashBoardMeterService.UpdateMeter(organisationMeter)
            .then(
                function (response) {
                    if (response.length > 0) {
                        $scope.successMessage = "Save Successful";
                    }
                },
                function (reason) {
                }
            );
        };
        /**
         * Get the available users 
         * For the selected meter
         */
        $scope.selectTheMeter = function (meter) {

            console.log(meter);
            console.log("Call the service");
            /**
             * Assign the tainer variable
             * To the 'selectedMeter' property on the scope
             */
            if (meter.RefreshRate.indexOf('.') != -1) {
                meter.RefreshRate = meter.RefreshRate.slice(0, meter.RefreshRate.indexOf('.') + 4);
            }
            
            $scope.selectedMeter = meter;

            /**
             * Extend the modal!
             */
            //ModalOptionsFactory.extend({
            //    mainModalID: "#assignMeterUsers",
            //    firstColumn: "#assignMeterFirstModalColumn",
            //    secondColumn: "#additionalAssignMeterContainer",
            //    classToRemove: "col-md-12",
            //    classToAdd: "col-md-5",
            //    cssProperties: {
            //        width: "950px"
            //    }
            //});

            $scope.getTheAvailableUsers();
        };

        /**
         * Open the Modal to update the course types
         */
        $scope.openAssignUsersModal = function () {

            // Put a diff meter If on scope
            $scope.replaceMeterId = $scope.selectedMeter.Id;
            $scope.replaceOrganisationId = $scope.selectedOrganisation.id;

            ModalService.displayModal({
                scope: $scope,
                title: "Update " + $scope.selectedMeter.Name + " Meter's Users",
                cssClass: "updateUserDashBoardMetersModal",
                filePath: "/app/components/dashboardMeter/updateMeter.html",
                controllerName: "MeterUsersCtrl",
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
         * 
         */
        $scope.getTheAvailableUsers = function () {
            DashBoardMeterService.getSelectedUsers($scope.selectedMeter.Id, $scope.selectedOrganisation.id)
            .then(
                function (response) {
                    $scope.selectedMeterUsers = response;
                },
                function (reason) {
                }
            );
        };

        $scope.clearSuccessMessage = function () {
            $scope.successMessage = "";
        }

        $scope.meterSelected = function (meter) {
            var selected = false;
            if (meter) {
                if (meter.Id > 0)
                {
                    selected = true;
                }
            }
            return selected;
        }
    }
})();