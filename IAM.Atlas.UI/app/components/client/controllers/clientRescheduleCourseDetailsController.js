(function () {

    'use strict';

    angular
        .module("app")
        .controller("clientRescheduleCourseDetailsCtrl", clientRescheduleCourseDetailsCtrl);

    clientRescheduleCourseDetailsCtrl.$inject = ["$scope", "activeUserProfile", "ShowVenueAddressService", "DateFactory", "ModalService", "ClientService"];

    function clientRescheduleCourseDetailsCtrl($scope, activeUserProfile, ShowVenueAddressService, DateFactory, ModalService, ClientService) {
        
        $scope.courseSelected.ErrorMessage = ''
        $scope.courseSelected.ClientId = activeUserProfile.ClientId;
        $scope.courseSelected = $scope.$parent.courseSelected;

        //course type will alwys be the samne as the current course selected
        $scope.courseSelected.CourseType = $scope.$parent.currentCourses[$scope.$parent.clientCourseSelection.index].CourseType

        /**
         * Get the address
         * From the venue Id
         */
        ShowVenueAddressService.getAddress($scope.courseSelected.VenueId)
        .then(
            function (response) {
                var venueDetails = response.data[0];
                $scope.courseSelected.venueAddress = venueDetails.Address + "\r\n" + venueDetails.PostCode;

            });

        $scope.confirmReschedule = function (course) {

            $scope.courseSelected = $scope.$parent.courseSelected;
            $scope.courseSelected.ClientId = activeUserProfile.ClientId;
            $scope.courseSelected.ErrorMessage = '';

            ClientService.courseClientTransferRequest($scope.courseSelected)
            .then(
                function successCallback(response) {
                    if (response.data == true) {
                        ModalService.displayModal({
                            scope: $scope,
                            title: "Rescheduled Course Confirm",
                            cssClass: "clientRescheduleCourseConfirmModal",
                            filePath: "/app/components/client/clientRescheduleCourseConfirm.html",
                            controllerName: "clientRescheduleCourseConfirmCtrl",

                        });
                        $('button.close').last().trigger('click');
                    }
                    else {
                        $scope.courseSelected.ErrorMessage = "Failed to reschedule the course. Please try again and if the problem persists please contact the administratror"
                    }
                },
                function errorCallback(reason) {
                    $scope.courseSelected.ErrorMessage = "Failed to reschedule the course. Please try again and if the problem persists please contact the administratror"
                }
            );

        };

    }

})();