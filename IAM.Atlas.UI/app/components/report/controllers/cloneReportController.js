(function () {
    'use strict';

    angular
        .module('app')
        .controller('cloneReportCtrl', ['$scope', '$timeout', '$location', '$window', '$http', 'CloneReportService', 'ModalService', 'activeUserProfile', cloneReportCtrl]);


    function cloneReportCtrl($scope, $timeout, $location, $window, $http, CloneReportService, ModalService, activeUserProfile) {


        $scope.cloneService = CloneReportService;
        $scope.cloneReport = {};
        $scope.sourceReport = {};
        $scope.successMessage = "";

        $scope.cloneExistingReport = function () {
            if ($scope.cloneReport.Title && $scope.cloneReport.Description) {

                $scope.cloneReportData = {};
                $scope.cloneReportData.sourceReportID = $scope.reportId;
                $scope.cloneReportData.userID = activeUserProfile.UserId;
                $scope.cloneReportData.cloneReportTitle = $scope.cloneReport.Title;
                $scope.cloneReportData.cloneReportDescription = $scope.cloneReport.Description;

                $scope.cloneService.cloneSourceReport($scope.cloneReportData)
                    .then(
                        function (response) {
                            //Open Edit Report Modal
                            $scope.editReport(response.data);
                            //...and then close 
                        }
                        ,
                        function () {

                        }
                    )
            }
            else {
                $scope.successMessage = 'Please provide a title and description before cloning';
            }
        }

        //Finalise once edit report user story has been completed
        $scope.editReport = function (reportId) {
            //Check that a description and title have been entered
            $scope.reportId = reportId;
            $scope.configureReport = false;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Edit Report",
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

        //Set up the title and label for the modal box
        $scope.displayDefaults = function () {
            $scope.cloneReport.Title = $scope.reportName + "...cloned";
            $scope.sourceReport.Title = $scope.reportName;
        }

        $scope.displayDefaults();
    }
})();