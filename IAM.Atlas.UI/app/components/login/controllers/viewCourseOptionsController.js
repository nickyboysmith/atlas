(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ViewCourseOptionsCtrl', ViewCourseOptionsCtrl);

    ViewCourseOptionsCtrl.$inject = ['$scope', '$window', "$filter", 'ModalService', 'ViewCourseOptionsService'];

    function ViewCourseOptionsCtrl($scope, $window, $filter, ModalService, ViewCourseOptionsService) {
        $scope.courseOptions = {};
        $scope.selectedDorsSchemeId = 0;
        $scope.selectedDorsSchemeName = "";

        $scope.closeSingleOptionDialog = function () {
            ModalService.closeCurrentModal("viewSingleCourseOptionModal");
        }

        $scope.closeMultipleOptionsDialog = function () {
            ModalService.closeCurrentModal("viewMultipleCourseOptionsModal");
        }

        $scope.showCourseOptions = function () {
            //Get the course options from local storage
            $scope.courseOptions = JSON.parse(sessionStorage.courseOptions);
            $scope.courseOptions = $filter('orderBy')($scope.courseOptions, 'SchemeName');
        }

        $scope.selectDorsCourse = function (dorsSchemeId, dorsSchemeName, dorsForceName, index) {
            $scope.selectedDorsSchemeId = dorsSchemeId;
            $scope.selectedDorsSchemeName = dorsSchemeName;
            $scope.selectedDorsForceName = dorsForceName;
            $scope.selectedDorsIndex = index;
        }

        $scope.selectCourse = function () {
            //Persist the selected DORS data to sessionStorage
            if ($scope.selectedDorsSchemeId == 0) //only have one course so selectDorsCourse() not called and need to set DORS data
            {
                sessionStorage.selectedDORSSchemeId = $scope.courseOptions.SchemeId;
                sessionStorage.selectedDORSSchemeName = $scope.courseOptions.SchemeName;
                sessionStorage.clientDORSData = JSON.stringify($scope.courseOptions);
            } else {                
                sessionStorage.selectedDORSSchemeId = $scope.selectedDorsSchemeId;
                sessionStorage.selectedDORSSchemeName = $scope.selectedDorsSchemeName;
                sessionStorage.clientDORSData = JSON.stringify($scope.courseOptions[$scope.selectedDorsIndex]);
            }

            //If the client came in via an organisation specific URL then allow them to register
            if (sessionStorage.organisationName != "") {
                $window.location.href = "/login/clientregister";
            }
            else {
                //Otherwise allow them to select an organisation that offers the course                
                $window.location.href = "/login/organisationselection";
            }
        }

        $scope.closeDialog = function (modal) {
            ModalService.closeCurrentModal(modal);
        }

        $scope.showCourseOptions();
    }
})();

