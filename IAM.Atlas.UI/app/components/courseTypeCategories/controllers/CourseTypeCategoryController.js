(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('CourseTypeCategoryCtrl', CourseTypeCategoryCtrl);

    CourseTypeCategoryCtrl.$inject = ["$scope", "$http", "$window", "ModalService", "CourseTypeCategoryService", "CourseTypeService", "UserService", "activeUserProfile"];

    function CourseTypeCategoryCtrl($scope, $http, $window, ModalService, CourseTypeCategoryService, CourseTypeService, UserService, activeUserProfile) {
        
        $scope.organisations = {};
        $scope.courseTypes = {};
        $scope.courseTypeCategories = {};
        $scope.courseTypeCategoryDetail = {};

        //$scope.selectedOrganisationId = -1;
        //$scope.selectedCourseTypeCategoryId = -1;
        //$scope.selectedCourseTypeId = -1;

        $scope.courseTypeCategoryService = CourseTypeCategoryService;
        $scope.courseTypeService = CourseTypeService;
        $scope.userService = UserService;

        $scope.userId = activeUserProfile.UserId;

        $scope.selectedCourseTypeCategory = {
            selectedOrganisationId: null,
            selectedCourseTypeId: null,
            selectedCourseTypeCategoryId: null
        };


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

            $scope.selectedCourseTypeCategory.selectedOrganisationId = organisationId;

            $scope.courseTypeService.GetCourseTypesByOrganisationId($scope.selectedCourseTypeCategory.selectedOrganisationId)
            .then(
                    function (data) {

                        $scope.courseTypes = data;

                        if ($scope.courseTypes.length > 0) {

                            $scope.selectedCourseTypeCategory.selectedCourseTypeId = $scope.courseTypes[0].Id;

                            $scope.getCourseTypesCategoriesByCourseType($scope.selectedCourseTypeCategory.selectedCourseTypeId)
                        };

                            //if (courseTypeId == null) // first time through, set to first in the collection
                            //{
                            //$scope.selectedCourseTypeDetail = angular.copy($scope.courseTypes[0]);
                            //$scope.selectedCourseTypeDetailId = $scope.courseTypes[0].Id;
                            //}
                            //else // find the course type in the collection and set it
                            //{

                            //    angular.forEach($scope.courseTypeCollection, function (value, key) {

                            //        if (Number(courseTypeId) === value.Id) {
                            //            $scope.selectedCourseTypeDetail = angular.copy(value);
                            //            $scope.selectedCourseTypeDetailId = value.Id;
                            //        }

                            //    });
                            //}

                            //$scope.selectedCourseTypeDetail = angular.copy($scope.courseTypeCollection[0]);
                            //$scope.selectedCourseTypeDetailId = $scope.courseTypeCollection[0].Id;

                            //$scope.selectedCourseType.selectedCourseTypeId = $scope.selectedCourseTypeDetailId;

                            //// get the coursetype categories
                            //$scope.getCourseTypeCategoriesByCourseTypeId($scope.selectedCourseType.selectedCourseTypeId)

                       
                    },
                    function (response) {

                    }
            );
        }

        $scope.getCourseTypesCategoriesByCourseType = function (selectedCourseTypeId) {
           
            $scope.selectedCourseTypeCategory.selectedCourseTypeId = selectedCourseTypeId;

            $scope.courseTypeCategoryService.showCourseTypeCategories($scope.selectedCourseTypeCategory.selectedCourseTypeId, $scope.userId)

                .then(
                        function (data) {

                            $scope.courseTypeCategories = data;

                            if ($scope.courseTypeCategories.length > 0) {

                                $scope.selectedCourseTypeCategory.selectedCourseTypeCategoryId = $scope.courseTypeCategories[0].Id;

                                $scope.setSelectedCourseTypeCategoryDetail($scope.courseTypeCategories[0])
                            }
                            else {


                                $scope.selectedCourseTypeCategoryDetail = {};
                                $scope.selectedCourseTypeCategoryDetailId = null;

                            };


                        },
                        function (data) {

                        }
                    );
        }

        $scope.setSelectedCourseTypeCategoryDetail = function (courseTypeCategory) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.selectedCourseTypeCategoryDetail = angular.copy(courseTypeCategory);
            $scope.selectedCourseTypeCategoryDetailId = courseTypeCategory.Id;

            $scope.selectedCourseTypeCategory.selectedCourseTypeCategoryId = $scope.selectedCourseTypeCategoryDetailId;

            //$scope.getCourseTypeCategoriesByCourseTypeId($scope.selectedCourseType.selectedCourseTypeId)


        }

        //if ($scope.$parent.selectedCourseType) {
        //    $scope.courseTypeId = $scope.$parent.selectedCourseType;
        //    $scope.selectedOrganisationId = $scope.$parent.selectedOrganisation;
        //}
        
        // When the "add new" button is clicked, clear the form inputs.
        //$scope.addNewCourseTypeCategory = function (organisationId) {
        //    // clear the courseTypeCategory name, disabled and id fields but keep the organisation id.
        //    $scope.courseTypeCategoryDetail = { };
        //    $scope.courseTypeCategoryDetail.OrganisationId = organisationId;
        //    $scope.selectedCourseTypeCategoryId = -1;
        //    $scope.showSaveSuccess = false;
        //}

        //$scope.openCourseTypeModal = function () {
        //    $scope.modalService.displayModal({
        //        scope: $scope,
        //        title: "Course Type",
        //        closable: true,
        //        closeByBackdrop: false,
        //        closeByKeyboard: false,
        //        draggable: true,
        //        filePath: "/app/components/coursetype/update.html",
        //        controllerName: "CourseTypeCtrl",
        //        cssClass: "courseTypeModal",
        //        buttons: {
        //            label: 'Close',
        //            cssClass: 'closeModalButton',
        //            action: function (dialogItself) {
        //                dialogItself.close();
        //            }
        //        }
        //    });

        //}

        //$scope.showCourseTypes = function (selectedOrganisationId) {
        //    $scope.selectedOrganisationId = selectedOrganisationId;
        //    $scope.courseTypeService.getCourseTypes(selectedOrganisationId)
        //        .success(function (data, status, headers, config) {
        //            if (data == null) {
        //                //$scope.courseTypes = {};
        //                //$scope.selectedCourseTypeId = -1;
        //                $scope.courseTypeCategories = {};
        //            }
        //            else {
        //                $scope.courseTypes = data;
        //                //$scope.selectedCourseTypeId = -1;
        //                //$scope.courseTypeCategories = {};
        //            }
        //        })
        //        .error(function (data, status, headers, config) {
        //            alert('Error retrieving course types list');
        //        });
        //}

        //Get Organisations function
        //$scope.getOrganisations = function (userId) {

        //    $scope.userService.getOrganisationIds(userId)
        //    .success(function (data) {
        //        $scope.organisations = data;
        //        if ($scope.organisations.length < 2) {
        //            $scope.organisationId = $scope.organisations[0].id;
        //        }
        //    })
        //   .error(function (data) {
        //       console.log("Can't get Organisations");
        //   });
        //}

        
        // has a courseTypeId been passed in via the scope?  If yes lock down the organisation and the courseType drop downs.
        //if ($scope.courseTypeId > 0) {
        //    $scope.passedInCourseTypeId = true;
        //    $scope.selectedCourseTypeId = $scope.courseTypeId;

        //    $scope.courseTypeService.getCourseType($scope.selectedCourseTypeId)
        //        .success(function (data, status, headers, config) {
        //            var courseType = data;
        //            $scope.CourseTypeName = courseType.CourseTypeName;
        //            $scope.OrganisationName = courseType.OrganisationName;
        //            $scope.selectedOrganisationId = courseType.OrganisationId;
        //        });

        //    $scope.courseTypeCategoryService.showCourseTypeCategories($scope.selectedCourseTypeId, $scope.userId)
        //        .then(
        //            function (response) {
        //                $scope.courseTypeCategories = response.data;
        //                $scope.addNewCourseTypeCategory($scope.selectedOrganisationId);
        //            },
        //            function (response) {

        //            }
        //        );


        //    //$scope.showCourseTypeCategories($scope.selectedCourseTypeId);
        //}


        $scope.saveCourseTypeCategory = function () {

            if ($scope.validateForm()) {

                $scope.courseTypeCategoryService.saveCourseTypeCategory($scope.selectedCourseTypeCategoryDetail)
                            .then(
                                function (response) {

                                    //$scope.showCourseTypeCategories($scope.selectedCourseTypeId);
                                    //$scope.showSaveSuccess = true;

                                    //If called from the Course Type Modal, refresh this
                                    //if ($scope.$parent.selectedCourseType) {
                                    //    $scope.$parent.refreshCourseTypeCategories();
                                    //}

                                    $scope.successMessage = "Save Successful";
                                    $scope.validationMessage = "";

                                },
                            function (response) {

                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            })
            };
        }

        /**
       * Open the Add New Course Type
       */
        $scope.addNewCourseTypeCategory = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "New Course Type Category",
                closable: true,
                filePath: "/app/components/CourseTypeCategories/add.html",
                controllerName: "addCourseTypeCategoryCtrl",
                cssClass: "addCourseTypeCategory",
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
            
            if ($scope.selectedCourseTypeCategoryDetail.Name == "") {
                $scope.validationMessage = "Please enter the Course Type Category Name.";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }


        $scope.selectedCourseTypeCategory.selectedOrganisationId = $scope.organisationId;

        $scope.getOrganisations($scope.userId);
        $scope.getCourseTypesByOrganisation($scope.organisationId, null);

    }
})();