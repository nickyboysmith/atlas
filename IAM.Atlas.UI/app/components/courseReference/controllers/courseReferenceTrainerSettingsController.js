(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CourseReferenceTrainerSettingsCtrl', CourseReferenceTrainerSettingsCtrl);

    CourseReferenceTrainerSettingsCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "CourseReferenceService"];

    function CourseReferenceTrainerSettingsCtrl($scope, $location, $window, $http, UserService, activeUserProfile, CourseReferenceService) {

        $scope.courseReferenceService = CourseReferenceService;

        $scope.userId = activeUserProfile.UserId;
        
        $scope.trainerSettings = {};

        if (angular.isDefined($scope.$parent.organisationId))
        {   
            $scope.organisationId = $scope.$parent.organisationId
        }

        //Get Course Reference Trainer Settings
        $scope.getTrainerSettings = function (OrganisationId) {

            $scope.courseReferenceService.GetTrainerSettings(OrganisationId)
                .then(
                    function (data) {
                        $scope.trainerSettings = data;
                    },
                    function (data) {
                    }
                );
        }

        $scope.clearStartAllReferencesWith = function () {

            if ($scope.trainerSettings.ReferencesStartWithCourseTypeCode == true) {
                $scope.trainerSettings.StartAllReferencesWith = "";
            }

        }

        $scope.saveTrainerSettings = function () {
            
            $scope.trainerSettings.UpdatedByUserId = $scope.userId;
                    
            $scope.courseReferenceService.SaveTrainerSettings($scope.trainerSettings)
                        .then(
                            function (response) {
                              
                                $scope.updateSuccessMessage = "Save Successful";
                                $scope.updateValidationMessage = "";
                            },
                            function (response) {
                                
                                $scope.updateSuccessMessage = "";
                                $scope.updateValidationMessage = "An error occurred please try again.";
                            }
                        );
           
        }


        $scope.getTrainerSettings($scope.organisationId);

    }

})();