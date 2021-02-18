(function () {
    'use strict';

    angular
        .module('app')
        .controller('reportParametersCtrl'
                    , ['$scope', '$timeout', '$location', '$window'
                        , '$http', '$q', '$filter', 'reportParametersService', 'ModalService', 'activeUserProfile', reportParametersCtrl
                    ]);


    function reportParametersCtrl($scope, $timeout, $location, $window, $http, $q, $filter, reportParametersService, ModalService, activeUserProfile) {
        $scope.report = {};

        $scope.runReportId = $scope.$parent.selectedReport;
        //$scope.runReportOrganisationId = $scope.$parent.selectedOrganisation;

        //$scope.report.OrganisationId = activeUserProfile.selectedOrganisation.Id;
        //$scope.report.UserId = activeUserProfile.UserId;

        //if ($scope.runReportOrganisationId.length > 0) {
        //    $scope.report.OrganisationId = $scope.runReportOrganisationId;
        //}

        var orgId = activeUserProfile.selectedOrganisation.Id;
        if ($scope.runReportOrganisationId !== undefined && $scope.runReportOrganisationId.length > 0) {
            orgId = $scope.runReportOrganisationId;
        }

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy');
        }

        $scope.errorClass = 'Error';
        $scope.successClass = 'Success';
        $scope.normalClass = 'Normal';
        $scope.reportGeneratorModalClass = 'reportGeneratorModal';
        $scope.ExceptionMessage = '';
        $scope.StatusClass = $scope.normalClass;

        $scope.reportParameterData = {
            bDate: null, bDateParameterId: -1
            , bDateTo: null, bDateToParameterId: -1
            , string: null, stringParameterId: -1
            , date: null, dateParameterId: -1
            , venueSingle: null, venueSingleParameterId: -1
            , trainerSingle: null, trainerSingleParameterId: -1
            , referringAuthoritySingle: null, referringAuthoritySingleParameterId: -1
            , paymentMethod: null, paymentMethodParameterId: -1
            , courseType: null, courseTypeParameterId: -1
            , coursesRecentFutureSingle: null, coursesRecentFutureSingleParameterId: -1
            , coursesPastSingle: null, coursesPastSingleParameterId: -1
        }

        var EmptyReportSession = { reportRequestId: -1, organisationId: -1, reportId: -1, reportTitle: '', reportTimer: '00:00', reportParameters: $scope.reportParameterData };
        $scope.reportSession = { reportRequestId: -1, organisationId: -1, reportId: -1, reportTitle: '', reportTimer: '00:00', reportParameters: $scope.reportParameterData };
        if ($scope.ActiveReportSessions === undefined || $scope.ActiveReportSessions === null) {
            $scope.ActiveReportSessions = [];
        }

        //$scope.showReportparametersLoading = true;
        //$scope.venueReferenceDataLoading = false;
        //$scope.trainerReferenceDataLoading = false;
        //$scope.referringAuthorityReferenceDataLoading = false;
        //$scope.paymentMethodReferenceDataLoading = false;
        //$scope.courseTypeReferenceDataLoading = false;
        //$scope.coursesRecentFutureDataLoading = false;
        //$scope.coursesPastDataLoading = false;
        //$scope.checkIfStillLoading = function () {
        //    if (
        //        $scope.venueReferenceDataLoading === false
        //        && $scope.trainerReferenceDataLoading === false
        //        && $scope.referringAuthorityReferenceDataLoading === false
        //        && $scope.paymentMethodReferenceDataLoading === false
        //        && $scope.courseTypeReferenceDataLoading === false
        //        && $scope.coursesRecentFutureDataLoading === false
        //        && $scope.coursesPastDataLoading === false
        //        )
        //    {
        //        $scope.showReportparametersLoading = false;
        //    } else {
        //        $scope.showReportparametersLoading = true;
        //    }
        //}


        /************************************************************************/
        var rowLimiterMin = 50;
        var rowLimiterMax = 500;
        var rowLimiterStep = 50;

        $scope.rowLimiterOptions =[];

        for (var x = rowLimiterMin; x < rowLimiterMax + 1; x = x + rowLimiterStep) {
            $scope.rowLimiterOptions.push(x);
        }
        $scope.coursesPastLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedPastCourseShowRows = $scope.rowLimiterOptions[0];

        $scope.coursesRecentFutureLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedRecentFutureCourseShowRows = $scope.rowLimiterOptions[0];

        $scope.courseTypeReferenceLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedCourseTypeReferenceShowRows = $scope.rowLimiterOptions[0];

        $scope.paymentMethodReferenceLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedPaymentMethodReferenceShowRows = $scope.rowLimiterOptions[0];

        $scope.referringAuthorityReferenceLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedReferringAuthorityReferenceShowRows = $scope.rowLimiterOptions[0];

        $scope.trainerReferenceLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedTrainerReferenceShowRows = $scope.rowLimiterOptions[0];

        $scope.venueReferenceLimiterOptions = $scope.rowLimiterOptions;
        $scope.selectedVenueReferenceShowRows = $scope.rowLimiterOptions[0];

        /************************************************************************/

        $scope.reportParameterControl = {
            bDateDisplay: false
            , bDateToDisplay: false
            , toggleBDateCalendar: function () { $scope.reportParameterControl.bDateDisplay = !$scope.reportParameterControl.bDateDisplay; }
            , toggleBDateToCalendar: function () { $scope.reportParameterControl.bDateToDisplay = !$scope.reportParameterControl.bDateToDisplay; }
        }

        $scope.getReportParameters = function () {
            reportParametersService.getReportParameters($scope.runReportId, orgId)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.report = response.data;
                        $scope.report.inputParameters.forEach(function (parameter) {
                            if (parameter.parameterType === 'VenueSingle') {
                                $scope.getVenueReferenceData();
                            } else if (parameter.parameterType === 'TrainerSingle') {
                                $scope.getTrainerReferenceData();
                            } else if (parameter.parameterType === 'ReferringAuthoritySingle') {
                                $scope.getReferringAuthorityReferenceData();
                            } else if (parameter.parameterType === 'PaymentMethod') {
                                $scope.getPaymentMethodReferenceData();
                            } else if (parameter.parameterType === 'CourseType') {
                                $scope.getCourseTypeReferenceData();
                            } else if (parameter.parameterType === 'CoursesRecentFutureSingle') {
                                $scope.getCoursesRecentFutureData();
                            } else if (parameter.parameterType === 'CoursesPastSingle') {
                                $scope.getCoursesPastData();
                            }
                        });
                    }
                }
                ,
                function () {
                    
                }
            )
        }

        /******************************************************************/
        $scope.selectedRecentFutureCourse = null;
        $scope.selectedRecentFutureCourseListItem = function (listItem) {
            $scope.selectedRecentFutureCourse = listItem;
            if (listItem === null) {
                $scope.reportParameterData.coursesRecentFutureSingle = null;
                $scope.reportParameterData.coursesRecentFutureSingleText = null;
            } else {
                $scope.reportParameterData.coursesRecentFutureSingle = listItem.CourseId;
                $scope.reportParameterData.coursesRecentFutureSingleText = listItem.CourseIdentity;
            }
        }

        $scope.getCoursesRecentFutureData = function () {
            $scope.coursesRecentFutureDataLoading = true;
            reportParametersService.getReportReferenceData('CoursesRecentFuture', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.coursesRecentFutureData = response.data;
                        //$scope.coursesRecentFutureDataLoading = false;
                        //$scope.checkIfStillLoading();
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    //$scope.coursesRecentFutureDataLoading = false;
                    //$scope.checkIfStillLoading();
                    return badResponse;
                }
            )
        }
        /******************************************************************/

        /******************************************************************/
        $scope.selectedPastCourse = null;
        $scope.selectedPastCourseListItem = function (listItem) {
            $scope.selectedPastCourse = listItem;
            if (listItem === null) {
                $scope.reportParameterData.coursesPastSingle = null;
                $scope.reportParameterData.coursesPastSingleText = null;
            } else {
                $scope.reportParameterData.coursesPastSingle = listItem.CourseId;
                $scope.reportParameterData.coursesPastSingleText = listItem.CourseIdentity;
            }
        }

        $scope.getCoursesPastData = function () {
            $scope.coursesPastDataLoading = true;
            reportParametersService.getReportReferenceData('CoursesPast', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.coursesPastData = response.data;
                        //$scope.coursesPastDataLoading = false;
                        //$scope.checkIfStillLoading();
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    //$scope.coursesPastDataLoading = false;
                    //$scope.checkIfStillLoading();
                    return badResponse;
                }
            )
        }
        /******************************************************************/

        /******************************************************************/
        $scope.selectedTrainer = null;
        $scope.selectTrainerListItem = function (listItem) {
            $scope.selectedTrainer = listItem;
            if (listItem === null) {
                $scope.reportParameterData.trainerSingle = null;
                $scope.reportParameterData.trainerSingleText = null;
            } else {
                $scope.reportParameterData.trainerSingle = listItem.TrainerId;
                $scope.reportParameterData.trainerSingleText = listItem.TrainerName;
            }
        }

        $scope.getTrainerReferenceData = function () {
            $scope.trainerReferenceDataLoading = true;
            reportParametersService.getReportReferenceData('Trainer', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.trainerReferenceData = response.data;
                        $scope.trainerReferenceDataLoading = false;
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    $scope.trainerReferenceDataLoading = false;
                    return badResponse;
                }
            )
        }
        /******************************************************************/
                

        /******************************************************************/
        $scope.selectedReferringAuthority = null;
        $scope.selectReferringAuthorityListItem = function (listItem) {
            $scope.selectedReferringAuthority = listItem;
            if (listItem === null) {
                $scope.reportParameterData.referringAuthoritySingle = null;
                $scope.reportParameterData.referringAuthoritySingleText = null;
            } else {
                $scope.reportParameterData.referringAuthoritySingle = listItem.ReferringAuthorityId;
                $scope.reportParameterData.referringAuthoritySingleText = listItem.ReferringAuthorityName;
            }
        }

        $scope.getReferringAuthorityReferenceData = function () {
            $scope.referringAuthorityReferenceDataLoading = true;
            reportParametersService.getReportReferenceData('ReferringAuthority', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.referringAuthorityReferenceData = response.data;
                        //$scope.referringAuthorityReferenceDataLoading = false;
                        //$scope.checkIfStillLoading();
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    //$scope.referringAuthorityReferenceDataLoading = false;
                    //$scope.checkIfStillLoading();
                    return badResponse;
                }
            )
        }


        /******************************************************************/
        $scope.selectedVenue = null;
        $scope.selectVenueListItem = function (listItem) {
            $scope.selectedVenue = listItem;
            if (listItem === null) {
                $scope.reportParameterData.venueSingle = null;
                $scope.reportParameterData.venueSingleText = null;
            } else {
                $scope.reportParameterData.venueSingle = listItem.Id;
                $scope.reportParameterData.venueSingleText = listItem.Title;
            }
        }

        $scope.getVenueReferenceData = function () {
            $scope.venueReferenceDataLoading = true;
            reportParametersService.getReportReferenceData('Venue', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.venueReferenceData = response.data;
                        //$scope.venueReferenceDataLoading = false;
                        //$scope.checkIfStillLoading();
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    //$scope.venueReferenceDataLoading = false;
                    //$scope.checkIfStillLoading();
                    return badResponse;
                }
            )
        }
        /******************************************************************/


        /******************************************************************/
        $scope.selectedPaymentMethod = null;
        $scope.selectPaymentMethodListItem = function (listItem) {
            $scope.selectedPaymentMethod = listItem;
            if (listItem === null) {
                $scope.reportParameterData.paymentMethod = null;
                $scope.reportParameterData.paymentMethodText = null;
            } else {
                $scope.reportParameterData.paymentMethod = listItem.Id;
                $scope.reportParameterData.paymentMethodText = listItem.Name;
            }
        }

        $scope.getPaymentMethodReferenceData = function () {
            $scope.paymentMethodReferenceDataLoading = true;
            reportParametersService.getReportReferenceData('PaymentMethod', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.paymentMethodReferenceData = response.data;
                        //$scope.paymentMethodReferenceDataLoading = false;
                        //$scope.checkIfStillLoading();
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    //$scope.paymentMethodReferenceDataLoading = false;
                    //$scope.checkIfStillLoading();
                    return badResponse;
                }
            )
        }
        /******************************************************************/


        /******************************************************************/
        $scope.selectedCourseType = null;
        $scope.selectCourseTypeListItem = function (listItem) {
            $scope.selectedCourseType = listItem;
            if (listItem === null) {
                $scope.reportParameterData.courseType = null;
                $scope.reportParameterData.courseTypeText = null;
            } else {
                $scope.reportParameterData.courseType = listItem.Id;
                $scope.reportParameterData.courseTypeText = listItem.Title;
            }
        }

        $scope.getCourseTypeReferenceData = function () {
            $scope.courseTypeReferenceDataLoading = true;
            reportParametersService.getReportReferenceData('CourseType', activeUserProfile.selectedOrganisation.Id)
            .then
            (
                function (response) {
                    if (response.data) {
                        $scope.courseTypeReferenceData = response.data;
                        //$scope.courseTypeReferenceDataLoading = false;
                        //$scope.checkIfStillLoading();
                        return true;
                    }
                }
                ,
                function (badResponse) {
                    //$scope.courseTypeReferenceDataLoading = false;
                    //$scope.checkIfStillLoading();
                    return badResponse;
                }
            )
        }
        /******************************************************************/


        $scope.date = new Date();
        
        //Reporting Defaults
        if ($scope.reportPageSize === undefined) {
            $scope.reportPageSize = 'A4';
            $scope.reportPageOrientation = 'P';
            $scope.reportPageOrientationClass = 'A4Protrait';
            $scope.reportPortraitRowsPerPage = 25;
            $scope.reportLanscapeRowsPerPage = 20;
            $scope.reportMaximumRows = 4000;
        }

        $scope.reportRunStatement = '';
        $scope.reportRunStatus = '';
        $scope.reportDataRowsReturned = 0;

        reportParametersService
            .getReportsDefaults()
            .then
                (
                    function (response) {
                        if (response.data) {
                            $scope.reportDefaults = response.data;
                            $scope.reportPageSize = $scope.reportDefaults[0].ReportDefaultPageSize;
                            $scope.reportPageOrientation = $scope.reportDefaults[0].ReportDefaultPageOrientation;
                            $scope.reportPortraitRowsPerPage = $scope.reportDefaults[0].ReportDefaultPortraitRowsPerPage;
                            $scope.reportLanscapeRowsPerPage = $scope.reportDefaults[0].ReportDefaultLanscapeRowsPerPage;
                            $scope.reportMaximumRows = $scope.reportDefaults[0].ReportMaximumRows;
                        }
                    }
                    ,
                    function () {
                    }
                )
        ;


        reportParametersService
            .getReportDetail($scope.runReportId)
            .then
                (
                    function (response) {
                        if (response.data) {
                            $scope.reportDetail = response.data;
                            $scope.reportMainTitle = $scope.reportDetail[0].ReportTitle;
                            //$scope.reportSubTitle = ''; //This is Calculated from the Parameters
                            $scope.reportDescription = $scope.reportDetail[0].ReportDescription;
                            $scope.reportPageOrientation = 'P';
                            $scope.reportPageOrientationClass = 'A4Portrait';
                            $scope.reportPageSize = 'A4';
                            if($scope.reportDetail[0].LandscapeReport === true){
                                $scope.reportPageOrientation = 'L'
                                $scope.reportPageOrientationClass = 'A4Landscape';
                                $scope.reportPageSize = 'A4';
                            }
                            $scope.reportVersion = $scope.reportDetail[0].ReportVersion;
                        }
                    }
                    ,
                    function () {
                    }
                )
        ;

        $scope.isDate = function (dateVal) {
            var d = new Date(dateVal);
            return d.toString() === 'Invalid Date' ? false : true;
        }

        $scope.formatDataItem = function (dataItem, dataType) {
            var formattedDataItem;
            switch(dataType) {
                case 'date':
                    if ($scope.isDate(dataItem)) {
                        formattedDataItem = (new Date(dataItem)).toString('dd MMM yyyy');
                    } else {
                        formattedDataItem = ''
                    }
                    break;
                case 'datetime':
                    if ($scope.isDate(dataItem)) {
                        formattedDataItem = (new Date(dataItem)).toString('dd MMM yyyy HH:mm');
                    } else {
                        formattedDataItem = ''
                    }
                    break;
                case 'number':
                    formattedDataItem = dataItem;
                    break;
                case 'currency':
                    formattedDataItem = '£' + dataItem;
                    break;
                default:
                    formattedDataItem = dataItem;
            }

            return formattedDataItem;
        }
        
        $scope.displayReport = function (repRequestId) {
            if (repRequestId === undefined || repRequestId === null) {
                repRequestId = $scope.reportRequestId;
            }
            var pageSize = $scope.reportPageSize;
            var pageOrientation = 'portrait';
            if ($scope.reportPageOrientation === 'L') { pageOrientation = 'landscape'; }
            var windowWidth = 900;
            var windowHeight = 800;
            var reportDivId = 'reportOutput' + repRequestId;
            var windowName = 'Atlas Report ' + (new Date()).toLocaleString(); //The Date Time Allows Multiple Version of the Same Report/Window Name
            var windowTitle = '<title>' + $scope.reportMainTitle + '</title>'
            var windowFeatures = 'menubar=yes,resizable=yes,scrollbars=yes,status=yes';
            var currentUrl = $location.absUrl().split('?')[0];
            windowFeatures = windowFeatures + ',width=' + windowWidth;
            windowFeatures = windowFeatures + ',height=' + windowHeight;

            var jqLite = angular.element;
            if (jqLite('#' + reportDivId)[0] === undefined) {
                //Report Cancelled
                $scope.reportRunStatus = 'Report Generation Cancelled.';
                return;
            }
            var divToView = jqLite('#' + reportDivId)[0]
                            .outerHTML
                            .replace('id="' + reportDivId + '" style="display: none;"', 'id="' + reportDivId + '"') //Remove the Style Display None from the Main Div;
            ;
            var additionalInfo = '';
            if (pageOrientation === 'landscape') { additionalInfo = '<span class="AdditionalInfo"> - Landscape Report</span>'; }
            var warningInfo = '';
            if ($scope.reportDataRowsReturned >= 1000) { warningInfo = '<span class="WarningInfo">This Report has had to be limited to the first 1000 rows only</span>'; }
            var printInfoButton = '<div title="Print Format Information" class="PrintInfo" onclick="ShowPrintInfo()"></div>';
            var printInfoDialog = '<div id="dialogPrintInfo" title="Print Format Information" style="display: none;">'
                                + '     <div>'
                                + '         <div>'
                                + '             <span>To Ensure that your report prints in Landscape you may have to adjust the Browser Page Setup.</span>'
                                + '             <span>If using Internet Explorer then from the File Menu select Page setup.</span>'
                                + '             <span>Select the Landscape Option and then Click the OK button.</span>'
                                + '             <div class="PageSetup"></div>'
                                + '         </div>'
                                + '     </div>'
                                + '</div>';

            var printButtonSection = ' <div class="no-print" style="width:100%;text-align:right">'
                                    + '     ' + '<div class="reportFrameLogo"></div><div class="reportFrameCaption">Atlas Reports' + additionalInfo + warningInfo + '</div>' //+ printInfoButton
                                    //+ printInfoDialog
                                    //+ '     <a id="zoomOut" onclick="zoomOut()" class="no-print btn btn-default btn-sm pull-right">Zoom Out</a>'
                                    //+ '     <a id="zoomIn" onclick="zoomIn()" class="no-print btn btn-default btn-sm pull-right">Zoom In</a>'
                                    + '     <input type="button" value="Cancel" class="no-print btn btn-default btn-sm pull-right"  style="width:100px" onclick="window.close()" />'
                                    + '     <input type="button" value="Print" class="no-print btn btn-default btn-sm pull-right" style="width:100px" onclick="window.print()" />'
                                    + ' </div>';
            var zoomFunctionality = '<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js">'
                                    + '$(document).ready(function () { '
                                    + '     var currFFZoom = 1;'
                                    + '     var currIEZoom = 100;'
                                    + '     '
                                    + '     function zoomIn(){'
                                    + '         var step = 0.10;'
                                    + '         currFFZoom += step;'
                                    + '         $("body").css("MozTransform","scale(" + currFFZoom + ")");'
                                    + '         var stepie = 20;'
                                    + '         currIEZoom += stepie;'
                                    + '         $("body").css("zoom", " " + currIEZoom + "%");'
                                    + '     };'
                                    + '     '
                                    + '     function zoomOut(){'
                                    + '         var step = 0.10;'
                                    + '         currFFZoom += step;'
                                    + '         $("body").css("MozTransform","scale(" + currFFZoom + ")");'
                                    + '         var stepie = 20;'
                                    + '         currIEZoom -= stepie;'
                                    + '         $("body").css("zoom", " " + currIEZoom + "%");'
                                    + '     };'
                                    + '});'
                                    + '</script>';
            var scriptShowPrintinfo = '<script  type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js"> '
                                    + '     $( function ShowPrintInfo() { alert("Dude"); '
                                    + '         $( "#dialogPrintInfo" ).dialog({'
                                    + '         modal: true,'
                                    + '         buttons: {'
                                    + '             Ok: function() {'
                                    + '                     $( this ).dialog( "close" );'
                                    + '                 }'
                                    + '             }'
                                    + '         });'
                                    + '     } );'
                                    + '</script>';
            var additionalPageSizeSettings = ' @page { size: portrait }';
            if (pageOrientation === 'landscape') { additionalPageSizeSettings = ' @page rotated { size: landscape } table { page : rotated }'; }
            var docHtml = '<html style="height: auto; overflow: auto;"><head>'
                        + windowTitle
                        + '<link href="/app_assets/css/app.css" rel="stylesheet">'
                        + '<link href="/app_assets/css/main.css" rel="stylesheet">'
                        + '<style type="text/css" media="print">'
                        + ' @media print{'
                        + '             .no-print'
                        + '             , .EmaptyLeftPanel'
                        + '             , .no-print *{'
                        + '                 display: none !important;'
                        + '                 height:0; width:0;'
                        + '             a[href]:after { content: none !important; }'
                        + '             img[src]:after { content: none !important; }'
                        + '             div.reportContent { margin: 0 !important; }'
                        + '             }'
                        + ' @page { size: ' + pageSize + ';'
                        + '         margin: 0;'
                        + '         }'
                        + additionalPageSizeSettings
                        + '</style>'
                        + zoomFunctionality
                        //+ scriptShowPrintinfo
                        + '</head><body class="print">'
                        + printButtonSection.replace('class="', 'class="header ')
                        + ''
                        + ''
                        + divToView.replace('display:none;', '')
                        + printButtonSection.replace('class="', 'class="footer ')
                        + '</body></html>'
            ;

            //var myWindow = window.open(this.href
            //                            , windowName
            //                            , windowFeatures
            //                            , true
            //                            );
            //var myWindow = window.open(this.href
            //                            , windowName
            //                            );
            var myWindow = window.open(currentUrl
                                        , '_blank'
                                        );

            var doc = myWindow.document;
            doc.open();
            doc.write(docHtml);
            //doc.getElementById('dialogPrintInfo').appendChild(scriptShowPrintinfo);
            $scope.reportTimer = '00:00';
            doc.close();
            myWindow.moveTo(myWindow.screenX, 1);
            myWindow.focus();
            return myWindow;
        }

        $scope.postReportRequestParameters = function (reportRequestId) {
            var noOfParameters = 0;
            var paramValueId = -1;
            if ($scope.reportParameterData.bDate !== null && $scope.reportParameterData.bDate.length > 0) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.bDateParameterId, $scope.reportParameterData.bDate + ' 00:00:00', $scope.reportParameterData.bDate + ' 00:00:00')
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.bDateTo !== null && $scope.reportParameterData.bDateTo.length > 0) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.bDateToParameterId, $scope.reportParameterData.bDateTo + ' 23:59:59', $scope.reportParameterData.bDateTo + ' 23:59:59')
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.string !== null && $scope.reportParameterData.string.length > 0) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.stringParameterId, $scope.reportParameterData.string, $scope.reportParameterData.string)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.date !== null && $scope.reportParameterData.date.length > 0) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.dateParameterId, $scope.reportParameterData.date, $scope.reportParameterData.date)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.venueSingle !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.venueSingleParameterId, $scope.reportParameterData.venueSingle, $scope.reportParameterData.venueSingleText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.trainerSingle !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.trainerSingleParameterId, $scope.reportParameterData.trainerSingle, $scope.reportParameterData.trainerSingleText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            } 
            if ($scope.reportParameterData.referringAuthoritySingle !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.referringAuthoritySingleParameterId, $scope.reportParameterData.referringAuthoritySingle, $scope.reportParameterData.referringAuthoritySingleText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.paymentMethod !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.paymentMethodParameterId, $scope.reportParameterData.paymentMethod, $scope.reportParameterData.paymentMethodText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.courseType !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.courseTypeParameterId, $scope.reportParameterData.courseType, $scope.reportParameterData.courseTypeText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.coursesRecentFutureSingle !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.coursesRecentFutureSingleParameterId, $scope.reportParameterData.coursesRecentFutureSingle, $scope.reportParameterData.coursesRecentFutureSingleText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            if ($scope.reportParameterData.coursesPastSingle !== null) {
                paramValueId = reportParametersService
                                        .postReportRequestParameterValue(reportRequestId, $scope.reportParameterData.coursesPastSingleParameterId, $scope.reportParameterData.coursesPastSingle, $scope.reportParameterData.coursesPastSingleText)
                                        .then(
                                            function (response) {
                                                noOfParameters += 1;
                                            }
                                            , function (badResponse) {
                                            }
                                        );
            }
            return noOfParameters;
        }
        

        $scope.getReportDataAndThenDownloadData = function (exportType) {
            $scope.reportRunStatus = 'Please wait....Collecting Download Data';
            $scope.reportTimer = '00:00';
            $scope.StatusClass = $scope.normalClass;
            $scope.reportColumnSelectStatement = '';

            angular.forEach($scope.reportColumns, function (value, key) {
                if ($scope.reportColumnSelectStatement === '') {
                    $scope.reportColumnSelectStatement = 'C' + value.ColumnDisplayOrder + ' AS [' + value.ColumnTitle + '] ';
                } else {
                    $scope.reportColumnSelectStatement = $scope.reportColumnSelectStatement + ', ' + 'C' + value.ColumnDisplayOrder + ' AS [' + value.ColumnTitle + '] ';
                }
            });

            reportParametersService
                .getReportData($scope.reportRequestId)
                .then
                    (
                        function (response) {
                            if (response.data) {

                                $scope.reportDataRows = response.data.length;
                                if ($scope.reportPageOrientation === 'P') {
                                    $scope.rowsPerPage = $scope.reportPortraitRowsPerPage;
                                } else {
                                    $scope.rowsPerPage = $scope.reportLanscapeRowsPerPage;
                                }

                                $scope.reportPages = window.Math.ceil($scope.reportDataRows / $scope.rowsPerPage); //Round Up for Pages

                                $scope.reportData = response.data;
                                $scope.reportRunStatus = 'Please wait....Data Collected ... Reformatting....';
                                //$scope.reportDataJson = JSON.stringify(response.data);
                                $scope.reportDataJson = JSON.parse(JSON.stringify(response.data));

                                $scope.reportTimer = '00:00';
                                $scope.secondsPassed = 0;
                                $scope.minutesPassed = 0;
                                $scope.reportClosed = false;
                                $scope.refreshId = setInterval(function () {
                                    if (($scope.reportColumnsApplied && $scope.reportDataApplied) === true) {
                                        clearInterval($scope.refreshId);
                                        //$scope.displayReport();
                                        var exportFileName = 'AtlasDataExport_' + $scope.runReportId + "_" + $filter('date')(new Date(), 'yyyyMMMddmmss');
                                        if (exportType === undefined || exportType === null) { exportType = ''; }
                                        if (exportType === 'pdf') {
                                            exportFileName = exportFileName + '.pdf';
                                        } else if (exportType === 'xls') {
                                            exportFileName = exportFileName + '.xls';
                                            $scope.reportRunStatus = 'Starting Download';
                                            alasql('SELECT ' + $scope.reportColumnSelectStatement + ' INTO XLS("' + exportFileName + '", {headers: true, quote:"",separator:","}) FROM ?', [$scope.reportDataJson]);
                                            setTimeout(
                                                        function () {
                                                            $scope.reportRunStatus = 'Download Ready';
                                                        }, 2000);
                                        } else if (exportType === 'xlsx') {
                                            exportFileName = exportFileName + '.xlsx';
                                            $scope.reportRunStatus = 'Starting Download';
                                            alasql('SELECT ' + $scope.reportColumnSelectStatement + ' INTO XLSX("' + exportFileName + '", {headers: true, quote:"",separator:","}) FROM ?', [$scope.reportDataJson]);
                                            setTimeout(
                                                        function () {
                                                            $scope.reportRunStatus = 'Download Ready';
                                                        }, 2000);
                                        } else if (exportType === 'csv') {
                                            exportFileName = exportFileName + '.csv';
                                            $scope.reportRunStatus = 'Starting Download';
                                            alasql('SELECT ' + $scope.reportColumnSelectStatement + ' INTO CSV("' + exportFileName + '", {headers: false, quote:"",separator:","}) FROM ?', $scope.reportDataJson);
                                            setTimeout(
                                                        function () {
                                                            $scope.reportRunStatus = 'Download Ready';
                                                        }, 2000);
                                        } else {
                                            //Do Nowt At the moment
                                            $scope.reportRunStatus = '**Error: Unexpected Download Type**';
                                        }
                                    } else {
                                        //Do Nothing except paint time
                                        if ($scope.reportClosed === true) {
                                            clearInterval($scope.refreshId);
                                        }
                                        $scope.secondsPassed = $scope.secondsPassed + 1;
                                        if ($scope.secondsPassed >= 60) {
                                            $scope.minutesPassed = $scope.minutesPassed + 1;
                                            $scope.secondsPassed = 0;
                                        }
                                        $scope.reportTimer = ("00" + $scope.minutesPassed).slice(-2)
                                                            + ':' + ("00" + $scope.secondsPassed).slice(-2);
                                    }
                                }, 1000);

                                setTimeout(
                                            function () {
                                                //$scope.currWindow = $scope.displayReport();
                                                var exportFileName = 'AtlasDataExport_' + $scope.runReportId + "_" + $filter('date')(new Date(), 'yyyyMMMddmmss');
                                                if (exportType === undefined || exportType === null) { exportType = ''; }
                                                if (exportType === 'pdf') {
                                                    exportFileName = exportFileName + '.pdf';
                                                } else if (exportType === 'xls') {
                                                    exportFileName = exportFileName + '.xls';
                                                    $scope.reportRunStatus = 'Starting Download';
                                                    alasql('SELECT ' + $scope.reportColumnSelectStatement + ' INTO XLS("' + exportFileName + '", {headers: true, quote:"",separator:","}) FROM ?', [$scope.reportDataJson]);
                                                    setTimeout(
                                                                function () {
                                                                    $scope.reportRunStatus = 'Download Ready';
                                                                }, 2000);
                                                } else if (exportType === 'xlsx') {
                                                    exportFileName = exportFileName + '.xlsx';
                                                    $scope.reportRunStatus = 'Starting Download';
                                                    alasql('SELECT ' + $scope.reportColumnSelectStatement + ' INTO XLSX("' + exportFileName + '", {headers: true, quote:"",separator:","}) FROM ?', [$scope.reportDataJson]);
                                                    setTimeout(
                                                                function () {
                                                                    $scope.reportRunStatus = 'Download Ready';
                                                                }, 2000);
                                                } else if (exportType === 'csv') {
                                                    exportFileName = exportFileName + '.csv';
                                                    $scope.reportRunStatus = 'Starting Download';
                                                    alasql('SELECT ' + $scope.reportColumnSelectStatement + ' INTO CSV("' + exportFileName + '", {headers: true, quote:"",separator:","}) FROM ?', [$scope.reportDataJson]);
                                                    setTimeout(
                                                                function () {
                                                                    $scope.reportRunStatus = 'Download Ready';
                                                                }, 2000);
                                                } else {
                                                    //Do Nowt At the moment
                                                    $scope.reportRunStatus = '**Error: Unexpected Download Type**';
                                                }
                                            }
                                            , 5000);

                            }
                        }
                        ,
                        function () {
                        }
                    )
        }

        $scope.getReportDataAndThenDisplayReport = function (repRequestId) {
            $scope.reportRunStatus = 'Please wait....Collecting Report Data';
            $scope.reportTimer = '00:00';
            $scope.StatusClass = $scope.normalClass;
            if (repRequestId === undefined || repRequestId === null) {
                repRequestId = $scope.reportRequestId;
            }
            reportParametersService
                .getReportData(repRequestId)
                .then
                    (
                        function (response) {
                            if (response.data) {

                                $scope.reportDataRows = response.data.length;
                                if ($scope.reportPageOrientation === 'P') {
                                    $scope.rowsPerPage = $scope.reportPortraitRowsPerPage;
                                } else {
                                    $scope.rowsPerPage = $scope.reportLanscapeRowsPerPage;
                                }

                                $scope.reportPages = window.Math.ceil($scope.reportDataRows / $scope.rowsPerPage); //Round Up for Pages

                                $scope.reportData = response.data;

                                $scope.reportTimer = '00:00';
                                $scope.secondsPassed = 0;
                                $scope.minutesPassed = 0;
                                $scope.reportClosed = false;

                                reportParametersService
                                    .getReportRequestData(repRequestId)
                                    .then
                                        (
                                            function (response) {
                                                if (response.data) {
                                                    $scope.reportDataRowsReturned = response.data.NumberOfDataRows;
                                                    $scope.reportSubTitle = response.data.ReportSubTitle;
                                                    $('.reportSubTitle' + repRequestId)[0].innerHTML = $scope.reportSubTitle;
                                                }

                                                $scope.refreshId = setInterval(function () {
                                                    if (($scope.reportColumnsApplied && $scope.reportDataApplied) === true) {
                                                        clearInterval($scope.refreshId);
                                                        $scope.displayReport(repRequestId);
                                                    } else {
                                                        //Do Nothing except paint time
                                                        if ($scope.reportClosed === true) {
                                                            clearInterval($scope.refreshId);
                                                        }
                                                        $scope.secondsPassed = $scope.secondsPassed + 1;
                                                        if ($scope.secondsPassed >= 60) {
                                                            $scope.minutesPassed = $scope.minutesPassed + 1;
                                                            $scope.secondsPassed = 0;
                                                        }
                                                        $scope.reportTimer = ("00" + $scope.minutesPassed).slice(-2)
                                                                            + ':' + ("00" + $scope.secondsPassed).slice(-2);
                                                    }
                                                }, 1000);

                                                setTimeout(
                                                            function () {
                                                                $scope.reportRunStatus = 'Please wait....Data Collected... Displaying Report';
                                                                //$scope.displayReport();
                                                                $scope.currWindow = $scope.displayReport(repRequestId);
                                                                setTimeout(
                                                                            function () {
                                                                                $scope.CloseReportGeneratorModal();
                                                                                if ($scope.currWindow !== undefined) {
                                                                                    $scope.currWindow.focus();
                                                                                    $scope.reportRunStatus = 'Report Ready';
                                                                                    $scope.StatusClass = $scope.successClass;
                                                                                }
                                                                                clearInterval($scope.refreshId);
                                                                                $scope.reportTimer = '00:00';
                                                                            }, 2000);
                                                            }
                                                            , 5000);
                                            }
                                            ,
                                            function (response) {
                                                $scope.reportRunStatus = 'There was an Error Retrieving the Report Request Data. Please contact Administration Support.';
                                                $scope.StatusClass = $scope.errorClass;
                                                $scope.CloseReportGeneratorModal();
                                                $scope.ExceptionMessage = response.data.ExceptionMessage;
                                            }
                                        )

                            }
                        }
                        ,
                        function (response) {
                            $scope.reportRunStatus = 'There was an Error Retrieving the Report Data. Please contact Administration Support.';
                            $scope.StatusClass = $scope.errorClass;
                            $scope.CloseReportGeneratorModal();
                            $scope.ExceptionMessage = response.data.ExceptionMessage;
                        }
                    )
        }

        $scope.getReportRequestData = function (repRequestId) {
            if (repRequestId === undefined || repRequestId === null) {
                repRequestId = $scope.reportRequestId;
            }

            reportParametersService
                .getReportRequestData(repRequestId)
                .then
                    (
                        function (response) {
                            if (response.data) {
                                $scope.reportDataRowsReturned = response.data.NumberOfDataRows;
                                $scope.reportSubTitle = response.data.ReportSubTitle;
                                $('.reportSubTitle' + repRequestId)[0].innerHTML = $scope.reportSubTitle;
                            }
                        }
                        ,
                        function () {
                        }
                    )
        }

        $scope.runReport = function (exportType) {

            if (exportType === undefined || exportType === null || exportType === '') {
                $scope.reportRunStatement = 'You have started the report generation process.';
            } else {
                $scope.reportRunStatement = 'You requested the report data for download.';
            }
            $scope.reportRunStatus = 'Please wait....';
            $scope.reportTimer = '00:00';

            $scope.runReportOrganisationId = $scope.$parent.selectedOrganisation;

            var orgId = activeUserProfile.selectedOrganisation.Id;

            if ($scope.runReportOrganisationId.length > 0) {
                orgId = $scope.runReportOrganisationId;
            }

            reportParametersService
                .getReportColumns($scope.runReportId)
                .then
                    (
                        function (response) {
                            if (response.data) {
                                $scope.reportRunStatus = 'Please wait....Collection Report Column Information';
                                $scope.reportColumns = response.data;
                            }
                        }
                        ,
                        function (response) {
                            $scope.reportRunStatus = 'There was an Error Retrieving the Report Parameter Data. Please contact Administration Support.';
                            $scope.StatusClass = $scope.errorClass;
                            $scope.CloseReportGeneratorModal();
                            $scope.ExceptionMessage = response.data.ExceptionMessage;
                        }
                    )

            reportParametersService
                .getReportRequest($scope.runReportId, orgId, activeUserProfile.UserId)
                .then
                    (
                        function (response) {
                            if (response.data) {
                                $scope.reportRunStatus = 'Please wait....Request Logged. Setting up parameters....';
                                //Create Report Request
                                $scope.reportRequestId = response.data;
                                //Now Post The Parameters
                                var noParams = $scope.postReportRequestParameters($scope.reportRequestId)

                                return noParams;
                            }
                        }
                        ,
                        function (response) {
                            $scope.reportRunStatus = 'There was an Error Retrieving the Report Parameter Data. Please contact Administration Support.';
                            $scope.StatusClass = $scope.errorClass;
                            $scope.CloseReportGeneratorModal();
                            $scope.ExceptionMessage = response.data.ExceptionMessage;
                        }
                    )
                .then(
                    function (data) {
                        if (exportType === undefined || exportType === null || exportType === '') {
                            $scope.getReportDataAndThenDisplayReport($scope.reportRequestId);
                        } else
                        {
                            $scope.getReportDataAndThenDownloadData(exportType);
                        }
                    }
                    ,
                    function (response) {
                        $scope.reportRunStatus = 'There was an Error Retrieving the Report Parameter Data. Please contact Administration Support.';
                        $scope.StatusClass = $scope.errorClass;
                        $scope.CloseReportGeneratorModal();
                        $scope.ExceptionMessage = response.data.ExceptionMessage;
                    }
                )
                

        }
        
        $scope.CloseReportGeneratorModal = function () {
            $scope.modalService.closeCurrentModal($scope.reportGeneratorModalClass);
        };

        $scope.generateReport = function () {
            $scope.reportRunStatement = 'You have started the report generation process. Please wait';
            $scope.reportRunStatus = '';
            $scope.reportTimer = '00:00';
            $scope.CloseReportGeneratorModal(); //Close if Already Open
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Generating Report",
                cssClass: $scope.reportGeneratorModalClass,
                filePath: "/app/components/report/reportGenerator.html",
                controllerName: "reportParametersCtrl",
                buttons: {
                    label: 'Cancel',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        $scope.reportClosed = true;
                        dialogItself.close();
                        $scope.CloseReportGeneratorModal();
                    }
                }
            });
            $scope.runReport();
        };

        $scope.exportReportData = function (exportType) {
            if (exportType === 'pdf') {
                //pdf
            } else if (exportType === 'xls') {
                //xls
            } else if (exportType === 'xlsx') {
                //xlsx
            } else {
                //Default to CSV
            }
            $scope.reportRunStatement = 'You requested the report data for download. Please wait.';
            $scope.reportRunStatus = '';
            $scope.reportTimer = '00:00';
            $scope.runReport(exportType);
        }

        $scope.getReportParameters();
    }
})();