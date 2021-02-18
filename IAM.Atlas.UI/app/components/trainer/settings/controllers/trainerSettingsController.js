(function () {
    'use strict';

    angular
        .module('app')
        .controller('trainerSettingsCtrl', ['$scope', 'TrainerSettingsService', 'UserService', 'activeUserProfile', trainerSettingsCtrl]);

    function trainerSettingsCtrl($scope, TrainerSettingsService, UserService, activeUserProfile, trainerSettingsCtrl) {
        
       
        
        $scope.selectedTrainer = null;
        $scope.trainerSettingsService = TrainerSettingsService;
        $scope.userService = UserService;

        $scope.trainer = {};
        $scope.trainers = {};
     
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

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        /**
        * Get the trainers associated with the selected Organisation
        */
        $scope.getOrganisationTrainers = function (orgId) {

            $scope.validationMessage = "";
            $scope.successMessage = "";

            $scope.trainerSettingsService.getOrganisationTrainers(orgId)
                .then(
                function (response) {

                    $scope.trainers = response.data;

                    if ($scope.trainers.length > 0) {

                        $scope.getTrainerSettings($scope.trainers[0].Id);

                    }

                }
                ,
                function () {
                }
            );
        }

        /**
        * Get the settings of the selected trainer
        */
        $scope.getTrainerSettings = function (trainerId) {
            
            $scope.validationMessage = "";
            $scope.successMessage = "";

            $scope.trainerSettingsService.getTrainerSettings(trainerId)
                .then(
                function (response) {

                    if (response.data.length > 0) {

                        $scope.trainer = response.data[0];
                        $scope.selectedTrainer = $scope.trainer.Id;
                    }
                }
                ,
                function () {
                }
                );
        }

        $scope.saveTrainerSettings = function () {

            $scope.trainerSettingsService.saveTrainerSettings($scope.trainer)
                .then(
                function (data, status) {
                    $scope.validationMessage = "";
                    $scope.successMessage = "Trainer Details Saved!";
                }
                ,
                function (data, status) {
                    
                    $scope.validationMessage = "Trainer Details NOT Saved!";
                    $scope.successMessage = "";
                }
                );
        }

        $scope.getOrganisations($scope.userId);
        $scope.getOrganisationTrainers($scope.organisationId);
    }
})();
