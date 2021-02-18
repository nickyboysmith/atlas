(function () {

    'use strict';

    angular
        .module("app")
        .controller("RemoveFromCourseCtrl", RemoveFromCourseCtrl);

    RemoveFromCourseCtrl.$inject = ["$scope", "ClientService", "ModalService", "activeUserProfile"];

    function RemoveFromCourseCtrl($scope, ClientService, ModalService, activeUserProfile) {

        $scope.notes = "";
        $scope.errorMessage = "";
        $scope.removed = false;

        $scope.removeClientFromCourse = function (clientId, courseId, notes) {
            ClientService.removeFromCourse(clientId, courseId, activeUserProfile.UserId, notes)
                .then(
                    function successCallback(response) {
                        if (response.data === false) {
                            $scope.errorMessage = "Couldn't remove client from course please contact support.";
                        }
                        else {
                            $scope.removed = true;
                            ModalService.closeCurrentModal("editCourseBookingModal");
                            var asdsd = typeof ($scope.loadClientDetails);

                            if (typeof ($scope.loadClientDetails) === 'function') {
                                $scope.loadClientDetails($scope.client.Id);
                            }

                            if (typeof ($scope.$parent.$parent.refreshClients) === 'function') {
                                $scope.$parent.$parent.refreshClients(courseId);
                            }

                            if ($scope.refreshNotes && $scope.client.Id) {
                                $scope.refreshNotes($scope.client.Id);  // refresh the notes in the client details page
                            }
                            
                            if ($scope.getClients) {    // perform a client search to ensure old results aren't misleading
                                $scope.getClients()
                            }
                        }
                    },
                    function errorCallback(response) {
                        if (response.data)
                        {
                            if (response.data.ExceptionMessage) {
                                $scope.errorMessage = "An error occurred: " + response.data.ExceptionMessage;
                            }
                            else{
                                $scope.errorMessage = "An error occurred: " + response.data.Message;
                            }
                        }
                        else {
                            $scope.errorMessage = "An error occurred.";
                        }
                    }
                );
        }

        $scope.cancel = function () {
            ModalService.closeCurrentModal("removeFromCourseModal");
        }
    };


})();