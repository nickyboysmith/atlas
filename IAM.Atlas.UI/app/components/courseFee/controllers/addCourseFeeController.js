(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddCourseFeeCtrl', AddCourseFeeCtrl);

    AddCourseFeeCtrl.$inject = ['$scope', '$location', '$window', '$http', 'DateFactory', 'CourseFeeService'];

    function AddCourseFeeCtrl($scope, $location, $window, $http, DateFactory, CourseFeeService) {

        $scope.courseFee = {
            OrganisationId:$scope.organisationId,
            AddedByUserId: $scope.userId,
            CourseTypeId: $scope.selectedCourseType.selectedCourseTypeId,
            CourseTypeCategoryId: $scope.selectedCourseType.selectedCourseTypeCategoryId,
            EffectiveDate: "",
            CourseFee: "",
            BookingSupplement: "",
            PaymentDays : ""
        };

        $scope.displayCalendar = false;

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }


        // New Course Fee Change
        $scope.save = function () {

            $scope.courseFeeService.addCourseFee($scope.courseFee)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
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

})();