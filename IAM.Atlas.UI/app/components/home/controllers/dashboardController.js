(function () {

    'use strict';

    angular
        .module("app")
        .controller("DashboardCtrl", DashboardCtrl);

    DashboardCtrl.$inject = ["$scope", "$injector", "activeUserProfile", "DashboardService", "DashboardFactory", "ModalService", "TaskService", "DocumentPrintQueueService", "UserService"];

    function DashboardCtrl($scope, $injector, activeUserProfile, DashboardService, DashboardFactory, ModalService, TaskService, DocumentPrintQueueService, UserService) {

        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;
        /**
         * Instantiate the allowed meters property
         */
        $scope.allowedMeters;

        /**
         * Instantiate the meters property and create an array
         */
        $scope.meter = {};

        /**
         * Instantiate the allowed meters list
         */
        $scope.allowedMetersList = [];

        /**
         * Instantiate the meter key object
         * To access description by key
         */
        $scope.meterByKey = {};

        $scope.userTaskSummary = {};
        $scope.allowUserToCreateTasks = false;
        $scope.showUserTaskPanel = false;


        $scope.documentPQSummary = [];
        $scope.documentPQSummaryInfo = 'Document Print Queue Management. There are "NO" Documents in the Queue.';
        $scope.documentPQDetail = [];

        $scope.getDocumentPrintQueueSummary = function () {
            DocumentPrintQueueService.GetSummary(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.documentPQSummary = response.data;
                        var findText = 'are "NO" Documents';
                        var replaceText = findText;
                        if ($scope.documentPQSummary.DocumentsInQueue === 1) { replaceText = 'is one document'; }
                        if ($scope.documentPQSummary.DocumentsInQueue > 1) { replaceText = 'are ' + $scope.documentPQSummary.DocumentsInQueue  + ' documents'; }
                        $scope.documentPQSummaryInfo = $scope.documentPQSummaryInfo.replace(findText, replaceText);
                        return response.data;
                    },
                    function errorCallback(response) {
                        var err = response;
                    }
                );
        }

        $scope.getDocumentPrintQueueDetail = function () {
            DocumentPrintQueueService.GetDetail(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.documentPQDetail = response.data;
                        return response.data;
                    },
                    function errorCallback(response) {
                        var err = response;
                    }
                );
        }

        $scope.openDocPrintQueueManagementModal = function () {

            //$scope.specialRequirementClientId = $scope.client.Id;
            //$scope.specialRequirementClientName = $scope.client.DisplayName;
            //$scope.specialRequirementOrganisationId = activeUserProfile.selectedOrganisation.Id;

            ModalService.displayModal({
                scope: $scope,
                title: "Document Merge and Print Queue",
                cssClass: "documentPrintQueueModal",
                filePath: "/app/components/documentPrintQueue/manage.html",
                controllerName: "DocumentPrintQueueCtrl",
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
         * Get the meters that 
         * the user / org has access to
         */
        DashboardService.getDashboardMeterAccess(activeUserProfile.selectedOrganisation.Id, activeUserProfile.UserId)
        .then(
            function (response) {
                var allowedMeters = response.data;
                var refreshRate = DashboardFactory.getRefreshRate(allowedMeters);
                $scope.allowedMetersList = response.data;
                $scope.getMeterData(allowedMeters);

                /**
                 * 
                 */
                angular.forEach($scope.allowedMetersList, function (value, index) {
                    $scope.meterByKey[value.Name] = value;
                });

                var refresh = setInterval(function () {
                    $scope.getMeterData(allowedMeters);
                }, refreshRate);

                $scope.$on('$destroy', function () {
                    var ret = clearInterval(refresh);
                });

            },
            function (reason) {
                console.log(reason);
            }
        );

        /**
         * Get when clicking on the icons closes and opens 
         * Based on when it's clicked
         * 
         * If a second parameter is set 
         * then increase /decrease colum width 
         * based on what is set
         */
        $scope.openPanel = function (element, increaseColumnSize) {

            var selector = $(element.currentTarget);

            if (increaseColumnSize !== undefined) {
                var classToUpdate = "col-sm-12";
                var mainColumnSelector = selector.parent().parent();
                var currentClassName = mainColumnSelector.attr("class");
                if (!mainColumnSelector.hasClass("col-sm-6")) {
                    classToUpdate = "col-sm-6";
                }
                mainColumnSelector
                    .addClass(classToUpdate)
                    .removeClass(currentClassName);
            }

            
            selector.toggleClass("show-dashboard-container");
            selector.parent().next().slideToggle();

            if (this.key !== undefined) {
                $scope.showRefreshButton(this.key);
            };
        };

        /**
         * 
         */
        $scope.transformPaymentData = function (paymentData) {
            return {
                today: {
                    online: paymentData.NumberOfOnlinePaymentsTakenToday,
                    phone: paymentData.NumberOfPhonePaymentsTakenToday,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenToday,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenToday,
                    total: paymentData.NumberOfPaymentsTakenToday - paymentData.NumberOfUnallocatedPaymentsTakenToday - paymentData.NumberOfRefundedPaymentsTakenToday,
                    amount: paymentData.PaymentSumTakenToday,
                    label: "Today's Payments"
                },
                yesterday: {
                    online: paymentData.NumberOfOnlinePaymentsTakenYesterday,
                    phone: paymentData.NumberOfPhonePaymentsTakenYesterday,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenYesterday,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenYesterday,
                    total: paymentData.NumberOfPaymentsTakenYesterday - paymentData.NumberOfUnallocatedPaymentsTakenYesterday - paymentData.NumberOfRefundedPaymentsTakenYesterday,
                    amount: paymentData.PaymentSumTakenYesterday,
                    label: "Yesterday's Payments"
                },
                thisWeek: {
                    online: paymentData.NumberOfOnlinePaymentsTakenThisWeek,
                    phone: paymentData.NumberOfPhonePaymentsTakenThisWeek,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenThisWeek,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenThisWeek,
                    total: paymentData.NumberOfPaymentsTakenThisWeek - paymentData.NumberOfUnallocatedPaymentsTakenThisWeek - paymentData.NumberOfRefundedPaymentsTakenThisWeek,
                    amount: paymentData.PaymentSumTakenThisWeek,
                    label: "This Week's Payments"
                },
                thisMonth: {
                    online: paymentData.NumberOfOnlinePaymentsTakenThisMonth,
                    phone: paymentData.NumberOfPhonePaymentsTakenThisMonth,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenThisMonth,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenThisMonth,
                    total: paymentData.NumberOfPaymentsTakenThisMonth - paymentData.NumberOfUnallocatedPaymentsTakenThisMonth - paymentData.NumberOfRefundedPaymentsTakenThisMonth,
                    amount: paymentData.PaymentSumTakenThisMonth,
                    label: "This Month's Payments"
                },
                previousMonth: {
                    online: paymentData.NumberOfOnlinePaymentsTakenPreviousMonth,
                    phone: paymentData.NumberOfPhonePaymentsTakenPreviousMonth,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenPreviousMonth,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenPreviousMonth,
                    total: paymentData.NumberOfPaymentsTakenPreviousMonth - paymentData.NumberOfUnallocatedPaymentsTakenPreviousMonth - paymentData.NumberOfRefundedPaymentsTakenPreviousMonth,
                    amount: paymentData.PaymentSumTakenPreviousMonth,
                    label: "The Previous Month's Payments"
                },
                thisYear: {
                    online: paymentData.NumberOfOnlinePaymentsTakenThisYear,
                    phone: paymentData.NumberOfPhonePaymentsTakenThisYear,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenThisYear,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenThisYear,
                    total: paymentData.NumberOfPaymentsTakenThisYear - paymentData.NumberOfUnallocatedPaymentsTakenThisYear - paymentData.NumberOfRefundedPaymentsTakenThisYear,
                    amount: paymentData.PaymentSumTakenThisYear,
                    label: "This Year's Payments"
                },
                previousYear: {
                    online: paymentData.NumberOfOnlinePaymentsTakenPreviousYear,
                    phone: paymentData.NumberOfPhonePaymentsTakenPreviousYear,
                    unallocated: paymentData.NumberOfUnallocatedPaymentsTakenPreviousYear,
                    refunded: paymentData.NumberOfRefundedPaymentsTakenPreviousYear,
                    total: paymentData.NumberOfPaymentsTakenPreviousYear - paymentData.NumberOfUnallocatedPaymentsTakenPreviousYear - paymentData.NumberOfRefundedPaymentsTakenPreviousYear,
                    amount: paymentData.PaymentSumTakenPreviousYear,
                    label: "The Previous Year's Payments"
                },
                lastUpdated: paymentData.lastUpdated
            };
        };


        /**
         * 
         */
        $scope.createMeterData = function (meterName) {
            
            DashboardService.getMeterData(meterName, activeUserProfile.selectedOrganisation.Id)
            .then(
                function (response) {
                    $scope["meter"][meterName] = {};
                    if (meterName === "Payments") {
                        $scope["meter"][meterName] = $scope.transformPaymentData(response.data);
                    } else {
                        $scope["meter"][meterName] = response.data;
                    }
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };



        /**
         * Load refresh button
         * For selected meters that are meant to have it
         */
        $scope.showRefreshButton = function (meterName) {

            /**
             * Array of allowed meters
             * That will show refresh button
             */
            var allowedMeters = ["Clients", "Courses", "DORSOfferWithdrawn", "Payments"];

            /**
             * Check to see if the meter is in the array
             */
            if (allowedMeters.indexOf(meterName) !== -1) {

                var theClassName = $(".refresh." + meterName);
                /**
                 * Check to see when 
                 * element is available
                 */
                var check = setInterval(function () {
                    if (theClassName.length > 0) {
                        $(theClassName).show();
                        clearInterval(check);
                    }
                }, 500);
            }
        }


        /**
         * Loop through the returned data
         * Call the views that are 
         * associated with the Meters
         */
        $scope.getMeterData = function (meters) {
            angular.forEach(meters, function (value, index) {
                $scope.createMeterData(value.Name);
            });
        };

        /**
         * Split the uppercase
         * 
         */
        $scope.splitUppercase = function (key) {
            return key.replace(/([a-z])([A-Z])/g, '$1 $2').replace(/_/g, ' ');
        };

        /**
         * Select the correct title for the child modal based on the unfiltered column name (i.e. the one from the webapi object)
         */
        $scope.selectCorrectTitle = function (parameter) {

            var isPayment = parameter.indexOf("|");
            if (isPayment !== -1) {
                return parameter.replace(/[|,]/g, ' - ');
            }

            var titleObject = {
                RegisteredToday: "Registrations",
                RegisteredOnlineToday: "Online Registrations",
                NumberOfUnpaidCourses: "Outstanding Course Payments",
                TotalAmountUnpaid: "Outstanding Course Payments",
                NumberOfAttendanceUpdatesDue: "Trainers with Outstanding Course Attendances",
                NumberOfAttendanceVerificationsDue: "Outstanding Course Attendance Verifications",
                SumOfOutstandingBalances: "Outstanding Course Payments",
                NumberOfPaymentsDue: "Outstanding Course Payments",
                OffersWithdrawnToday: "DORS - Offers Withdrawn - Today",
                OffersWithdrawnThisWeek: "DORS - Offers Withdrawn - This Week",
                OffersWithdrawnThisMonth: "DORS - Offers Withdrawn - This Month",
                OffersWithdrawnPreviousMonth: "DORS - Offers Withdrawn - Previous Month",
                UnableToUpdateInDORS: "DORS - Clients Unable To Update",
                AttendanceNotUploadedToDORS: "DORS - Attendance Not Uploaded",
                ClientsWithMissingReferringAuthorityCreatedThisWeek: "Clients With Missing Referring Authority - Created This Week",
                ClientsWithMissingReferringAuthorityCreatedThisMonth: "Clients With Missing Referring Authority - Created This Month",
                ClientsWithMissingReferringAuthorityCreatedLastMonth: "Clients With Missing Referring Authority - Created Last Month"
            };
            return titleObject[parameter];
        };

        /**
         * Select the correct title
         */
        $scope.selectCorrectCss = function (hoverParamName) {
            if (hoverParamName === "NumberOfAttendanceVerificationsDue") {
                return "dashboardHoverInformationSmallModal";
            } else {
                return "dashboardHoverInformationModal";
            }
        };

        /**
         * Open a modal
         * With more information based on which
         * parameter has been clicked
         */
        $scope.openExtraInformationModal = function (meterName, parameter) {

            /**
             * Array of allowed meters
             * That can be clickable
             */
            var allowedMeters = ["Clients", "Courses", "DORSOfferWithdrawn", "Payments"];

            /**
             * Excluded Parameters
             */
            var excludedParams = ["TotalClients"];

            /**
             * Check to see if the meter name is in
             * The array of allowed meters
             */
            if (allowedMeters.indexOf(meterName) === -1) {
                return false;
            }

            /**
             * Check to see if the parameter name is in
             * The array of excluded parameters
             */
            if (excludedParams.indexOf(parameter) !== -1) {
                return false;
            }

            /**
             * Set parameter & meter name 
             * On the scope
             */
            $scope.hoverMeterName = meterName;
            $scope.hoverParamName = parameter;


            /**
             * open modal 
             * & pass params
             */
            ModalService.displayModal({
                scope: $scope,
                title: $scope.selectCorrectTitle(parameter),
                cssClass: $scope.selectCorrectCss(parameter),
                filePath: "/app/components/home/dashboardHoverInformation.html",
                controllerName: "DashboardHoverInformationCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            })
        };


        /**
         * Chart data
         */
        $scope.labels = ["January", "February", "March", "April", "May", "June", "July"];
        $scope.series = ['Series A', 'Series B'];
        $scope.data = [
          [65, 59, 80, 81, 56, 55, 40],
          [28, 48, 40, 19, 86, 27, 90]
        ];

        $scope.onClick = function (points, evt) {
            console.log(points, evt);
        };

        $scope.filterUpdateTime = function (items) {
            var result = {};
            angular.forEach(items, function (value, key) {
                if (!(key === 'lastUpdated') && !(key === 'meterOrgName')) {
                    result[key] = value;
                }
            });
            return result;
        }

        $scope.getUserTaskSummary = function () {
            TaskService.GetTaskSummaryByUser(activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        $scope.userTaskSummary = response.data;
                        if ($scope.userTaskSummary.length > 0) {
                            $scope.allowUserToCreateTasks = $scope.userTaskSummary[0].AllowTaskCreation;
                            $scope.showUserTaskPanel = $scope.userTaskSummary[0].ShowTaskList;
                        }
                    },
                    function errorCallback(response) {
                        var err = response;
                    }
                );
        }

        $scope.viewTaskList = function (TaskPriorityNumber, TotalNumberOfOpenTasks) {
            $scope.viewAllUsers = false;
            if (TotalNumberOfOpenTasks > 0) {
                $scope.TaskPriorityNumber = TaskPriorityNumber;
                ModalService.displayModal({
                    scope: $scope,
                    title: "Task and Action List - Priority " + $scope.TaskPriorityNumber,
                    cssClass: "TaskListModal",
                    filePath: "/app/components/task/list.html",
                    controllerName: "TaskListCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogueItself) {
                            dialogueItself.close();
                        }
                    }
                });
            }
        }

        $scope.addNewTask = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Create New Task",
                cssClass: "AddTaskModal",
                filePath: "/app/components/task/add.html",
                controllerName: "AddTaskCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        $scope.viewAllUserTaskLists = function () {
            $scope.viewAllUsers = true;
            ModalService.displayModal({
                scope: $scope,
                title: "View All User Task Lists",
                cssClass: "TaskListModal",
                filePath: "/app/components/task/list.html",
                controllerName: "TaskListCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        if (activeUserProfile.PasswordChangeRequired === true) {
            ModalService.displayModal({
                scope: $scope,
                title: "Please change your password",
                cssClass: "passwordResetModal",
                filePath: "/app/components/changePassword/Update.html",
                controllerName: "ChangePasswordCtrl"
            });
        }

        $scope.checkUserExtendedRoles = function(){
            UserService.getCurrentUserExtendedRoles(activeUserProfile.UserId)
                .then(
                    function (data) {
                        $scope.UserExtendedRoles = data;
                        $scope.allowUserToCreateTasks = $scope.UserExtendedRoles.IsAllowedToCreateTasks;
                        $scope.showUserTaskPanel = $scope.UserExtendedRoles.IsAllowedAccessToTaskPanel;
                    },
                    function (response) {
                        var err = response;
                    }
                );
        }

        $scope.getDocumentPrintQueueSummary();
        $scope.getDocumentPrintQueueDetail();

        $scope.getUserTaskSummary();
        $scope.checkUserExtendedRoles();

    }

})();