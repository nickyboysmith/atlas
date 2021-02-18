(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CourseFeeCtrl', CourseFeeCtrl);

    CourseFeeCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'DateFactory', 'CourseTypeCategoryService', 'CourseTypeService', 'CourseFeeService'];

    function CourseFeeCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, DateFactory, CourseTypeCategoryService, CourseTypeService, CourseFeeService) {

        $scope.courseFeeService = CourseFeeService;
        $scope.courseTypeService = CourseTypeService;
        $scope.courseTypeCategoryService = CourseTypeCategoryService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.selectedCourseType = {
            selectedCourseTypeId: "-1",
            selectedCourseTypeTitle: "",
            selectedCourseTypeCategoryId: "-1",
            selectedCourseTypeCategoryName: "",
            selectedCourseFeeId: "-1"
        };

        $scope.courseTypes = {};
        $scope.courseTypeCategories = {};
        $scope.courseFees = {};

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }


        //Get Course Types
        $scope.getCourseTypesByOrganisation = function (organisationId) {



            $scope.courseTypes = {};

            $scope.courseTypeService.getCourseTypes(organisationId)
                .then(
                    function (response) {
                        $scope.courseTypes = response;

                        if ($scope.courseTypes.length > 0)
                        {
                            $scope.selectedCourseType.selectedCourseTypeId = $scope.courseTypes[0].Id;
                            $scope.selectedCourseType.selectedCourseTypeTitle = $scope.courseTypes[0].Title;
                            $scope.getCourseTypeCategoriesByOrganisation($scope.selectedCourseType.selectedCourseTypeId, $scope.selectedCourseType.selectedCourseTypeTitle)
                        }
                        

                    },
                    function (response) {
                    }
                );
        }

        //Get Course Category Types
        $scope.getCourseTypeCategoriesByOrganisation = function (CourseTypeId) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.courseTypeCategories = {};

            angular.forEach($scope.courseTypes, function (value, key) {
                if (CourseTypeId == value.Id)
                    $scope.selectedCourseType.selectedCourseTypeTitle = value.Title;
            });
          
            $scope.courseTypeCategoryService.showCourseTypeCategories(CourseTypeId, $scope.userId)
                .then(
                    function (response) {
                        $scope.courseTypeCategories = response;

                        $scope.ALLItem = {
                            Id: null,
                            Name: "*ALL*"
                        };

                        $scope.courseTypeCategories.unshift($scope.ALLItem);

                        if ($scope.courseTypeCategories.length > 0) {
                            $scope.selectedCourseType.selectedCourseTypeCategoryId = $scope.courseTypeCategories[0].Id;
                            $scope.selectedCourseType.selectedCourseTypeCategoryName = $scope.courseTypeCategories[0].Name;
                        }

                        $scope.setSelectedCourseTypeCategory($scope.selectedCourseType.selectedCourseTypeCategoryId, $scope.selectedCourseType.selectedCourseTypeCategoryName)

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        //Get Course Fees
        $scope.setSelectedCourseTypeCategory = function (CourseTypeCategoryId, CourseTypeCategoryName) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedCourseType.selectedCourseTypeCategoryId = CourseTypeCategoryId;
            $scope.selectedCourseType.selectedCourseTypeCategoryName = CourseTypeCategoryName;

            $scope.courseFeeService.getCourseTypeFee($scope.selectedCourseType.selectedCourseTypeId, $scope.selectedCourseType.selectedCourseTypeCategoryId)
            .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.courseFees = response.data;

                        var Id = {
                         Id: 0
                        }

                        $scope.courseFees = $scope.courseFees.map(function (obj) {
                            return angular.extend(obj, Id);
                        });

                        if ($scope.courseFees.length > 0)
                        {
                            var count = 0;
                            angular.forEach($scope.courseFees, function (value, key) {
               
                                value.Id = count;
                                count = count + 1;
                            });

                            $scope.selectedCourseType.selectedCourseFeeId = $scope.courseFees[0].Id;
                        }
                        else {
                            $scope.selectedCourseType.selectedCourseFeeId = "-1";
                        }
                        
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        $scope.isDistantDate = function () {

            
            /*
               If the selected date is in the past disable the remove button 
            */

            if ($scope.selectedCourseType.selectedCourseFeeId == "-1") {
                return false;
            }
            else if (angular.isDefined($scope.courseFees[$scope.selectedCourseType.selectedCourseFeeId].EffectiveDate)) {
                var today = $filter('date')(new Date(), 'yyyyMMdd');
                var effectiveDate = $filter('date')($scope.courseFees[$scope.selectedCourseType.selectedCourseFeeId].EffectiveDate, 'dd-MMM-yyyy');
                effectiveDate = DateFactory.formatDatedddmmyyyy(effectiveDate);

                if (Number(effectiveDate) < Number(today)) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else { return false; }
        }


        /**
         * Open the cancel course fee modal
         */
        $scope.openCancelFeeChangeModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Cancel Course Fee Change",
                closable: true,
                filePath: "/app/components/courseFee/cancel.html",
                controllerName: "CancelCourseFeeCtrl",
                cssClass: "CancelCourseFeeModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        /**
         * Open the add course fee modal
         */
        $scope.openAddFeeChangeModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "New Course Fee Change",
                closable: true,
                filePath: "/app/components/courseFee/add.html",
                controllerName: "AddCourseFeeCtrl",
                cssClass: "AddCourseFeeModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        // Save CourseFee
        $scope.saveCourseFee = function () {

            if ($scope.validateCourseFee()) {

                $scope.courseFeeService.save($scope.courseFees[$scope.selectedCourseType.selectedCourseFeeId])
                    .then(
                        function (response) {
                            console.log("Success");
                            console.log(response.data);
                            $scope.successMessage = "Save Successful";
                            $scope.validationMessage = "";
                        },
                        function (response) {
                            console.log("Error");
                            console.log(response);
                            $scope.successMessage = "";
                            $scope.validationMessage = "An error occurred please try again.";
                        }
                    );
            }
        }


        $scope.validateCourseFee = function () {

            // If empty string or null, (only possible bad value) -  filter with set it to default 0
            //$scope.archiveControl.ArchiveEmailsAfterDaysDefault = $filter('number')($scope.archiveControl.ArchiveEmailsAfterDaysDefault, 0);
            //$scope.archiveControl.ArchiveSMSsAfterDaysDefault = $filter('number')($scope.archiveControl.ArchiveSMSsAfterDaysDefault, 0);
            //$scope.archiveControl.DeleteEmailsAfterDaysDefault = $filter('number')($scope.archiveControl.DeleteEmailsAfterDaysDefault, 0);
            //$scope.archiveControl.DeleteSMSsAfterDaysDefault = $filter('number')($scope.archiveControl.DeleteSMSsAfterDaysDefault, 0);

            return true;
        }

        $scope.getOrganisations($scope.userId);
        $scope.getCourseTypesByOrganisation($scope.organisationId);

    }

})();