(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('VenueCostTypeCtrl', VenueCostTypeCtrl);

    VenueCostTypeCtrl.$inject = ["$scope", "$http", "$window", "VenueCostTypeService", "UserService"];

    function VenueCostTypeCtrl($scope, $http, $window, VenueCostTypeService, UserService)
    {
        /*
        *Fetch and load the Organisation(s) and their venue cost types: will need to pass in user id or means to obtain it server side and 
        *authentication data, which is still to be developed and applied across the system: 21/09/2015, Dan Murray
        */

        $scope.userService = UserService;
        $scope.venueCostTypeService = VenueCostTypeService;

        $scope.userId = "1";
        $scope.venueCostTypes = {};
        $scope.venueCostTypeDetails = {};
        $scope.organisations = {};
        $scope.showOrganisationsDropDown = true;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        // function declarations

        $scope.showVenueCostTypes = function (organisationId) {
            $scope.selectedOrganisation = organisationId;
            $scope.venueCostTypeService.getVenueCostTypes(organisationId)
                .then(function (data) {
                    $scope.venueCostTypes = data;
                });
            $scope.addNewVenueCostType();
        };
        
        $scope.showVenueCostTypeDetail = function (val) {                       
            $scope.venueCostTypeDetails = JSON.parse(JSON.stringify($scope.venueCostTypes[val]));
        };

        $scope.addNewVenueCostType = function () {
            // reset the venue cost type detail on the right
            $scope.venueCostTypeDetails = {};
            $scope.venueCostTypeDetails.UserId = $scope.userId;
            $scope.venueCostTypeDetails.OrganisationId = $scope.selectedOrganisation;
        };

        $scope.saveVenueCostType = function () {
            $scope.venueCostTypeService.saveVenueCostType($scope.venueCostTypeDetails)
                .then(function () {

                    $scope.showSuccessFader = true;
                    
                    $scope.addNewVenueCostType();
                    $scope.showVenueCostTypes($scope.selectedOrganisation);
                });
        };

        $scope.loadVenueCostTypeDetail = function (venueCostTypeId) {

            for (var i = 0; i < $scope.venueCostTypes.length; i++) {

                if ($scope.venueCostTypes[i].Id == venueCostTypeId) {
                    $scope.addNewVenueCostType();
                    $scope.venueCostTypeDetails.Id = $scope.venueCostTypes[i].Id;
                    $scope.venueCostTypeDetails.Name = $scope.venueCostTypes[i].Name;
                    $scope.venueCostTypeDetails.Disabled = $scope.venueCostTypes[i].Disabled;
                }
            }
        };

        $scope.closeModal = function () {
            // run the below function on the parent modal when adding a venue cost. 
            // may need a scope param to see if that is what we are doing.
            $scope.refreshVenueCostTypes()
                .then(function (data) {
                    $('button.close').last().trigger('click');
                });
        };

        // initialisations
        if ($scope.selectedOrganisation == undefined) {
            $scope.selectedOrganisation = -1;
        }
        else // we are loading the form as a modal from the venue cost modal
        {
            $scope.showOrganisationsDropDown = false;
            $scope.showVenueCostTypes($scope.selectedOrganisation);
        }

        $scope.venueCostTypeDetails.UserId = $scope.userId;
        $scope.venueCostTypeDetails.OrganisationId = $scope.selectedOrganisation;

        $scope.userService.getOrganisationIds($scope.venueCostTypeDetails.UserId)
            .then(function (data) {
                $scope.organisations = data;
            });

        $scope.userService.checkSystemAdminUser($scope.venueCostTypeDetails.UserId)
            .then(function (data) {
                $scope.isAdmin = JSON.parse(data);
            });
    } 
})();