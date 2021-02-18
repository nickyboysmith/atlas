(function () {

    'use strict';

    angular
        .module("app")
        .controller("TransferToNewCourseCtrl", TransferToNewCourseCtrl);

    TransferToNewCourseCtrl.$inject = ["$scope", "$filter", "ClientService", "ModalService", "CourseService", "activeUserProfile"];

    function TransferToNewCourseCtrl($scope, $filter, ClientService, ModalService, CourseService, activeUserProfile) {

        $scope.TransferFromCourse = {};
        $scope.availableCourses = [];
        $scope.availableCoursesTemplate = [];
        $scope.noAvailableCourses = true;
        $scope.selectedAvailableCourse = {};
        $scope.transfer = {};
        $scope.transfer.transferNotes = ""; //Notes weren't binding when it was just a property so putting it in to object.
        $scope.transferred = false;
        $scope.errorMessage = "";
        $scope.successMessage = "";
        $scope.maxResults = 5;
        $scope.loading = false;
        $scope.showDORSData = false;
        $scope.clientDORSDataList = [];

        $scope.CoursesAvailable = function (availableCourses) {
            var available = false;
            if (availableCourses.length === 1) {
                // check to make sure the current course that the client is on isn't the only available course.
                if (availableCourses[0].Id !== $scope.TransferFromCourse.Id) {
                    available = true;
                }
            }
            if (availableCourses.length > 1) {
                available = true;
            }
            return available;
        }

        $scope.selectCourse = function (selectedCourse) {
            $scope.selectedAvailableCourse = selectedCourse;
        }

        $scope.TransferToNewCourse = function () {
            ClientService.transferToNewCourse($scope.client.Id, $scope.TransferFromCourse.Id, $scope.selectedAvailableCourse.Id, activeUserProfile.UserId, $scope.transfer.transferNotes)
                .then(
                    function successCallback(response) {
                        if (response.data === true) {
                            $scope.successMessage = "Client transferred successfully";
                            $scope.transferred = true;
                            ModalService.closeCurrentModal("editCourseBookingModal");

                            if (typeof ($scope.loadClientDetails) === 'function') {
                                $scope.loadClientDetails($scope.client.Id);
                            }

                            if (typeof ($scope.$parent.$parent.refreshClients) === 'function') {
                                $scope.$parent.$parent.refreshClients($scope.$parent.$parent.currentCourse.Id);
                            }
                            $scope.refreshNotes($scope.client.Id);
                        }
                        else {
                            $scope.errorMessage = "Client not transferred.  Please contact support.";
                        }
                    },
                    function errorCallback(response) {
                        if (response.data.ExceptionMessage) {
                            $scope.errorMessage = response.data.ExceptionMessage;
                        }
                        else {
                            $scope.errorMessage = response.data.Message;
                        }
                    }
                );
        }

        $scope.cancel = function () {
            ModalService.closeCurrentModal("transferToNewCourseModal");
        }

       
        $scope.loadClientDORSData = function () {
            if ($scope.clientId) {
                ClientService.getClientDORSData($scope.clientId)
                .then(
                    function successCallback(response) {
                        $scope.clientDORSDataList = response.data;
                        if ($scope.clientDORSDataList.length > 0) {
                            //$scope.clientName = $scope.clientDORSDataList[0].ClientDisplayName;
                            if ($scope.clientDORSDataList[0].DORSAttendanceRef === null) {
                                $scope.showDORSData = false;
                                // the client doesn't have a DORS scheme associated with their record so show all the available courses
                                //$scope.loadAvailableCourses();
                            }
                            else {
                                $scope.showDORSData = true;
                            }
                        }
                        $scope.loading = false;
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = response.data;
                        $scope.loading = false;
                    }
                );
            }
        }

        $scope.loadPage = function () {
            if ($scope.clientId === undefined && $scope.$parent.$parent.client) {
                $scope.clientId = $scope.$parent.$parent.client.Id
            }
            $scope.loading = true;
            CourseService.get($scope.currentCourse.Id, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        if (response.data) {
                            $scope.TransferFromCourse = response.data;

                            CourseService.getAvailableCoursesForTransfer(activeUserProfile.selectedOrganisation.Id, activeUserProfile.UserId, $scope.TransferFromCourse.courseTypeId, $scope.TransferFromCourse.courseTypeCategoryId, $scope.TransferFromCourse.courseDorsCourse, $scope.clientId)
                                .then(
                                    function successCallback(response) {
                                        $scope.availableCourses = response.data;

                                        //$scope.availableCourses = $filter('orderBy')($scope.availableCourses, 'courseDateStart');

                                        $scope.availableCoursesTemplate = $scope.availableCourses;
                                        if ($scope.availableCourses.length === 0) {
                                                $scope.noAvailableCourses = true;
                                        }
                                        else {
                                            if ($scope.availableCourses.length === 1) {
                                                if ($scope.availableCourses[0].Id === $scope.TransferFromCourse.Id) {
                                                    $scope.noAvailableCourses = true;
                                                }
                                                else {
                                                    $scope.noAvailableCourses = false;
                                                }
                                            }
                                            else {
                                                $scope.noAvailableCourses = false;
                                            }
                                        }
                                        $scope.loadClientDORSData();
                                        
                                    },
                                    function errorCallback(response) {
                                        $scope.loading = false;
                                    }
                                );
                        }
                    },
                    function errorCallback(response) {
                        $scope.loading = false;
                    }
                );
            

        }

        

        $scope.loadPage();
    };


})();