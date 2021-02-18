(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CancelCourseRebookingFeeCtrl', CancelCourseRebookingFeeCtrl);

    CancelCourseRebookingFeeCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'CourseRebookingFeeService'];

    function CancelCourseRebookingFeeCtrl($scope, $location, $window, $http, $filter, CourseRebookingFeeService) {


        $scope.cancelCourseRebookingFees = $filter('filter')($scope.courseRebookingFees, { EffectiveDate: $scope.selectedCourseType.selectedCourseRebookingFeeDate });
        $scope.cancelCourseRebookingFeeDate = $scope.selectedCourseType.selectedCourseRebookingFeeDate
       
        // Cancel Course Rebooking Fee Change
        $scope.cancelCourseRebookingFee = function () {


            $scope.cancelRebookingFee = {
                OrganisationId: $scope.organisationId,
                courseRebookingFee: $filter('filter')($scope.courseRebookingFees, { EffectiveDate: $scope.cancelCourseRebookingFeeDate }),
                UserId: $scope.userId
            };

            CourseRebookingFeeService.cancelCourseRebookingFee($scope.cancelRebookingFee)
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