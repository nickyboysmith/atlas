(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CourseReferenceInterpreterSettingsCtrl', CourseReferenceInterpreterSettingsCtrl);

    CourseReferenceInterpreterSettingsCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "CourseReferenceService"];

    function CourseReferenceInterpreterSettingsCtrl($scope, $location, $window, $http, UserService, activeUserProfile, CourseReferenceService) {

        $scope.courseReferenceService = CourseReferenceService;

        $scope.userId = activeUserProfile.UserId;

        $scope.interpreterSettings = {};

        if (angular.isDefined($scope.$parent.organisationId)) {
            $scope.organisationId = $scope.$parent.organisationId
        }

        //Get Course Reference Interpreter Settings
        $scope.getInterpreterSettings = function (OrganisationId) {

            $scope.courseReferenceService.GetInterpreterSettings(OrganisationId)
                .then(
                    function (data) {
                        $scope.interpreterSettings = data;
                    },
                    function (data) {
                    }
                );
        }

        $scope.clearStartAllReferencesWith = function () {

            if ($scope.interpreterSettings.ReferencesStartWithCourseTypeCode == true) {
                $scope.interpreterSettings.StartAllReferencesWith = "";
            }

        }

        $scope.saveInterpreterSettings = function () {

            $scope.interpreterSettings.UpdatedByUserId = $scope.userId;

            $scope.courseReferenceService.SaveInterpreterSettings($scope.interpreterSettings)
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


        $scope.getInterpreterSettings($scope.organisationId);

    }

})();