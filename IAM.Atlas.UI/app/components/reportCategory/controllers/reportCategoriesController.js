(function () {

    'use strict';


    angular
        .module("app")
        .controller("ManageReportCtrl", ManageReportCtrl);

    ManageReportCtrl.$inject = ["$scope", "$filter", "ReportManagementFactory", "ReportCategoryService", "UserService", "activeUserProfile"];

    function ManageReportCtrl($scope, $filter, ReportManagementFactory, ReportCategoryService, UserService, activeUserProfile)
    {


        $scope.reportManagementService = ReportCategoryService;
        $scope.reportManagementFactory = ReportManagementFactory;
        
        $scope.userService = UserService;

        $scope.userId = activeUserProfile.UserId;
        
        $scope.reportCategory = {};
        $scope.reportCategoryDetails = {};

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

        $scope.getReportCategories = function (organisationId) {

            $scope.selectedOrganisation = organisationId;

            $scope.successMessage = "";
            $scope.validationMessage = "";
            
            $scope.reportManagementService.getReportCategories($scope.selectedOrganisation)
                .then(function (data) {

                    $scope.reportCategories = data;

                    if ($scope.reportCategories.length > 0) {

                        $scope.selectedReportCategory = $scope.reportCategories[0];
                        $scope.reportCategoryDetails = angular.copy($scope.selectedReportCategory);
                        $scope.selectedReportCategoryId = $scope.selectedReportCategory.Id;
                    }

                }, function (data) {

                });
           
        };

        $scope.selectReportCategory = function (selectedReportCategory) {

            $scope.successMessage = "";
            $scope.validationMessage = "";
            $scope.selectedReportCategory = selectedReportCategory;
            $scope.reportCategoryDetails = angular.copy(selectedReportCategory);
            $scope.selectedReportCategoryId = selectedReportCategory.Id;
        }

        // Reset Report Category Details
        $scope.addReportCategory = function () {
            $scope.reportCategoryDetails = {};
            $scope.successMessage = "";
            $scope.validationMessage = "";
        };

        // Save the Report Category
        $scope.saveReportCategory = function () {

            if ($scope.validateForm()) {

                if (!angular.equals({}, $scope.reportCategoryDetails)) {

                    $scope.reportCategoryDetails.OrganisationId = $scope.selectedOrganisation;

                    $scope.reportManagementService.saveReportCategory($scope.reportCategoryDetails)

                    .then(function (data) {

                        $scope.getReportCategories($scope.selectedOrganisation);

                        $scope.successMessage = "Report Category Saved Successfully";
                        $scope.validationMessage = "";

                    }, function (data) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An Error Ocurred Saving the Report Category";

                    });

                }
            }
        };


        $scope.closeModal = function () {
            console.log("Close the modal");
        };

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (angular.isUndefined($scope.reportCategoryDetails.Title)) {
                $scope.validationMessage = "Please Enter a Report Category Title. \r ";
            }
            else if ($scope.reportCategoryDetails.Title.length == 0) {
                $scope.validationMessage = "Please Enter a Report Category Title. \r ";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        };

        $scope.getOrganisations($scope.userId);
        $scope.getReportCategories($scope.organisationId);
        
    }

})();