(function () {
    'use strict';
    angular
        .module('app')
        .controller('clientAvailableCoursesCtrl', ['$scope', '$filter', 'CourseService', 'activeUserProfile', 'ModalService', 'DateFactory', 'CourseTypeService', 'VenueService', 'ClientService', clientAvailableCoursesCtrl]);

    function clientAvailableCoursesCtrl($scope, $filter, CourseService, activeUserProfile, ModalService, DateFactory, CourseTypeService, VenueService, ClientService) {

        $scope.availableCourses = [];
        $scope.availableCoursesInProgress = [];
        $scope.courseTypes = [];
        $scope.regions = [];
        $scope.venues = [];
        $scope.availableCoursesTemplate = [];
        $scope.maxResults = 10;
        $scope.availableCoursesFilter = 1;
        $scope.selectedCourseTypeId = "-1";
        $scope.selectedVenueId = "-1";
        $scope.selectedRegionId = "-1";
        $scope.loading = false;
        $scope.clientDORSDataList = [];
        $scope.showDORSData = true;
        $scope.selectedCourseId = -1;
        $scope.clientCourses = [];
        $scope.lockCourseTypeDropDownList = false;

        $scope.getFilter = function (filter) {
            var filterAction = "showAll";
            if (filter === 2) {
                filterAction = "interpreter";
            }
            else if (filter === 3) {
                filterAction = "noInterpreter";
            }
            return filterAction;
        }

        $scope.loadAvailableCourses = function () {
            $scope.loading = true;
            if ($scope.clientId) {
                ClientService.getCourseBookings($scope.clientId, activeUserProfile.selectedOrganisation.Id)
                    .then(
                        function successCallback(response) {
                            $scope.clientCourses = response.data;
                            CourseService.getCoursesWithPlaces(activeUserProfile.selectedOrganisation.Id, $scope.selectedCourseTypeId, $scope.selectedRegionId, $scope.selectedVenueId, $scope.getFilter($scope.availableCoursesFilter), $scope.clientId)
                                .then(
                                    function successCallback(response) {
                                        var availableCourses = response.data;
                                        for(var i = 0; i < $scope.clientCourses.length; i++){
                                            availableCourses = $filter('filter')(availableCourses, { CourseId: '!' + $scope.clientCourses[i].CourseId });
                                        }
                                        $scope.availableCoursesInProgress = availableCourses;
                                        ClientService.GetCourseRemovals($scope.clientId, activeUserProfile.selectedOrganisation.Id)
                                            .then(
                                                function successCallback(response) {
                                                    var previousCourses = response.data;
                                                    var availableCourses = $scope.availableCoursesInProgress;
                                                    for (var i = 0; i < previousCourses.length; i++) {
                                                        availableCourses = $filter('filter')(availableCourses, { CourseId: '!' + previousCourses[i].CourseId });
                                                    }
                                                    $scope.availableCourses = availableCourses;

                                                    $scope.availableCourses = $filter('orderBy')($scope.availableCourses, 'StartDate');
                                                    
                                                    $scope.availableCoursesTemplate = $scope.availableCourses;
                                                    $scope.loading = false;
                                                },
                                                function errorCallback(response) {
                                                    $scope.statusMessage = "An error occurred.";
                                                    $scope.loading = false;
                                                }
                                            );
                                        
                                    },
                                    function errorCallback(response) {
                                        $scope.statusMessage = "An error occurred.";
                                        $scope.loading = false;
                                    }
                                );
                        },
                        function errorCallback(response) {
                            $scope.statusMessage = "An error occurred when trying to lookup client's booked courses.";
                            $scope.loading = false;
                        }
                    );
            }
            else {
                $scope.statusMessage = "No client could be found.";
            }
        }

        $scope.loadCourseTypes = function () {
            CourseTypeService.getCourseTypes(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(data) {
                        // only display course types that are not disabled
                        $scope.courseTypes = $filter('filter')(data, { Disabled: false });
                    },
                    function errorCallback(data) {

                    }
                );
        }

        $scope.loadVenues = function () {
            VenueService.getOrganisationVenues(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(data) {
                        if (data) {
                            // filter out the disabled venues
                            $scope.venues = $filter('filter')(data, { Enabled: true });
                        }
                    },
                    function errorCallback(data) {

                    }
                );
        }

        $scope.loadRegions = function () {
            VenueService.getOrganisationRegions(activeUserProfile.selectedOrganisation.Id, activeUserProfile.UserId)
                .then(
                    function successCallback(data) {
                        if (data) {
                            $scope.regions = data;
                        }
                    },
                    function errorCallback(data) {

                    }
                );
        }

        $scope.loadClientDORSData = function () {
            if ($scope.clientId) {
                ClientService.getClientDORSData($scope.clientId)
                .then(
                    function successCallback(response) {
                        $scope.clientDORSDataList = response.data;
                        if ($scope.clientDORSDataList.length > 0) {
                            $scope.clientName = $scope.clientDORSDataList[0].ClientDisplayName;
                            if($scope.clientDORSDataList[0].DORSAttendanceRef === null){
                                $scope.showDORSData = false;
                                // the client doesn't have a DORS scheme associated with their record so show all the available courses
                                $scope.loadAvailableCourses();
                            }
                            else {
                                // let's look up the course type of the client's dorsScheme to filter the results of the available courses.
                                CourseTypeService.getCourseTypeByDORSScheme($scope.clientDORSDataList[0].DORSSchemeId, activeUserProfile.selectedOrganisation.Id)
                                    .then(
                                        function successCallback(response) {
                                            $scope.selectedCourseTypeId = response.Id;
                                            $scope.lockCourseTypeDropDownList = true;
                                            $scope.loadAvailableCourses();
                                        },
                                        function errorCallback(response) {
                                            $scope.statusMessage = "Couldn't determine the course type from the DORS Scheme, showing all available course types.";
                                            $scope.loadAvailableCourses();
                                        }
                                    );
                            }
                        }
                    },
                    function errorCallback(response) {

                    }
                );
            }
        }

        $scope.ifNullZero = function (number) {
            var zeroed = number;
            if (!number) {
                zeroed = 0;
            }
            return zeroed;
        }

        $scope.formatDate = function (date) {

            //return $filter('date')(date, 'dd/mm/yyyy EEEE')

            var formattedDate = DateFactory.formatDateSlashesWithDayOfWeek(DateFactory.parseDate(date));
            return formattedDate;
        }

        $scope.initSelectedCourseTypeId = function () {
            $scope.selectedCourseTypeId = "-1";
        }

        $scope.openCourseModal = function (courseId) {

            $scope.courseId = parseInt(courseId);
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.userId = activeUserProfile.UserId;

            ModalService.displayModal({
                scope: $scope,
                title: "View Course",
                cssClass: "courseViewModal",
                filePath: "/app/components/course/edit.html",
                controllerName: "editCourseCtrl"
            });
        }

        $scope.typeChange = function (typeId) {
            $scope.selectedCourseTypeId = typeId;
            $scope.loadAvailableCourses();
        }

        $scope.venueChange = function (venueId) {
            $scope.selectedVenueId = venueId;
            $scope.loadAvailableCourses();
        }

        $scope.regionChange = function (regionId) {
            $scope.selectedRegionId = regionId;
            $scope.loadAvailableCourses();
        }

        $scope.interpreterRadioChange = function (interpreterValue) {
            $scope.availableCoursesFilter = interpreterValue;
            $scope.loadAvailableCourses();
        }

        $scope.selectCourse = function (courseId) {
            if ($scope.selectedCourseId === courseId) {
                $scope.selectedCourseId = -1;
            }
            else {
                $scope.selectedCourseId = courseId;
            }
        }

        $scope.bookCourse = function () {
            if($scope.selectedCourseId > 0 && $scope.clientId > 0){
                CourseService.book($scope.clientId, $scope.selectedCourseId, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if(response.data === true){
                                $scope.statusMessage = "Course booked.";
                                if (angular.isDefined($scope.loadClientDetails)) {
                                    $scope.loadClientDetails($scope.clientId);
                                }
                                if ($scope.getClients) {    // perform a client search to ensure old results aren't misleading
                                    $scope.getClients()
                                }
                            }
                            else{
                                $scope.statusMessage = "Course not booked.";
                            }
                        },
                        function errorCallback(response) {
                            if (response.data && response.data.ExceptionMessage) {
                                $scope.statusMessage = response.data.ExceptionMessage;
                            }
                            else {
                                $scope.statusMessage = "An error occurred please try again.";
                            }
                        }
                    );
            }
        }

        $scope.RemovedFromCourse = function (courseId) {

        }

        //initialise
        $scope.loadCourseTypes();
        $scope.loadVenues();
        $scope.loadRegions();
        $scope.loadClientDORSData();
    }
}
)();