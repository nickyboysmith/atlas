(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddSpecialRequirementCtrl", AddSpecialRequirementCtrl);

    AddSpecialRequirementCtrl.$inject = ["$scope", "SpecialRequirementService", "ModalService", "activeUserProfile"];

    function AddSpecialRequirementCtrl($scope, SpecialRequirementService, ModalService, activeUserProfile) {

        $scope.notes = "";
        $scope.errorMessage = "";

        $scope.addSpecialRequirement = function (ntitle, ndescription) {
            $scope.newRequirement = {};
            $scope.newRequirement.OrganisationId = $scope.$parent.selectedOrganisationId;
            $scope.newRequirement.NewTitle = ntitle;
            $scope.newRequirement.NewDescription = ndescription;
            $scope.newRequirement.UserID = activeUserProfile.UserId;
            SpecialRequirementService.addRequirement($scope.newRequirement)
                .then(
                    function successCallback(response) {
                        if (response.data == false) {
                            errorMessage = "Couldn't add requirement - please contact support.";
                        }
                        else {
                            //can be called from client or special requirements views so different actions to update calling view
                            if ($scope.$parent.source.toLowerCase() == "specialrequirements") {
                                $scope.$parent.showSpecialRequirements($scope.$parent.selectedOrganisationId, response.data);
                            }
                            else if ($scope.$parent.source.toLowerCase() == "client") {
                                $scope.$parent.getAvailable();
                            }
                            $scope.$parent.statusMessage = "Additional requirement '" + ntitle + "' created sucessfully";                            
                            ModalService.closeCurrentModal("addSpecialRequirementModal");                            
                        }
                    },
                    function errorCallback(response) {
                        if (response.data) {
                            $scope.errorMessage = response.data;
                        } else {
                            $scope.errorMessage = "Couldn't add requirement - please contact support.";
                        }
                    }
                );
        }

        $scope.cancel = function () {
            ModalService.closeCurrentModal("addSpecialRequirementModal");
        }
    };


})();