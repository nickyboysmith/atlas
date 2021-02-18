(function () {

    'use strict';

    angular
        .module("app")
        .controller("EditCourseBookingCtrl", EditCourseBookingCtrl);

    EditCourseBookingCtrl.$inject = ["$scope", "ClientService", "ModalService"];

    function EditCourseBookingCtrl($scope, ClientService, ModalService) {

        
        $scope.removeFromCourse = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Remove from Course",
                cssClass: "removeFromCourseModal",
                filePath: "/app/components/client/removeFromCourse.html",
                controllerName: "RemoveFromCourseCtrl"
            });
        }

        $scope.transferToNewCourse = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Transfer to new Course",
                cssClass: "transferToNewCourseModal",
                filePath: "/app/components/client/transferToNewCourse.html",
                controllerName: "TransferToNewCourseCtrl"
            });
        }
    };


})();