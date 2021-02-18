(function () {
    'use strict';

    angular
        .module('app')
        .controller('AddNetcallAgentCtrl', AddNetcallAgentCtrl);

    AddNetcallAgentCtrl.$inject = ["$scope", "UserService", "ModalService"];

    function AddNetcallAgentCtrl($scope, UserService, ModalService) {

        $scope.selectedSupportUser = {};
        $scope.selectedSupportUserId = -1;
        $scope.supportUsers = {};
        $scope.displaySupportUsers = {};

        $scope.fromAddNetcallAgent = true;
        $scope.organisationId = $scope.$parent.organisationId;
        
        $scope.GetAvailableNetcallAgentsByOrganisation = function (organisationId) {

            $scope.errorMessage = "";
          
            UserService.getAvailableNetcallAgentsByOrganisation(organisationId)

                .then(
                    function (data) {
                        $scope.supportUsers = data;
                        $scope.displaySupportUsers = $scope.supportUsers;
                    },
                    function (data) {

                    }
                );
        };

        $scope.selectSupportUser = function (user) {
            $scope.selectedSupportUserId = user.Id;
            $scope.selectedSupportUser = user;
        };

        // Add a Netcall Agent
        $scope.makeSelectedUserANetcallAgent = function () {

            $scope.netcallAgent = {
                Id: 0,
                UserId: $scope.selectedSupportUserId,
                DefaultCallingNumber: null,
                Disabled: false,
                UpdateByUserId: $scope.$parent.userId
            };
            
            $scope.userService.saveNetcallAgentCallingNumber($scope.netcallAgent)
                .then(
                    function (data) {
                        console.log("Success");
                        console.log(data);

                        // return the netcallAgent Id and set it for use in the Edit Calling Number
                        $scope.netcallAgent.Id = data;

                        // refresh the Available Netcall Agents 
                        $scope.GetAvailableNetcallAgentsByOrganisation($scope.$parent.organisationId);

                        // refresh the Netcall Agents 
                        $scope.$parent.getNetcallAgentsByOrganisation($scope.$parent.organisationId);

                        $scope.modalService.displayModal({
                            scope: $scope,
                            title: "Edit NetCall Agent Calling Number",
                            cssClass: "EditNetcallAgentNumberModal",
                            filePath: "/app/components/users/editNetcallAgentNumber.html",
                            controllerName: "EditNetcallAgentNumberCtrl",
                            buttons: {
                                label: 'Close',
                                cssClass: 'closeModalButton',
                                action: function (dialogueItself) {
                                    dialogueItself.close();
                                }
                            }
                        });
                    },
                    function (data) {
                        console.log("Error");
                        console.log(data);
                    }
                );
        }

        // Disable Edit If No Agent Selected
        $scope.IsAgentSelected = function () {

            if ($scope.selectedSupportUserId > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.GetAvailableNetcallAgentsByOrganisation($scope.$parent.organisationId);
    }

})();