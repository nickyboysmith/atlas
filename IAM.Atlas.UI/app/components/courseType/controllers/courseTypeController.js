(function () {

    'use strict';


    angular
        .module("app")
        .controller("CourseTypeCtrl", CourseTypeCtrl)

    CourseTypeCtrl.$inject = ["$scope", "$filter", "CourseTypeFactory", "CourseTypeService", "ModalService", "UserService", "activeUserProfile", "CourseTypeCategoryService"];

    function CourseTypeCtrl($scope, $filter, CourseTypeFactory, CourseTypeService, ModalService, UserService, activeUserProfile, CourseTypeCategoryService) {

        $scope.courseTypeService = CourseTypeService;
        $scope.userService = UserService;
        $scope.courseTypeCategoryService = CourseTypeCategoryService;

        $scope.userId = activeUserProfile.UserId;

        $scope.selectedCourseType = {
            selectedOrganisationId: null,
            selectedCourseTypeId: null
        };

        $scope.selectedCourseTypeDetail = {};
        $scope.selectedCourseTypeDetailId = "";

        $scope.courseTypeCategories = {};
        $scope.DORSScheme = {};

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


        // get the Course Types
        $scope.getCourseTypesByOrganisation = function (organisationId, courseTypeId) {

            $scope.selectedCourseType.selectedOrganisationId = organisationId;

            $scope.courseTypeService.GetCourseTypesByOrganisationId($scope.selectedCourseType.selectedOrganisationId)
            .then(
                    function (data) {

                        $scope.courseTypeCollection = data;

                        if ($scope.courseTypeCollection.length > 0) {


                            if (courseTypeId == null) // first time through, set to first in the collection
                            {
                                $scope.selectedCourseTypeDetail = angular.copy($scope.courseTypeCollection[0]);
                                $scope.selectedCourseTypeDetailId = $scope.courseTypeCollection[0].Id;
                            }
                            else // find the course type in the collection and set it
                            { 

                                angular.forEach($scope.courseTypeCollection, function (value, key) {
                                    
                                    if (Number(courseTypeId) === value.Id) {
                                        $scope.selectedCourseTypeDetail = angular.copy(value);
                                        $scope.selectedCourseTypeDetailId = value.Id;
                                    }
                                   
                                });
                            }

                          
                            $scope.selectedCourseType.selectedCourseTypeId = $scope.selectedCourseTypeDetailId;

                            // get the coursetype categories
                            $scope.getCourseTypeCategoriesByCourseTypeId($scope.selectedCourseType.selectedCourseTypeId)

                        }
                    },
                    function (data) {

                    }
            );
        }

        //Get Course Type Categories
        $scope.getCourseTypeCategoriesByCourseTypeId = function (courseTypeId) {

           
            $scope.courseTypeCategories = {};

            $scope.courseTypeCategoryService.showCourseTypeCategories(courseTypeId, $scope.userId)
                .then(
                    function (data) {

                        $scope.courseTypeCategories = data;

                        $scope.DORSScheme = {};

                        $scope.courseTypeService.getDORSScheme(courseTypeId)
                            .then(
                                function (data) {

                                    $scope.DORSScheme = data;

                                },
                                function (data) {

                                }
                            );

                    },
                    function (data) {

                    }
                );

        }

        $scope.setSelectedCourseTypeDetail = function (courseType) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedCourseTypeDetail = angular.copy(courseType);
            $scope.selectedCourseTypeDetailId = courseType.Id;

            $scope.selectedCourseType.selectedCourseTypeId = courseType.Id;

            $scope.getCourseTypeCategoriesByCourseTypeId($scope.selectedCourseType.selectedCourseTypeId)


        }
        

        //$scope.refreshCourseTypeCategories = function () {
        //    $scope.courseTypeCategoryService.showCourseTypeCategories($scope.selectedCourseType, $scope.userId)
        //    .then(
        //            function successCall(response) {
        //                $scope.courseTypeCategories = response.data;
        //            }
        //            ,
        //            function failCall(response) {

        //            }
        //    );
        //}

        /**
         * 
         */
        $scope.saveCourseTypeMaintenance = function () {

            if ($scope.validateForm()) {

                $scope.addObject = {
                    Disabled: $scope.selectedCourseTypeDetail.Disabled,
                    OrganisationId: $scope.selectedCourseType.selectedOrganisationId,
                    CourseTypeId: $scope.selectedCourseType.selectedCourseTypeId,
                    Title: $scope.selectedCourseTypeDetail.Title,
                    Code: $scope.selectedCourseTypeDetail.Code,
                    Description: $scope.selectedCourseTypeDetail.Description,
                    DaysBeforeCourseLastBooking: $scope.selectedCourseTypeDetail.DaysBeforeCourseLastBooking
                };

                /**
                 * Send to the WebAPI
                 */
                $scope.courseTypeService.saveCourseType($scope.addObject)
                    .then(function (response) {

                        $scope.getCourseTypesByOrganisation($scope.selectedCourseType.selectedOrganisationId, $scope.selectedCourseType.selectedCourseTypeId);

                        $scope.successMessage = "Save Successful";
                        $scope.validationMessage = "";
                    }, function (response) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                       
                    });
            };
        };

        /**
        * Open the Add New Course Type
        */
        $scope.addNewCourseType = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "New Course Type",
                closable: true,
                filePath: "/app/components/CourseType/add.html",
                controllerName: "addCourseTypeCtrl",
                cssClass: "addCourseType",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if ($scope.selectedCourseTypeDetail.Title == "") {
                $scope.validationMessage = "Please enter the Course Type Title.";
            }

            if ($scope.selectedCourseTypeDetail.Code == "") {
                $scope.validationMessage = "Please enter the Course Type Code.";
            }
            
            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        /**
         * 
         */
        $scope.closeModal = function () {
            console.log("Close the modal");
        };

        $scope.selectedCourseType.selectedOrganisationId = $scope.organisationId;
        $scope.getOrganisations($scope.userId);
        $scope.getCourseTypesByOrganisation($scope.organisationId, null);
       

    }

})();

