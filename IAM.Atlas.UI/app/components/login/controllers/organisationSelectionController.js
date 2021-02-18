(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('OrganisationSelectionCtrl', OrganisationSelectionCtrl);

    OrganisationSelectionCtrl.$inject = ['$scope', '$window', 'ModalService', 'OrganisationSelectionService', 'SystemControlService'];

    function OrganisationSelectionCtrl($scope, $window, ModalService, OrganisationSelectionService, SystemControlService) {
        $scope.contacts = {};
        $scope.systemControl = {};
        $scope.clientWithMultipleCourseOptions = sessionStorage.courseOptions.match(/"SchemeId":/g).length > 1;
        $scope.selectedDORSSchemeName = sessionStorage.selectedDORSSchemeName;

        $scope.showMultipleCourseOptions = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Booking",
                cssClass: "viewMultipleCourseOptionsModal",
                filePath: "/app/components/login/viewMultipleCourseOptions.html",
                controllerName: "ViewCourseOptionsCtrl"
            });
        };

        $scope.registerClient = function (courseOrganisation, courseTypeId, regionId, organisationName, areaName) {
            //Persist the selection organisation
            sessionStorage.organisationId = courseOrganisation;
            sessionStorage.organisationName = organisationName;
            sessionStorage.areaName = areaName;
            sessionStorage.selectedProvider = courseOrganisation;
            sessionStorage.selectedCourseTypeId = courseTypeId;
            sessionStorage.selectedRegionId = regionId;
            $window.location.href = "/login/clientregister";

        }

        $scope.getDORSCourseOrganisations = function () {

            $("#showProcessingSpinner").show();

            OrganisationSelectionService.getDorsOrganisationContactsWithAvailableCourses(sessionStorage.selectedDORSSchemeId)
            .then(
                    function successCallback(response) {
                        $scope.courseTypeOrganisations = response.data;
                        $("#showProcessingSpinner").hide();

                    }
                    ,
                    function errorCallback(response) {
                        $("#showProcessingSpinner").hide();
                    }
                  )
        }

        $scope.getSystemControlSettings = function () {
            SystemControlService.GetClientRegistrationSystemControlData()
                .then(
                    function successCallback(response) {
                        $scope.systemControl.NonAtlasAreaInfo = response.data.NonAtlasAreaInfo;
                        $scope.systemControl.NonAtlasAreaLink = response.data.NonAtlasAreaLink;
                        $scope.systemControl.NonAtlasAreaLinkTitle = response.data.NonAtlasAreaLinkTitle;

                        /* if we don't have a title but do have a link show the link as the title */
                        if (!$scope.systemControl.NonAtlasAreaLinkTitle == true && !$scope.systemControl.NonAtlasAreaLink == false)
                        {
                            $scope.systemControl.NonAtlasAreaLinkTitle = $scope.systemControl.NonAtlasAreaLink;
                        }

                    },
                    function errorCallback(response) {
                    }
                );
        }

        $scope.showRow = function (row) {
            if (row == '' || row == null) {
                return false;
            } else {
                return true;
            }
        }

        $scope.getDORSCourseOrganisations();
        $scope.getSystemControlSettings();
    }
})();

