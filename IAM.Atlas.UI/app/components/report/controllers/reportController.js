angular
        .module('app')
        .controller('reportCtrl', ['$scope', 'reportService', 'UserService', 'activeUserProfile', 'ModalService', reportCtrl]);

function reportCtrl($scope, reportService, UserService, activeUserProfile, ModalService) {

    $scope.organisations = {};
    $scope.reportCategories = {};
    $scope.chartColumns = {};
    $scope.reportColumns = [];
    $scope.report = {};
    $scope.report.columnOrder = {};
    $scope.report.columnSortByOrder = {};

    $scope.report.selectedReportCategory = '';
    $scope.report.selectedDataSource = '';
    
    $scope.successMessage = '';
    $scope.validationMessage = '';

    $scope.chartSelection = [];
    $scope.reportSelection = [];
    $scope.selectedOrganisation = {};
    $scope.selectedChartType = {};

    $scope.reportService = reportService;
    $scope.userService = UserService;
    $scope.modalService = ModalService;
    $scope.userId = activeUserProfile.UserId;
    $scope.isAdmin = activeUserProfile.IsSystemAdmin;

    //Get Organisations function
    $scope.getOrganisations = function (userID) {
        if ($scope.isAdmin) {
            $scope.userService.getOrganisationIds(userID)
        .then(
        function (response) {
            $scope.organisations = response;
            $scope.report.selectedOrganisation = "" + activeUserProfile.selectedOrganisation.Id;
            $scope.getReportCategories(activeUserProfile.selectedOrganisation.Id);
        },
        function (response) {
            console.log("Can't get Organisations");
        });
        }
        else {
            $scope.report.selectedOrganisation = activeUserProfile.selectedOrganisation.Id;
            $scope.getReportCategories(activeUserProfile.selectedOrganisation.Id);
        }
    }

    //Get report categories function
    $scope.getReportCategories = function (orgID) {

        $scope.clearMessages();

        $scope.reportCategories.length = 0;

        $scope.reportService.getRelatedReportCategories(orgID)
        .then(
        function (response) {
            $scope.reportCategories = response.data;

            $scope.report.selectedReportCategory = '-1';

            //if ($scope.reportCategories.length > 0) {
               
            //    $scope.report.selectedReportCategory = $scope.reportCategories[0];
            //}

            $scope.selectedOrganisation = orgID;
        },
        function (data) {
            console.log("Can't get Report Categories");
        });
    }

    $scope.getReportCategoriesAndSelect = function (orgId, categoryId) {

        $scope.clearMessages();

        $scope.reportCategories.length = 0;

        $scope.reportService.getRelatedReportCategories(orgId)
        .then(
            function (response) {
                $scope.reportCategories = response.data;
                $scope.selectedOrganisation = orgId;
                if ($scope.reportCategories.indexOf(categoryId) > -1)
                {
                    $scope.report.selectedReportCategory = categoryId;
                }
            },
            function (data) {
                console.log("Can't get Report Categories");
            }
        );
    }

    //Get report data sources
    $scope.getDataSources = function () {

        $scope.clearMessages();

        $scope.reportService.getReportDataSources()
        .then(
        function (response) {
            $scope.dataSources = response.data;

            if ($scope.dataSources.length > 0) {

                $scope.report.selectedDataSource = $scope.dataSources[0].Id.toString();

                $scope.dataViewChanged($scope.report.selectedDataSource);
            }


        },
        function (data) {
            console.log("Can't get Data Sources");
        });
    }

    $scope.dataViewChanged = function (dataViewId)
    {
        $scope.reportSelection = [];
        $scope.chartSelection =[];
        $scope.getDataColumns(dataViewId);
    }

    $scope.findElement = function (array, id) {
        var element;
        for (var i = 0 ; i < array.length; i++) {
            if (array[i].Id) {
                if (array[i].Id == id) {
                    element = array[i];
                    break;
                }
            }
        }
        return element;
    }

    $scope.sortByDisplayOrder = function (a, b) {
        if (a.DisplayOrder && b.DisplayOrder) {
            return a.DisplayOrder - b.DisplayOrder;
        }
        else {
            return -1;
        }
    }

    $scope.sortDataColumns = function () {
        $scope.reportService.getReportDataColumnsWithSortOrder($scope.report.Id)
        .then(
            function (response) {
                var sortByColumnsOrder = response.data.slice().sort(function (a, b) { return a.SortOrder - b.SortOrder });
                var displayOrder = response.data.slice().sort(function (a, b) { return a.DisplayOrder - b.DisplayOrder });
                if ($scope.reportColumns) {
                    for (var i = 0; i < $scope.reportColumns.length; i++) {
                        var sortByExists = false;
                        var displayExists = false;
                        for (var j = 0; j < sortByColumnsOrder.length; j++) {
                            if ($scope.reportColumns[i].Id == sortByColumnsOrder[j].Id) {
                                sortByExists = true;
                                break;
                            }
                        }
                        if (!sortByExists) {
                            sortByColumnsOrder.push($scope.reportColumns[i]);
                        }
                        for (var k = 0; k < displayOrder.length; k++) {
                            if ($scope.reportColumns[i].Id == displayOrder[k].Id) {
                                displayExists = true;
                                break;
                            }
                        }
                        if (!displayExists) {
                            displayOrder.push($scope.reportColumns[i]);
                        }
                    }
                }
                //$scope.report.columnOrder = 
                //$scope.report.columnSortByOrder = $scope.reportColumns.slice().sort(function (a, b) { return a.SortOrder -b.SortOrder            });
                $scope.report.columnSortByOrder = sortByColumnsOrder;
                $scope.report.columnOrder = displayOrder;
            },
            function (data) {
                console.log("Can't get Data Source Columns");
            }
        );
    }

    //Get report data source columns for the report and graph
    $scope.getDataColumns = function (dataViewId) {

        $scope.clearMessages();

        $scope.reportService.getReportDataColumns(dataViewId)
        .then(
            function (response) {
                $scope.chartColumns = response.data;
                $scope.reportColumns = response.data;

                //filter: { hidden: false }
                // Setup Hidden Organisation and Name Property
                angular.forEach($scope.reportColumns, function (value, key) {
                    
                    if (value.Name == 'OrganisationId' || value.Name =='OrganisationName') {
                        value.IsHidden = true;
                    }
                    else {
                        value.IsHidden = false;
                    }
                        
                    
                });

                //$scope.report.columnOrder = $scope.reportColumns.slice().sort(function(a, b) {return a.DisplayOrder - b.DisplayOrder});
                //$scope.report.columnSortByOrder = $scope.reportColumns.slice().sort(function (a, b) { return a.SortOrder - b.SortOrder });
                if($scope.report.Id){
                    $scope.sortDataColumns();
                }
            },
            function (data) {
                console.log("Can't get Data Source Columns");
            }
        );
    }

    //Toggle Chart Column ids
    $scope.toggleChartColumnsTickbox = function (id) {

        //Add id if not present
        if ($scope.chartSelection.indexOf(id) == -1) {
            $scope.chartSelection.push(id);
        }
        else {
            //Delete if present
            delete $scope.chartSelection[$scope.chartSelection.indexOf(id)];
        }
    }

    //Toggle Report Column ids
    $scope.toggleReportColumnsTickbox = function (id) {
        //Add id if not present
        if ($scope.reportSelection.indexOf(id) == -1)
        {
            $scope.reportSelection.push(id);
        }
        else {
            //Delete if present
            delete $scope.reportSelection[$scope.reportSelection.indexOf(id)];
        }
    }

    $scope.isReportColumnChecked = function (id) {
        var checked = false;
        if ($scope.reportSelection.indexOf(id) > -1)
        {
            checked = true;
        }
        return checked;
    }

    $scope.isChartColumnChecked = function (id) {
        var checked = false;
        if ($scope.chartSelection.indexOf(id) > -1) {
            checked = true;
        }
        return checked;
    }

    $scope.editReportOwners = function () {

        $scope.clearMessages();

        $scope.organisationId = $scope.report.selectedOrganisation;
        $scope.reportId = $scope.report.Id;
        $scope.editingReport = true;

        if ($scope.organisationId && $scope.reportId) {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Edit Report Owners",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/report/reportOwners.html",
                controllerName: "reportOwnersCtrl",
                cssClass: "reportOwnersModal",
                onhide: function (dialogRef) {
                    $scope.editingReport = false;
                }
            });
        }
        else {
            $scope.validationMessage = 'Please select an organisation.';
        }
    }

    $scope.loadReport = function (reportId) {
        var report = $scope.reportService.get(reportId)
                            .then(
                                function successCallback(response) {
                                    // this callback will be called asynchronously
                                    // when the response is available
                                    $scope.report.Id = reportId;
                                    $scope.report.Title = response.data.Title;
                                    $scope.report.Description = response.data.Description;
                                    if (response.data.ReportsReportCategories.length == 0) {
                                        $scope.report.selectedReportCategory = "-1";
                                    }
                                    else {
                                        $scope.report.selectedReportCategory = response.data.ReportsReportCategories[0].ReportCategoryId.toString();
                                    }
                                    if (response.data.ReportDataGrids.length > 0) {
                                        $scope.report.selectedDataSource = response.data.ReportDataGrids[0].DataViewId.toString();
                                    }
                                    if (response.data.ReportCharts.length > 0) {
                                        $scope.report.selectedChartType = response.data.ReportCharts[0].ChartType;
                                    }

                                    $scope.getDataColumns($scope.report.selectedDataSource);

                                    if (response.data.ReportDataGrids.length > 0) {
                                        $scope.report.ReportDataGridColumns = response.data.ReportDataGrids[0].ReportDataGridColumns;
                                        for (var i = 0; i < response.data.ReportDataGrids[0].ReportDataGridColumns.length; i++) {
                                            $scope.toggleReportColumnsTickbox(response.data.ReportDataGrids[0].ReportDataGridColumns[i].DataViewColumnId);
                                        }
                                    }
                                    if (response.data.ReportCharts.length > 0) {
                                        for (var i = 0; i < response.data.ReportCharts[0].ReportChartColumns.length; i++) {
                                            $scope.toggleChartColumnsTickbox(response.data.ReportCharts[0].ReportChartColumns[i].DataViewColumnId);
                                        }
                                    }
                                    if ($scope.reportOrganisationId) {
                                        $scope.report.selectedOrganisation = $scope.reportOrganisationId.toString();
                                        $scope.getReportCategoriesAndSelect($scope.reportOrganisationId, $scope.report.selectedReportCategory);
                                    }
                                    if (response.data.OrganisationReports.length > 0)
                                    {
                                        $scope.report.selectedOrganisation = response.data.OrganisationReports[0].OrganisationId.toString();
                                    }
                                    if (response.data.ReportOwners.length > 0) {
                                        $scope.report.ReportOwners = response.data.ReportOwners;
                                    }
                                },
                                function errorCallback(response) {
                                    // called asynchronously if an error occurs
                                    // or server returns response with an error status.
                                }
        );
    }

    //Save the report
    $scope.saveReport = function () {

        $scope.clearMessages();

        if (!($scope.report.Title
                && $scope.report.Description
                && ($scope.report.selectedReportCategory == -1 || $scope.report.selectedReportCategory > 0)))
        {
            $scope.validationMessage = 'Please provide a title, description and category before saving';
        }
        else {
            $scope.report.reportColumns = JSON.stringify($scope.reportSelection);
            $scope.report.chartColumns =  JSON.stringify($scope.chartSelection);
            $scope.report.userId = $scope.userId;

            $scope.reportService.saveReportData($scope.report)
            .then(
                function (response) {
                    console.log("Report saved!");
                    $scope.successMessage = "Report Saved";

                    if (!$scope.report.Id) {
                        var reportId = response.data;
                        
                        // refresh report menu with new report
                        if (angular.isDefined( $scope.$parent.getReportMenuItems)) {
                            $scope.$parent.getReportMenuItems();
                        }
                       
                        // initialise the parameters on the scope to their defaults again in preparation of the reloading of the report.
                        $scope.organisations = { };
                        $scope.reportCategories = {};
                        $scope.chartColumns = {};
                        $scope.reportColumns = [];
                        $scope.report = {};
                        $scope.report.columnOrder = {};
                        $scope.report.columnSortByOrder = {};

                        $scope.successMessage = '';
                        $scope.chartSelection =[];
                        $scope.reportSelection =[];
                        $scope.selectedOrganisation = {};
                        $scope.selectedChartType = {};

                        $scope.loadReport(reportId);
                    }
                    //show the configure report screen:
                    $scope.configureReport = true;
                },
                    function (response) {
                        console.log(response);
                        $scope.validationMessage = response.data + " " +response.statusText;
                    }
                );
        }
    }

    $scope.clearChartColumns = function () {
        $scope.chartSelection =[];
    }

    $scope.clearMessages = function () {

        //Clear any error message
        $scope.successMessage = '';
        $scope.validationMessage = '';
    }


    $scope.createReportCategory = function () {

        //Clear any error message
        $scope.successMessage = '';
        $scope.validationMessage = '';
    }


    $scope.getOrganisations($scope.userId);
    $scope.getDataSources();

    // show the add/edit report form:
    if (!$scope.configureReport) {
        $scope.configureReport = false;
    }

    // see if we are performing an edit of a report
    if ($scope.reportId){
        $scope.loadReport($scope.reportId);
    }

    // initialising the organisation ddl
    $scope.setInitialOrganisation = function () {
        $scope.report.selectedOrganisation = activeUserProfile.selectedOrganisation.Id;
        $scope.getReportCategories(activeUserProfile.selectedOrganisation.Id);
    }

}