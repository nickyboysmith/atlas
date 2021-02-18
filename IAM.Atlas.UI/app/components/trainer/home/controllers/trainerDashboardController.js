(function () {

    'use strict';

    angular
        .module("app")
        .controller("TrainerDashboardCtrl", TrainerDashboardCtrl);

    TrainerDashboardCtrl.$inject = ["$scope", "$injector", "activeUserProfile", "TrainerDashboardService", "$interval"];

    function TrainerDashboardCtrl($scope, $injector, activeUserProfile, TrainerDashboardService, $interval) {

        $scope.bookedCourses = {};
        $scope.systemTrainerInformation = {};

        $scope.GetSystemTrainerInformation = function () {

            TrainerDashboardService.getSystemTrainerInformation(activeUserProfile.selectedOrganisation.Id)
            .then(
                function (data) {
                    $scope.systemTrainerInformation = data[0];

                    //$scope.systemTrainerInformation.Content = $scope.systemTrainerInformation.DisplayedMessage
                    //                    + ' Telephone - '
                    //                    + $scope.systemTrainerInformation.AdminContactPhoneNumber
                    //                    + ', Email - '
                    //                    + $scope.systemTrainerInformation.AdminContactEmailAddress
                    //                    + $scope.systemTrainerInformation.OrganisationDisplayedMessage
                    //                    + ' ' + $scope.systemTrainerInformation.OrganisationName
                    //                    + ' Telephone - '
                    //                    + $scope.systemTrainerInformation.OrganisationAdminContactPhoneNumber
                    //                    + ' Email - '
                    //                    + $scope.systemTrainerInformation.OrganisationAdminContactEmailAddress


                },
                function (data) {
                }
            );
        }


        $scope.GetCourseBookings = function () {

            TrainerDashboardService.getCourseBookingsByOrganisationTrainer(activeUserProfile.selectedOrganisation.Id, activeUserProfile.TrainerId)
            .then(
                function (response) {
                    $scope.bookedCourses = response.data;
                },
                function (response) {
                    console.log(response);
                }
            );
        }
       
        // Set up 5 minute refresh rate on page
        var timer = $interval(function () {

            $scope.GetCourseBookings();

        }, 300000); // 1000 = 1 second. 300000 = 5 mins


        $scope.GetSystemTrainerInformation();
        $scope.GetCourseBookings();




        $scope.$on('$destroy', function () { $interval.cancel(timer); });


    }

})();