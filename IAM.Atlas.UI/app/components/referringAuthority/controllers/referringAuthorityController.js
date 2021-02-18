(function () {
    'use strict';

    angular
        .module('app')
        .controller('referringAuthorityCtrl', referringAuthorityCtrl);

    referringAuthorityCtrl.$inject = ["$scope", "ReferringAuthorityService", "UserService", "activeUserProfile", "DateFactory"];

    function referringAuthorityCtrl($scope, ReferringAuthorityService, UserService, activeUserProfile, DateFactory) {

 
        $scope.authority = {};
        $scope.selectedOrganisation = {};
        $scope.referringAuthorityService = ReferringAuthorityService;
        $scope.userService = UserService;


        $scope.userId = activeUserProfile.UserId;

        $scope.userService.checkSystemAdminUser($scope.userId)
                      .then(
                          function (data) {
                              $scope.isAdmin = data;
                          },
                          function (data) {
                              $scope.isAdmin = false;
                          }
                      );

        //Get Referring Authority Organisations
        $scope.getReferringAuthorityOrganisations = function () {

            $scope.referringAuthorityService.getReferringAuthorityOrganisations()
            .then(function (data) {

                $scope.organisations = data;

                if ($scope.organisations.length > 0) {
                    $scope.selectedOrganisation = $scope.organisations[0];

                    $scope.getReferringAuthority($scope.selectedOrganisation);

                }

            }, function (data) {
                console.log("Can't get Organisations");
            });
        }
 
        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.toggleCalendar2 = function () {
            $scope.displayCalendar2 = !$scope.displayCalendar2;
        }

        $scope.formatDate = function (date) {
            return DateFactory.formatDateSlashes(date);
        }

        $scope.getReferringAuthority = function (organisation) {
            
            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedOrganisation = organisation;
           
            $scope.referringAuthorityService.getAuthority($scope.selectedOrganisation.AssociatedOrganisationId)
                .then
                    (
                        function (data) {
                            if (data) {
                                $scope.authority = data;
                            }
                        }
                        ,
                        function (data) {
                        }
                    );
        }

        $scope.saveAuthority = function () {

            $scope.authority.UserId = activeUserProfile.UserId;
            $scope.authority.AssociatedOrganisationId = $scope.selectedOrganisation.AssociatedOrganisationId;
            $scope.authority.ReferringAuthorityId = $scope.selectedOrganisation.Id;
           
            ReferringAuthorityService.saveAuthority($scope.authority)
                .then
                    (
                        function (data) {
                            if (data) {
                                if(data == "success"){
                                    $scope.successMessage = "Authority Saved";
                                    $scope.validationMessage = "";
                                }
                                else {
                                    $scope.validationMessage = "Save Failed";
                                    $scope.successMessage = "";
                                }
                            }
                        }
                        ,
                        function (data) {
                            $scope.validationMessage = "Save Failed";
                            $scope.successMessage = "";
                        }
                    );
        }

        $scope.getReferringAuthorityOrganisations();
    }
})();