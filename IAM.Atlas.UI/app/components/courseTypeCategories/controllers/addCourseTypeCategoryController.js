(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('addCourseTypeCategoryCtrl', addCourseTypeCategoryCtrl);

    addCourseTypeCategoryCtrl.$inject = ["$scope", "$http", "$window", "CourseTypeCategoryService", "UserService"];

    function addCourseTypeCategoryCtrl($scope, $http, $window, CourseTypeCategoryService, UserService) {

       
        $scope.courseTypeCategoryService = CourseTypeCategoryService;
        
        $scope.add = {
            courseTypeCategory: {
                Name: "",
                DaysBeforeCourseLastBooking: ""
            }
        };

        //if ($scope.organisationId) {
        //    $scope.courseTypeOrganisationId = $scope.organisationId;
        //}
        //else {
        //    $scope.courseTypeOrganisationId = $scope.$parent.selectedOrganisation;
        //}

        if ($scope.selectedCourseTypeCategory.selectedCourseTypeId) {
            $scope.courseTypeCategoryId = $scope.selectedCourseTypeCategory.selectedCourseTypeId;
        }

        if ($scope.selectedCourseTypeCategory.selectedOrganisationId) {
            $scope.courseTypeOrganisationId = $scope.selectedCourseTypeCategory.selectedOrganisationId;
        }
        //else {
        //    $scope.courseTypeOrganisationId = $scope.$parent.selectedOrganisation;
        //}


        $scope.save = function () {


            validateForm();

            if ($scope.addValidationMessage == "") {

                $scope.addObject = {
                    CourseTypeId: $scope.courseTypeCategoryId,
                    Name: $scope.add.courseTypeCategory.Name,
                    DaysBeforeCourseLastBooking: $scope.add.courseTypeCategory.DaysBeforeCourseLastBooking
                   
                };

               
                $scope.courseTypeCategoryService.addCourseTypeCategory($scope.addObject)
                    .then(
                        function (response) {

                            $scope.addSuccessMessage = "Course Type Category Saved Successfully.";

                            /**
                             * Refresh the course type collection
                             * On Success
                             */
                            if ($scope.refreshAddNewVenueCourseTypeModal) {
                                $scope.refreshAddNewVenueCourseTypeModal();
                            }

                            // Refresh the Course Types in the Course Type Category Admin page
                            if (angular.isDefined($scope.$parent.getCourseTypesByOrganisation)) {
                                $scope.$parent.getCourseTypesByOrganisation($scope.courseTypeOrganisationId, $scope.courseTypeCategoryId);
                            }

                        },
                        function (response) {

                            $scope.addValidationMessage = "An error occurred please try again.";
                            console.log(response);
                        }
                   );
            }
        }

        function validateForm() {

            $scope.addValidationMessage = '';

            if ($scope.add.courseTypeCategory.Name == "") {
                $scope.addValidationMessage = "Please enter the Course Type Category Name.";
            }
        }
    }
})();