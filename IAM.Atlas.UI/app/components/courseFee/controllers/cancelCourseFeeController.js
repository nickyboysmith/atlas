(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CancelCourseFeeCtrl', CancelCourseFeeCtrl);

    CancelCourseFeeCtrl.$inject = ['$scope', '$location', '$window', '$http', 'CourseFeeService'];

    function CancelCourseFeeCtrl($scope, $location, $window, $http, CourseFeeService) {

    // Cancel Course Fee Change
        $scope.cancelCourseFee = function () {


        $scope.cancelFee = {
            CourseTypeFeeId: $scope.courseFees[$scope.selectedCourseType.selectedCourseFeeId].CourseTypeFeeId,
            CourseTypeCategoryFeeId: $scope.courseFees[$scope.selectedCourseType.selectedCourseFeeId].CourseTypeCategoryFeeId,
            UserId: $scope.userId
        };

        $scope.courseFeeService.cancelCourseFee($scope.cancelFee)
            .then(
                function (response) {
                    console.log("Success");
                    console.log(response.data);
                    $scope.cancelSuccessMessage = "Save Successful";
                    $scope.cancelValidationMessage = "";

                    $scope.$parent.setSelectedCourseTypeCategory($scope.selectedCourseType.selectedCourseTypeCategoryId, $scope.selectedCourseType.selectedCourseTypeCategoryName)
                },
                function (response) {
                    console.log("Error");
                    console.log(response);
                    $scope.cancelSuccessMessage = "";
                    $scope.cancelValidationMessage = "An error occurred please try again.";
                }
            );
        
        }
    }


})();