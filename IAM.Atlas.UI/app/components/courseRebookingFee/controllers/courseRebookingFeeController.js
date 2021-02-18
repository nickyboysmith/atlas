(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CourseRebookingFeeCtrl', CourseRebookingFeeCtrl);

    CourseRebookingFeeCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'DateFactory', 'CourseTypeCategoryService', 'CourseTypeService', 'CourseRebookingFeeService'];

    function CourseRebookingFeeCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, DateFactory, CourseTypeCategoryService, CourseTypeService, CourseRebookingFeeService) {

        $scope.courseTypeService = CourseTypeService;
        $scope.courseTypeCategoryService = CourseTypeCategoryService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.selectedCourseType = {
            selectedCourseTypeId: "-1",
            selectedCourseTypeTitle: "",
            selectedCourseTypeCategoryId: "-1",
            selectedCourseTypeCategoryName: "",
            selectedCourseRebookingFeeDate: ""
        };

        $scope.courseTypes = {};
        $scope.courseTypeCategories = {};
        $scope.courseRebookingFees = [];

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

                        if ($scope.courseTypes.length > 0) {
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

            //$scope.successMessage = "";
            //$scope.validationMessage = "";

            $scope.selectedCourseType.selectedCourseTypeCategoryId = CourseTypeCategoryId;
            $scope.selectedCourseType.selectedCourseTypeCategoryName = CourseTypeCategoryName;

            CourseRebookingFeeService.getCourseTypeRebookingFee($scope.selectedCourseType.selectedCourseTypeId, $scope.selectedCourseType.selectedCourseTypeCategoryId)
            .then(
                    function (response) {
                        $scope.courseRebookingFees = response.data;

                        if ($scope.courseRebookingFees.length > 0) {
                            
                            $scope.selectedCourseType.selectedCourseRebookingFeeDate = $scope.courseRebookingFees[0].EffectiveDate;
                        }
                        else {
                            $scope.courseRebookingFees = [];
                            $scope.selectedCourseType.selectedCourseRebookingFeeDate = "-1";
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

            if (angular.isDefined($scope.selectedCourseType.selectedCourseRebookingFeeDate)) {

                var today = $filter('date')(new Date(), 'yyyyMMdd');
                var effectiveDate = $filter('date')($scope.selectedCourseType.selectedCourseRebookingFeeDate, 'dd-MMM-yyyy');
                effectiveDate = DateFactory.formatDatedddmmyyyy(effectiveDate);
                
                if (Number(effectiveDate) < Number(today)) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else { return false; }

        };
      

        /**
         * Open the cancel course fee modal
         */
        $scope.openCancelRebookingFeeChangeModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Cancel Course Rebooking Fee Change",
                closable: true,
                filePath: "/app/components/courseRebookingFee/cancel.html",
                controllerName: "CancelCourseRebookingFeeCtrl",
                cssClass: "CancelCourseRebookingFeeModal",
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
        $scope.openAddRebookingFeeChangeModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "New Course Rebooking Fee Change",
                closable: true,
                filePath: "/app/components/courseRebookingFee/add.html",
                controllerName: "AddCourseRebookingFeeCtrl",
                cssClass: "AddCourseRebookingFeeModal",
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
        $scope.saveCourseRebookingFee = function () {

            if ($scope.validateCourseRebookingFee()) {


                $scope.saveRebookingFee = {
                    OrganisationId: $scope.organisationId,
                    AddedByUserId: $scope.userId,
                    CourseTypeId: $scope.selectedCourseType.selectedCourseTypeId,
                    CourseTypeCategoryId: $scope.selectedCourseType.selectedCourseTypeCategoryId,
                    EffectiveDate: $scope.selectedCourseType.selectedCourseRebookingFeeDate,
                    courseRebookingFee: $filter('filter')($scope.courseRebookingFees, { EffectiveDate: $scope.selectedCourseType.selectedCourseRebookingFeeDate })
                    
                };


                CourseRebookingFeeService.save($scope.saveRebookingFee)
                    .then(
                        function (response) {
                            console.log("Success");
                            console.log(response.data);
                            
                            $scope.setSelectedCourseTypeCategory($scope.selectedCourseType.selectedCourseTypeCategoryId, $scope.selectedCourseType.selectedCourseTypeCategoryName)

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


        $scope.SetFirstConditionReadOnly = function (conditionNumber) {

            if (conditionNumber == 1) {
                return true;
            }

        }

        $scope.selectCourseRebookingFeeDate = function (selectedCourseRebookingFeeDate) {

            $scope.selectedCourseType.selectedCourseRebookingFeeDate = selectedCourseRebookingFeeDate;

        }

        $scope.validateCourseRebookingFee = function () {

            $scope.validateDaysBefore = $filter('filter')($scope.courseRebookingFees, { EffectiveDate: $scope.selectedCourseType.selectedCourseRebookingFeeDate })

            var testvalue = -1;
            var exitStatus = true;

            angular.forEach($scope.validateDaysBefore, function (value, key) {

                if (exitStatus) {


                    if (value.IsSelected == true) {
                        if (value.DaysBefore > testvalue) {
                            testvalue = value.DaysBefore
                        }
                        else {
                            $scope.validationMessage = "Days Before value " + value.DaysBefore + " must be greater than the previous value of " + testvalue;
                            exitStatus = false;
                        }
                    }
                }
            });

            return exitStatus;
        }

        
        $scope.getOrganisations($scope.userId);
        $scope.getCourseTypesByOrganisation($scope.organisationId);

    }

})();