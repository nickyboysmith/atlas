(function () {
    'use strict';
    angular
        .module('app')
        .controller('AvailableCoursesCtrl', ['$scope', '$filter', 'CourseService', 'activeUserProfile', 'ModalService', 'DateFactory', 'CourseTypeService', 'VenueService', AvailableCoursesCtrl]);

    function AvailableCoursesCtrl($scope, $filter, CourseService, activeUserProfile, ModalService, DateFactory, CourseTypeService, VenueService) {

        $scope.availableCourses = [];
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

        $scope.getFilter = function (filter) {
            var filterAction = "showAll";
            if (filter === 2) {
                filterAction = "interpreter";
            }
            else if(filter === 3){
                filterAction = "noInterpreter";
            }
            return filterAction;
        }

        $scope.loadAvailableCourses = function () {
            $scope.loading = true;
            // TODO - "-1" for ClientId  - expected parameter for CourseService.getCoursesWithPlaces
            CourseService.getCoursesWithPlaces(activeUserProfile.selectedOrganisation.Id, $scope.selectedCourseTypeId, $scope.selectedRegionId, $scope.selectedVenueId, $scope.getFilter($scope.availableCoursesFilter), "-1")
            //CourseService.getCoursesWithPlaces(activeUserProfile.selectedOrganisation.Id, $scope.selectedCourseTypeId, $scope.selectedRegionId, $scope.selectedVenueId, $scope.getFilter($scope.availableCoursesFilter))
                .then(
                    function successCallback(response) {
                        $scope.availableCourses = response.data;
                        $scope.availableCoursesTemplate = $scope.availableCourses;
                        $scope.loading = false;
                    },
                    function errorCallback(response) {
                        $scope.statusMessage = "An error occurred when trying to lookup client's booked courses.";
                        $scope.loading = false;
                    }
                );
        }

        $scope.loadCourseTypes = function () {
            CourseTypeService.getCourseTypes(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(data) {
                        // only display course types that are not disabled
                        $scope.courseTypes = $filter('filter')(data, {Disabled: false});
                    },
                    function errorCallback(response) {
                        return false;
                    }
                );
        }

        $scope.loadVenues = function () {
            VenueService.getOrganisationVenues(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(data) {
                        if (data) {
                            // filter out the disabled venues
                            $scope.venues = $filter('filter')(data, {Enabled: true});
                        }
                    },
                    function errorCallback(response) {
                        return false;
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
                    function errorCallback(response) {
                        return false;
                    }
                );
        }

        $scope.ifNullZero = function (number) {
            var zeroed = number;
            if (!number) {
                zeroed = 0;
            }
            return zeroed;
        }

        $scope.formatDate = function (date) {
            var formattedDate = DateFactory.formatDateSlashes(DateFactory.parseDate(date));
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

        //initialise

        $scope.loadCourseTypes();
        $scope.loadVenues();
        $scope.loadRegions();
        $scope.loadAvailableCourses();
    }
}
)();