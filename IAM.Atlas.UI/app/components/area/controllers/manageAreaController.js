(function () {

    'use strict';


    angular
        .module("app")
        .controller("ManageAreaCtrl", ManageAreaCtrl);

    ManageAreaCtrl.$inject = ["$scope", "AreaManagementFactory", "AreaManagementService", "UserService"];

    function ManageAreaCtrl($scope, AreaManagementFactory, AreaManagementService, UserService) {


        $scope.areaManagementService = AreaManagementService;
        $scope.areaManagementFactory = AreaManagementFactory;

        $scope.userService = UserService;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;


        /**
         * Create Object
         */
        $scope.manage = {
            theArea: {
                Disabled: {
                    area: false,
                    label: "",
                    status: ""
                }
            }
        };


        /**
        * Set to false
        */
        $scope.isAdmin;
        /**
         * Set the organisation dropdown to the default
         */
        $scope.selectedOrganisation = "*";

        /**
         * Set the completed message
         */
        $scope.completeMessage = "";

        /**
         * Hide the success message
         */
        $scope.hideSuccessMessage = true;

        /**
         * Hide add new button
         */
        $scope.hideAddNewOnStart = true;

        /**
         * Hide the unused features on page load
         */
        $scope.hideOnStart = true;

        /**
         * Move the add new button over
         */
        $("#theAddNewContainer").addClass("col-md-offset-3");

        /**
         * user id
         * get from the active user object
         * @todo get userid from the active object
         */

        // admin 
        //$scope.userId = 1;
        // not an admin 
        $scope.userId = 297;

        
        $scope.loadOrganisations = function (userId) {

            /**
         * Check to see if the user
         * Is a system administrator*/
            $scope.userService.checkSystemAdminUser(userId)

                    .then(function (response) {


                        $scope.isAdmin = JSON.parse(response);
                       
                        $scope.userService.getOrganisationIds(userId)

                            .then(function (response) {

                                $scope.relatedOrganisations = response;

                                if ($scope.isAdmin === true) {
                                    $scope.hideAreaTable = true;
                                }
                                else {

                                    $("#areaInput").prop("disabled", true);

                                    /**
                                     * Show the add new button now an organisation has been selected.
                                     */
                                    $scope.hideAddNewOnStart = false;

                                    $scope.associatedOrganisationId = $scope.relatedOrganisations[0].id;
                                   
                                    $scope.areaManagementService.getAreas($scope.associatedOrganisationId).then(function (response) {
                                        $scope.areaCollection = response;
                                    });

                                    $scope.hideOrganisationList = true;
                                }
                        }, function (data, status) {
                    });
            }, function (data, status) {
            });

        }

        $scope.loadOrganisations($scope.userId);
            /**
             * Select organisation
             */
        $scope.selectTheOrganisation = function () {

            /**
             * Show the add new button now an organisation has been selected.
             */
            $scope.hideAddNewOnStart = false;

            $scope.areaManagementService.getAreas($scope.selectedOrganisation).then(function (response) {
                $scope.areaCollection = response;
        });
        $scope.hideAreaTable = false;
        };


        /**
        * Select the area and then add to the page
        * @param {area} Area to be selected
        */
        $scope.selectTheArea = function (area) {

            $scope.manage.theArea = area;

            $scope.hideOnStart = false;

            if ($scope.isAdmin === false) {
                $("#areaInput").prop("disabled", true);
        }

            $scope.disabledStatus = area.Disabled;
            $scope.disabledMessage = $scope.areaManagementFactory.getDisabledMessage($scope.disabledStatus);
            $scope.manage.theArea.Disabled = $scope.disabledMessage;

        };

            /**
             *  Change 
             */
        $scope.changeTheMessage = function () {

            $scope.disabledStatus = $scope.manage.theArea.Disabled.area;
            $scope.disabledMessage = $scope.areaManagementFactory.getDisabledMessage($scope.disabledStatus);
            $scope.manage.theArea.Disabled = $scope.disabledMessage;
            
        };

            /**
             * 
             */
        $scope.saveAreaMaintenance = function () {

            $scope.addObject = {
                    disabled: $scope.areaManagementFactory.convertToInteger($scope.manage.theArea.Disabled.area),
                    organisationId: $scope.associatedOrganisationId,
                    Name: $scope.manage.theArea.Name,
                    AreaId: $scope.manage.theArea.Id,
                    Notes: $scope.manage.theArea.Notes
        };


            /**
             * If this is not a super user 
             * add the organisation from the active user object 
             * (Hard coded) - Line 72
             */
            if ($scope.isAdmin === false) {
                $scope.addObject.organisationId = $scope.associatedOrganisationId;
        }

            /**
             * If super user
             * Get the organisation ID from the selected dropdown option
             * (gets from the "selectTheOrganisation" method) - Line 81 
             */
            if ($scope.isAdmin === true) {
                $scope.addObject.organisationId = $scope.selectedOrganisation;
        }

            /**
             * Send to the WebAPI
             */
            $scope.areaManagementService.saveArea($scope.addObject)
                .then(function (response) {


                    $scope.showSuccessFader = true;

                    /**
                     * Refresh the payment collection
                     * On Success
                     */
                    $scope.areaManagementService.getAreas($scope.addObject.organisationId).then(function (response) {
                        $scope.areaCollection = response;
                });


                    /**
                     * Show the completed div
                     * Add the success message
                     */
                    $scope.hideSuccessMessage = false;
                    $scope.completedMessage = response.replace(/\"/g, "");

             }, function(response) {

                    $scope.showErrorFader = true;

                    console.log(response);
        });

        };

            /**
             * Add a new area
             */
        $scope.addNewArea = function () {

            $scope.hideOnStart = false;

            /**
             * remove the offset class
             */
            $("#theAddNewContainer").removeClass("col-md-offset-3");

            /**
             * Add placeholder
             */
            $("#areaInput").prop("placeholder", "Please enter the new area");

            // $scope.manage.thePaymentType.Name = "";
            $scope.disabledMessage = $scope.areaManagementFactory.getDisabledMessage(false);


            /**
             * Create a new object
             * To send to the save method
             */
            $scope.manage.theArea = {
                Name: "",
                Id: undefined,
                Disabled: $scope.disabledMessage,
                Notes: ""
        };

            /**
             * If isn't super user
             * Enable the input field
             */
            if ($scope.isAdmin === false) {
                $("#areaInput").prop("disabled", false);
        }

            /**
             * If superuser
             * Fill out the disabled text & checkbox
             */
            if ($scope.isAdmin === true) {
                $scope.disabledMessage = $scope.areaManagementFactory.getDisabledMessage(false);
                $scope.manage.theArea.Disabled = $scope.disabledMessage;
        }
        };

            /**
             * 
             */
        $scope.closeModal = function () {
            console.log("Close the modal");
        };

    }

})();