(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('NetcallAgentsCtrl', NetcallAgentsCtrl);

    NetcallAgentsCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile'];

    function NetcallAgentsCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile) {

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.netcallAgents = {};
        $scope.selectedAgent = {};

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        //Get NetcallAgents
        $scope.getNetcallAgentsByOrganisation = function (organisationId) {

            $scope.userService.getNetcallAgentsByOrganisation(organisationId)
                .then(
                    function (data) {
                        $scope.netcallAgents = data;
                    },
                    function (data) {
                        console.log("Error");
                        console.log(data);
                    }
                );
        }

        //Set Selected Netcall Agent 
        $scope.setSelectedAgent = function (SelectedAgent) {

            $scope.selectedAgent = SelectedAgent;
            $scope.selectedNetcallAgent = SelectedAgent.Id;

        }

        // Display Add Netcall Agent Modal
        $scope.addNetcallAgent = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add User as a NetCall Agent",
                cssClass: "AddNetcallAgentModal",
                filePath: "/app/components/users/addNetcallAgent.html",
                controllerName: "AddNetcallAgentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        // Edit Netcall Agent Number
        $scope.editNetcallAgentNumber = function () {

            // repopulate the selected agent again in case user doers not reselect but just edits again
            $scope.netcallAgents.forEach(function (arrayItem) {
                var x = arrayItem.Id
                if (x == $scope.selectedNetcallAgent) { $scope.selectedAgent = arrayItem; }
            });
           
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
        }
        
        // Disable Edit If No Agent Selected
        $scope.IsAgentSelected = function () {

            if ($scope.selectedNetcallAgent > 0) {
                return false;
            }
            else {
                return true;
            }
        }
        
        $scope.getOrganisations($scope.userId);
        $scope.getNetcallAgentsByOrganisation($scope.organisationId);

    }

})();

