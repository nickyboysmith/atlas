(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('addCourseTypeCtrl', addCourseTypeCtrl);

    addCourseTypeCtrl.$inject = ["$scope", "$http", "$window", "CourseTypeService", "DorsConnectionDetailsService", "UserService"];

    function addCourseTypeCtrl($scope, $http, $window, CourseTypeService, DorsConnectionDetailsService, UserService) {

        $scope.organisationHasDORSConnection = false;
        $scope.courseTypeService = CourseTypeService;
        $scope.DORSSchemes = [];

        $scope.add = {
            courseType: {
                Title: "",
                Code: "",
                Description: "",
                isDORSCourse: false
            }
        };

        if ($scope.organisationId) {
            $scope.courseTypeOrganisationId = $scope.organisationId;
        }
        else {
            $scope.courseTypeOrganisationId = $scope.$parent.selectedOrganisation;
        }

        $scope.loadDORSSchemes = function () {
            DorsConnectionDetailsService.getConnectionDetails($scope.courseTypeOrganisationId)
            .then(
                    function (data) {
                        if (data) {
                            $scope.organisationHasDORSConnection = true;
                            CourseTypeService.getDORSSchemeList($scope.courseTypeOrganisationId)
                                .then(
                                    function (data) {
                                        if (data) {
                                            $scope.DORSSchemes = data;
                                        }
                                        else {
                                            $scope.addValidationMessage = "No DORS Schemes found for this organisation.";
                                        }
                                    },
                                    function (data) {
                                        $scope.addValidationMessage = "Error getting DORS Schemes.";
                                    }
                                );
                        }
                    },
                    function (data) {

                    }
                );

            
        }

        $scope.selectTheDORSScheme = function (DORSSchemeId) {
            $scope.DORSSchemeId = DORSSchemeId;
        }

        $scope.save = function () {


            validateForm();

            if ($scope.addValidationMessage == "") {

                $scope.addObject = {
                    OrganisationId: $scope.courseTypeOrganisationId,
                    Title: $scope.add.courseType.Title,
                    Code: $scope.add.courseType.Code,
                    Description: $scope.add.courseType.Description,
                    DORSCourse: $scope.add.courseType.isDORSCourse,
                    DORSSchemeId: $scope.DORSSchemeId
                };

                $scope.courseTypeService.addCourseType($scope.addObject)
                    .then(function (response) {

                        $scope.addSuccessMessage = "Course Type Saved Successfully.";

                        /**
                         * Refresh the course type collection
                         * On Success
                         */
                        if ($scope.refreshAddNewVenueCourseTypeModal) {
                            $scope.refreshAddNewVenueCourseTypeModal();
                        }

                        if ($scope.selectTheOrganisation) {
                            $scope.selectTheOrganisation($scope.courseTypeOrganisationId);
                        }

                        // Refresh the Course Types in the Course Type Admin page
                        if (angular.isDefined($scope.$parent.getCourseTypesByOrganisation)) {
                            $scope.$parent.getCourseTypesByOrganisation($scope.courseTypeOrganisationId, null);
                        }

                    }, function (response) {

                        $scope.addValidationMessage = "An error occurred please try again.";
                        console.log(response);
                    });
            }
        }

        function validateForm() {

            $scope.addValidationMessage = '';


            if ($scope.add.courseType.Title == "") {
                $scope.addValidationMessage = "Please enter a Course Type title.";
            }

            else if ($scope.add.courseType.Code == "") {
                $scope.addValidationMessage = "Please enter a Course Type code.";
            }
            
        }

        // initialise the page
        $scope.loadDORSSchemes();
    }
})();