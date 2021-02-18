(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('SpecialRequirementCtrl', SpecialRequirementCtrl);

    SpecialRequirementCtrl.$inject = ["$scope", "$http", "$window", "$filter", "SpecialRequirementService", "UserService", "activeUserProfile", "ModalService"];

    function SpecialRequirementCtrl($scope, $http, $window, $filter, SpecialRequirementService, UserService, activeUserProfile, ModalService) {
        
        $scope.userId = activeUserProfile.UserId;
        $scope.organisations = {};
        $scope.specialRequirements = {};
        $scope.specialRequirementDetail = {};
        $scope.selectedOrganisationId = -1;
        $scope.selectedSystemTaskId = -1;
        $scope.showSaveSuccess = false;
        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        $scope.errorMessage = "";
        $scope.statusMessage = "";

        $scope.specialRequirementService = SpecialRequirementService;
        $scope.userService = UserService;
        
        $scope.isAdminUser = false;

        $scope.userService.checkSystemAdminUser($scope.userId).then(function (response) {
            $scope.isAdminUser = JSON.parse(response);
        });

        $scope.showSpecialRequirements = function (selectedOrganisationId, specialRequirementId) {
            $scope.specialRequirementDetail = {};
            $scope.errorMessage = "";
            if (specialRequirementId == 0) {
                $scope.statusMessage = "";
            }
            $scope.selectedSpecialRequirementId = 0;
            $scope.selectedOrganisationId = selectedOrganisationId;
            $scope.specialRequirementService.showSpecialRequirements(selectedOrganisationId, $scope.userId)
                .then(function (response) {
                    $scope.specialRequirements = response;

                    if ($scope.specialRequirements.length > 0) {
                        $scope.specialRequirements = $filter('orderBy')($scope.specialRequirements, 'Name');
                        if (specialRequirementId > 0) {
                            $scope.loadSpecialRequirementDetail(specialRequirementId, true)
                        } else {
                            $scope.loadSpecialRequirementDetail($scope.specialRequirements[0].Id, false)
                        }
                    }
                }, function (response, status, headers, config) {
                    alert('Error retrieving additional requirements list');
                });
        }

        $scope.loadOrganisations = function (userId) {
            $scope.userService.getOrganisationIds(userId)
                .then(function (response, status, headers, config) {
                    $scope.organisations = response;
                    $scope.selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
                    if ($scope.organisations.length > 0) {
                        $scope.showSpecialRequirements($scope.selectedOrganisationId, 0);
                    }
                }, function (response, status, headers, config) {
                    alert('Error retrieving client list');
                });
        }

        

        $scope.loadOrganisations($scope.userId);
        
        $scope.loadSpecialRequirementDetail = function (specialRequirementId, newSpecialRequirement)
        {
            $scope.errorMessage = "";

            if (newSpecialRequirement == false) {
                $scope.statusMessage = "";
            }

            $scope.showSaveSuccess = false;
            $scope.selectedSpecialRequirementId = specialRequirementId;
            // TODO: optimise with a filter
            if ($scope.specialRequirements != {})
            {
                for (var i = 0; i < $scope.specialRequirements.length; i++)
                {
                    if ($scope.specialRequirements[i].Id == specialRequirementId)
                    {
                        $scope.specialRequirementDetail = $scope.specialRequirements[i];
                        break;
                    }
                }
            }
        }

        $scope.saveSpecialRequirement = function () {
            $scope.specialRequirementDetail.UserID = activeUserProfile.UserId;
            $scope.specialRequirementService.saveSpecialRequirement($scope.specialRequirementDetail)
                        .then(function (data, status, headers, config) {
                            $scope.errorMessage = "";
                            $scope.statusMessage = "Save Successful.";
                        }, function (data, status, headers, config) {
                            $scope.showErrorFader = true;
                            $scope.errorMessage = "Save Failed. Please try again. Please contact an administrator if the problem persists.";
                        });                
            
        }

        $scope.addNewRequirement = function () {

            $scope.source = "SpecialRequirements";

            ModalService.displayModal({
            scope: $scope,
            title: "Create A New Additional Requirements",
            cssClass: "addSpecialRequirementModal",
            filePath: "/app/components/specialRequirements/Add.html",
            controllerName: "AddSpecialRequirementCtrl"         
            
        });
        }
    }
})();