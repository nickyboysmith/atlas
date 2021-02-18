(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('addVenueCourseTypeCtrl', addVenueCourseTypeCtrl);

    addVenueCourseTypeCtrl.$inject = ["$scope", "$http", "$window", "$filter", "ModalService", "CourseTypeService", "UserService"];

    function addVenueCourseTypeCtrl($scope, $http, $window, $filter, ModalService , CourseTypeService, UserService)
    {


        $scope.venueCourseTypeService = CourseTypeService;

        $scope.modalService = ModalService;

        $scope.venueCourseTypes = {};

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        if ($scope.selectedOrganisation == undefined) {
            $scope.selectedOrganisation = -1;
        }

        $scope.selectVenueCourseType = function (venueCourseTypeId) {
            //if ($scope.selectedVenueCourseType == venueCourseTypeId) {
            //    $scope.selectedVenueCourseType = -1;
            //}
            //else {
            $scope.selectedCourseType = venueCourseTypeId;
            
            //}
        }

        if ($scope.venue.selectedOrganisation != undefined && $scope.venue.id != undefined) {
            $scope.organisationId = Number($scope.venue.selectedOrganisation);

            $scope.venueCourseTypeService.getCourseTypes($scope.organisationId).then(function (response) {
                $scope.venueCourseTypes = response;

                // filter the results, remove the course types from the select list that have already been added. 
                angular.forEach($scope.venue.courseTypes, function (value, key) {
                    $scope.venueCourseTypes = $filter('filter')($scope.venueCourseTypes, { Title: '!' + value.courseTypeName })
                });

                // Does the same as the above, but without the $filter, more efficient ?
                // for (var i = $scope.venueCourseTypes.length - 1; i >= 0; i--) {
                //    angular.forEach($scope.venue.courseTypes, function (value, key) {
                //        if ($scope.venueCourseTypes[i].Title == value.courseTypeName) {
                //            $scope.venueCourseTypes.splice(i, 1);
                //        }
                //    });
                //}

            });

        }

        // used by child modals to refresh this page
        $scope.refreshAddNewVenueCourseTypeModal = function () {

            $scope.venueCourseTypeService.getCourseTypes($scope.organisationId).then(function (response) {
                $scope.venueCourseTypes = response;

                // filter the results, remove the course types from the select list that have already been added. 
                angular.forEach($scope.venue.courseTypes, function (value, key) {
                    $scope.venueCourseTypes = $filter('filter')($scope.venueCourseTypes, { Title: '!' + value.courseTypeName })
                });

            });
         }

        $scope.addNewVenueCourseType = function () {
            $scope.addingCourseType = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "New Course Type",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/CourseType/add.html",
                controllerName: "addCourseTypeCtrl",
                cssClass: "xxxAddCourseType",
                buttons: {
                label: 'Close',
                cssClass: 'closeModalButton',
                action: function (dialogueItself) {
                    dialogueItself.close();
                }
                    }
            });
        }

        $scope.addSelectedVenueCourseType = function () {
           
            $scope.venueCourseTypeService.saveVenueCourseType($scope.selectedVenue, $scope.selectedCourseType)
                .then(function (response) {

                    $scope.showSuccessFader = true;
                    

                    // refresh the venue page, effect of moving the course type on to the venue course type list 
                    $scope.refreshVenueCourseTypeModal();
                    // removes the selected course type from the add list
                    $scope.venueCourseTypes = $filter('filter')($scope.venueCourseTypes, { Id: '!' + $scope.selectedCourseType  })
                
                }, function(response) {
                    $scope.showErrorFader = true;
                    $scope.removeValidationMessage = "An error occurred please try again.";
                });
        }
    }
})();