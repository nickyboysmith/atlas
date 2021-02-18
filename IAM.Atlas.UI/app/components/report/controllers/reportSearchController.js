(function () {
    'use strict';

    angular
        .module('app')
        .controller('reportSearchCtrl', ['$scope', '$timeout', '$location', '$window', '$http', 'reportSearchService', 'UserService', 'activeUserProfile', 'ModalService', reportSearchCtrl]);

    function reportSearchCtrl($scope, $timeout, $location, $window, $http, reportSearchService, UserService, activeUserProfile, ModalService, $route) {
        $scope.organisations = {};
        $scope.reportCategories = {};
        $scope.reports = {};
        $scope.report = {};
        $scope.successMessage = '';

        $scope.selectedOrganisation = {};
        $scope.selectedReportCategory = {};
        $scope.selectedReport = {};

        $scope.reportService = reportSearchService;
        $scope.userService = UserService;
        $scope.modalService = ModalService;
        $scope.userId = activeUserProfile.UserId;
        $scope.isAdmin = false;
        $scope.showCategories = true;


        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (data) {
                    $scope.isAdmin = data;
                    if ($scope.isAdmin === true) {
                        $scope.selectedOrganisation = "" + activeUserProfile.selectedOrganisation.Id;
                        $scope.getReportCategories(activeUserProfile.selectedOrganisation.Id);
                    }
                });
                if ($scope.organisations.length < 2) {
                    $scope.getReportCategories(activeUserProfile.selectedOrganisation.Id);
                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        //Get report categories function
        $scope.getReportCategories = function (orgID) {

            //Clear any error message
            $scope.successMessage = '';

            $scope.reportCategories.length = 0;
            $scope.reports.length = 0;
            $scope.selectedReportCategory.length = 0;

            $scope.reportService.getRelatedReportCategories(orgID)
            .then(function (data) {
                $scope.reportCategories = data;
                $scope.selectedOrganisation = "" + orgID;
            }, function (data) {
                console.log("Can't get Report Categories");
            });
        }        

        //Get the trainers based on the selected Organisation, Category and Course Type
        $scope.getReports = function (reportCategoryID) {
            $scope.successMessage = '';
            if (reportCategoryID === 0) {
                $scope.reportService.getReportsByUser($scope.userId)
                   .then(function (data) {
                       $scope.reports = data;
                       $scope.setSearchMessage($scope.reports.length);
                   }, function (data) {
                       console.log("Can't get Reports");
                   });
            }
            else if (reportCategoryID === -1) {
                $scope.reportService.getReportsByOrganisation($scope.selectedOrganisation)
                   .then(function (data) {
                       $scope.reports = data;
                       $scope.setSearchMessage($scope.reports.length);
                   }, function (data) {
                       console.log("Can't get Reports");
                   });
            }
            else  {
                $scope.reportService.getReportsByCategory(reportCategoryID)
                   .then(function (data) {
                       $scope.reports = data;
                       $scope.setSearchMessage($scope.reports.length);
                   }, function (data) {
                       console.log("Can't get Reports");
                   });
            }            
        };

        $scope.setSearchMessage = function (results) {
            if (results === 0) {
                $scope.successMessage = 'No Results Found';
            }
            else {
                $scope.successMessage = '';
            }
        }

        $scope.refreshReports = function () {
            if ($scope.selectedCourseCategory !== null) {
                $scope.getReports($scope.selectedCourseCategory);
            }
        };

        $scope.selectReport = function (reportID) {
            $scope.successMessage = '';
            $scope.selectedReport = reportID;
        };

        //$scope.showReport = function (reportID) {
        //    $scope.successMessage = '';
        //    $scope.selectedReport = reportID;
        //    $scope.updateReports($scope.selectedReport);
        //};

        //Will work once report adding has been added(!)
        $scope.createReport = function () {
            //Check that an organisation has been selected first
            //if ($scope.selectedOrganisation > 0) {
            //    $scope.modalService.displayModal({
            //        scope: $scope,
            //        title: "Add Report",
            //        cssClass: "reportAddModal",
            //        filePath: "/app/components/report/about/save.html",
            //        controllerName: "reportCtrl",
            //        buttons: {
            //            label: 'Close',
            //            cssClass: 'closeModalButton',
            //            action: function (dialogItself) {
            //                dialogItself.close();
            //            }
            //        }
            //    });
            //}
            //else {
            //    $scope.successMessage = 'Select an Organisation before adding a report.';
            //}

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Report",
                cssClass: "reportAddModal",
                filePath: "/app/components/report/save.html",
                controllerName: "reportCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.createReportCategory = function () {
            //Check that an organisation has been selected first
            if ($scope.selectedOrganisation > 0) {
                $scope.modalService.displayModal({
                    scope: $scope,
                    title: "Report Categories",
                    cssClass: "reportCategoryModal",
                    filePath: "/app/components/reportcategory/manage.html",
                    controllerName: "ManageReportCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });
            }
            else {
                $scope.successMessage = 'Select an Organisation before adding a report.';
            }
        };        

        $scope.showReportParameters = function (reportID) {
            //Open the report parameters modal, passing in the report id

            $scope.report = reportID;
            $scope.isModal = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Run Report",
                cssClass: "reportParametersModal",
                filePath: "/app/components/report/reportparameters.html",
                controllerName: "reportParametersCtrl"
            });
        }

        $scope.getOrganisations($scope.userId);



        /**************************************************************************
        * 
        * Start report list options menu
        * 
        **************************************************************************/

        /**
         * Context menu object  ('Add Client Note', '/app/components/client/addNote.html', 'addClientNoteCtrl', 'true', 'true');
         */
        $scope.reportListOptions = {
            Clone: {
                name: "Clone",
                modalTitle: "Clone Report",
                modalFilePath: "/app/components/report/cloneReport.html",
                modalController: "cloneReportCtrl",
                modalClass: ""
            },
            editDetails: {
                name: "Edit Report",
                modalTitle: "Edit Report",
                modalFilePath: "/app/components/report/save.html",
                modalController: "reportCtrl",
                modalClass: "reportAddModal"
            },
            editConfig: {
                name: "Edit Config",
                modalTitle: "Report Configuration",
                modalFilePath: "/app/components/report/save.html",
                modalController: "reportCtrl",
                modalClass: "reportAddModal"
            },
            editOwnership: {
                name: "Edit Report Owners",
                modalTitle: "Edit Report Owners",
                modalFilePath: "/app/components/report/reportOwners.html",
                modalController: "reportOwnersCtrl",
                modalClass: "editReportOwners"
            }
        }

        /**
         * Open a modal from the content menu
         */
        $scope.openModalFromContextMenu = function (reportOption, reportID, reportName) {
            $scope.reportId = reportID;
            $scope.reportName = reportName;
            $scope.reportOrganisationId = $scope.selectedOrganisation;

            if(reportOption.name === "Edit Config"){
                $scope.configureReport = true;
            }
            else {
                $scope.configureReport = false;
            }

            $scope.modalService.displayModal({
                scope: $scope,
                title: reportOption.modalTitle,
                cssClass: reportOption.modalClass,
                filePath: reportOption.modalFilePath,
                controllerName: reportOption.modalController,
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
         * Open the report menu
         */
        $scope.openReportMenu = function (reportID, reportName, $event) {
           
            /**
             * Check position of the mouse click and 
             * how far down the page it is 
             * Percent wise
             */
            $scope.clickRawPercentage = $event.clientY / $(window).height();
            $scope.clickPercent = $scope.clickRawPercentage.toFixed(2);
            /**
             * Check to see if the context menu is going over the page
             */
            var yAdjustment = -20;
            if ($scope.clickPercent > 0.75) {
                yAdjustment = 180;
            }
            /**
             * Set the position of the context menu
             */
            $scope.hiddenMenuTop = ($event.target.offsetTop - yAdjustment) + "px";
            $scope.hiddenMenuLeft = 60 + "px";
            
            /**
             * Create object to pass to Ng Style
             */
            $scope.menuStyle = {
                top: $scope.hiddenMenuTop,
                left: $scope.hiddenMenuLeft
            };
            
            /**
             * Set the report name
             */
            $scope.theReportName = reportName;

            /**
             * Set the report ID
             */
            $scope.theReportID = reportID;

            /**
             * Set the menu to true so it can be displayed
             */
            $scope.reportHiddenMenuVisible = true;

        };
        /**************************************************************************
         * 
         * End Report list options
         * 
         **************************************************************************/
        $scope.setHiddenMenuVisible = function () {
            $scope.reportHiddenMenuVisible = false;
        }



        $scope.addToMenuFavourite = function () {

            var menuFavourouriteParams = {
                UserId: $scope.$parent.userId,
                Title: "add course",
                Link: "app/components/course/add.html",
                Parameters: "addCourseCtrl",
                Modal: "True",

            };
            $scope.$emit('savemenufavourite', menuFavourouriteParams);
        }
    }
})();