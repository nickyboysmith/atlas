(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ClientBookCourseCtrl', ClientBookCourseCtrl);

    ClientBookCourseCtrl.$inject = ['$scope', '$location', '$window', '$http', 'activeUserProfile', 'DorsService', 'DateFactory', 'ClientService'];

    function ClientBookCourseCtrl($scope, $location, $window, $http, activeUserProfile, DorsService, DateFactory, ClientService) {

        $scope.client = {};
        //$scope.schemes = {};
        $scope.licenceNumber = '';
        $scope.clientStatuses;
        $scope.courses = [];

        //$scope.getAvailableSchemes = function(clientStatuses) {
        //    var schemes = [];
        //    for (var i = 0; i < clientStatuses.length; i++)
        //    {
        //        var scheme = { 'Id': clientStatuses[i].SchemeId, 'Name': clientStatuses[i].SchemeName };
        //        var exists = false;
        //        for (var j = 0; j < schemes.length; j++) {
        //            if (schemes[j].Id == scheme.Id && schemes[j].Name == scheme.Name) {
        //                exists = true;
        //            }
        //        }
        //        if (!exists) {
        //            schemes.push(scheme);
        //        }
        //    }
        //    return schemes;
        //}

        $scope.getClientStatuses = function () {

            if ($scope.clientId)
            {
                ClientService.get($scope.clientId)
                    .then(
                        function successCallback(response) {
                            $scope.client = response.data;
                            if ($scope.client.ClientLicence.length > 0) {
                                $scope.licenceNumber = $scope.client.ClientLicence[0].LicenceNumber;
                            }
                            if ($scope.client) {
                                DorsService.getClientStatuses($scope.licenceNumber, activeUserProfile.selectedOrganisation.Id)
                                    .then(
                                        function successCallback(response) {
                                            $scope.clientStatuses = response.data;
                                            //$scope.schemes = $scope.getAvailableSchemes($scope.clientStatuses);
                                        },
                                        function errorCallback(response) {
                                            $scope.validationMessage = response.data.ExceptionMessage;
                                        }
                                    );
                            }
                        },
                        function errorCallback(response) {
                            $scope.validationMessage = response.data.ExceptionMessage;
                        }
                    );
            }
            else
            {
                $scope.validationMessage = "No client selected.";
            }
        }

        $scope.selectClientStatus = function (clientStatus) {
            $scope.selectedClientStatus = clientStatus;
            DorsService.getAvailableCourses(clientStatus.SchemeId, activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.courses = response.data;
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = response.data.ExceptionMessage;
                    }
                );
        }

        $scope.formatDate = function (date) {
            return DateFactory.formatDateddMONyyyy(DateFactory.parseDate(date));
        }

        $scope.bookCourse = function (courseId) {
            DorsService.bookClientOnCourse($scope.selectedClientStatus.AttendanceId, courseId)
                .then(
                    function successCallback(response) {
                        if (response.data == true) {
                            $scope.statusMessage = "Course booked successfully.";
                            if ($scope.getClients) {    // perform a client search to ensure old results aren't misleading
                                $scope.getClients()
                            }
                        }
                        else {
                            $scope.errorMessage = "Course was not booked onto DORS.  Please try again.";
                        }
                    },
                    function errorCallback(response) {
                        if (response.data != null && response.data.Message) {
                            $scope.errorMessage = response.data.Message;
                        }
                        else {
                            $scope.errorMessage = "An error occured please contact support.";
                        }
                    }
                );
        }

        $scope.getClientStatuses();
    }
})();