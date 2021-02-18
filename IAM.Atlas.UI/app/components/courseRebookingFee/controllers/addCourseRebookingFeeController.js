(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddCourseRebookingFeeCtrl', AddCourseRebookingFeeCtrl);

    AddCourseRebookingFeeCtrl.$inject = ['$scope', '$location', '$window', '$http', 'DateFactory', 'CourseRebookingFeeService'];

    function AddCourseRebookingFeeCtrl($scope, $location, $window, $http, DateFactory, CourseRebookingFeeService) {

        $scope.courseRebookingFees = {
            OrganisationId: $scope.organisationId,
            AddedByUserId: $scope.userId,
            CourseTypeId: $scope.selectedCourseType.selectedCourseTypeId,
            CourseTypeCategoryId: $scope.selectedCourseType.selectedCourseTypeCategoryId,
            EffectiveDate: $scope.EffectiveDate,
            courseRebookingFee: [{
                Condition: "1",
                IsSelected: true,
                DaysBefore: "",
                CourseRebookingFee: ""
            },
            {
                Condition: "2",
                IsSelected: false,
                DaysBefore: "",
                CourseRebookingFee: ""
            },
            {
                Condition: "3",
                IsSelected: false,
                DaysBefore: "",
                CourseRebookingFee: ""
            },
            {
                Condition: "4",
                IsSelected: false,
                DaysBefore: "",
                CourseRebookingFee: ""
            },
            {
                Condition: "5",
                IsSelected: false,
                DaysBefore: "",
                CourseRebookingFee: ""
            }]
        };

        $scope.displayCalendar = false;

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }

        $scope.SetFirstConditionReadOnly = function (conditionNumber) {

            if (conditionNumber == 1) {
                return true;
            }

        }

        // New Course Fee Change
        $scope.save = function () {

            if ($scope.validateEffectiveDate()) {

                if ($scope.validateCourseRebookingFee()) {

                    CourseRebookingFeeService.save($scope.courseRebookingFees)
                        .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);

                                // refresh the course Rebookings.
                                $scope.$parent.setSelectedCourseTypeCategory($scope.$parent.selectedCourseType.selectedCourseTypeCategoryId, $scope.$parent.selectedCourseType.selectedCourseTypeCategoryName, false)

                                $scope.addSuccessMessage = "Save Successful";
                                $scope.addValidationMessage = "";
                            },
                            function (response) {
                                console.log("Error");
                                console.log(response);
                                $scope.addSuccessMessage = "";
                                $scope.addValidationMessage = "An error occurred please try again.";
                            }
                        );
                }
            }
        }


        $scope.validateEffectiveDate = function () {

            if (angular.isDefined($scope.courseRebookingFees.EffectiveDate))
            {
                return true;
            }
            else {

                $scope.addValidationMessage = "Please select an Effective Date";
                return false;
            }
        }



        $scope.validateCourseRebookingFee = function () {

            //$scope.validateDaysBefore = $filter('filter')($scope.courseRebookingFees, { EffectiveDate: $scope.selectedCourseRebookingFeeDate })

            var testvalue = -1;
            var exitStatus = true;

            angular.forEach($scope.courseRebookingFees.courseRebookingFee, function (value, key) {

                if (exitStatus) {


                    if (value.IsSelected == true) {
                        if (Number(value.DaysBefore) > testvalue) {
                            testvalue = Number(value.DaysBefore)
                        }
                        else {
                            $scope.addValidationMessage = "Days Before value " + value.DaysBefore + " must be greater than the previous value of " + testvalue;
                            exitStatus = false;
                        }
                    }
                }
            });

            return exitStatus;
        }

    }

})();