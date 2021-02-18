(function () {

    'use strict';

    angular
        .module("app")
        .controller("reportOwnersCtrl", reportOwnersCtrl);

    reportOwnersCtrl.$inject = ["$scope", "activeUserProfile", "reportService"];

    function reportOwnersCtrl($scope, activeUserProfile, ReportService) {

        /**
         * Selected Report Owners
         */
        $scope.reportOwners = [];

        /**
         * Available Users
         */
        $scope.availableUsers = [];

        $scope.getReportOwners = function () {

            ReportService.get($scope.reportId)
                                .then(
                                    function successCallback(response) {
                                        $scope.report = response.data;
                                        if ($scope.report) {
                                            if ($scope.report.ReportOwners) {
                                                var reportOwnerNameIdPairs = [];
                                                for (var i = 0; i < $scope.report.ReportOwners.length; i++)
                                                {
                                                    if ($scope.report.ReportOwners[i].User) {
                                                        var reportOwnerNameIdPair = {};
                                                        reportOwnerNameIdPair.Id = $scope.report.ReportOwners[i].User.Id;
                                                        reportOwnerNameIdPair.Name = $scope.report.ReportOwners[i].User.Name;
                                                        reportOwnerNameIdPairs.push(reportOwnerNameIdPair);
                                                    }
                                                }
                                                $scope.reportOwners = reportOwnerNameIdPairs;
                                            }
                                            else {
                                                $scope.reportOwners = [];
                                            }
                                        }
                                        else {
                                            $scope.statusMessage = "An error occurred please talk to your system administrator.";
                                        }
                                    },
                                    function errorCallback(response) {
                                        // called asynchronously if an error occurs
                                        // or server returns response with an error status.
                                    }
                                );            
        };

        /**
         * Get the available users
         */
        $scope.getAvailableUsers = function () {

            /**
             * For now set the org id as the first in the array 
             */
            ReportService.getReportAvailableUsers($scope.reportId, $scope.reportOrganisationId)
                .then(function (response) {
                    $scope.availableUsers = response.data;
                }, function(response) {
                    console.log("There has been an error retrieving the list of available user data");
                });
        };

        /**
         * Call the methods to update the object
         */
        $scope.refreshLists = function () {
            // make sure all our scope variables are as expected.
            if (!$scope.reportId && !$scope.reportOrganisationId) {
                if ($scope.parent.reportId && $scope.parent.reportOrganisationId) {
                    $scope.reportId = $scope.parent.reportId;
                    $scope.reportOrganisationId = $scope.parent.reportOrganisationId;
                }
                else {
                    return;
                }
            }
            if (!$scope.reportOrganisationId && $scope.organisationId) {
                $scope.reportOrganisationId = $scope.organisationId;
            }

            $scope.getReportOwners();
            $scope.getAvailableUsers();
            if($scope.editingReport && $scope.editingReport == true){   // refresh the reportOwners list in the edit report form.
                if ($scope.loadReport) {
                    $scope.loadReport($scope.reportId);
                }
            }
        }

        $scope.arrayContainsId = function (array, id) {
            var exists = false;
            if(array && id){
                for (var i = 0; i < array.length; i++) {
                    if (array[i].Id == id) {
                        exists = true;
                        break;
                    }
                }
            }
            return exists;
        }

        /**
         * 
         */
        $scope.processDataMove = function (option, event, to, from) {
            $scope.statusMessage = "";
            if (from === "availableUsers" && to === "reportOwners") {
                // see if the report owners array already has this user
                if (!$scope.arrayContainsId($scope.reportOwners, option.Id)) {
                    // add the user to the reportOwners
                    ReportService.addReportOwner($scope.reportId, option.Id)
                                        .then(
                                            function successCallback(response) {
                                                $scope.refreshLists();
                                            },
                                            function errorCallback(response) {
                                                // called asynchronously if an error occurs
                                                // or server returns response with an error status.
                                                $scope.statusMessage = "An error occurred please contact support."
                                            }
                                        );
                }
            }
            else if (from === "reportOwners" && to === "availableUsers") {
                if ($scope.reportOwners.length == 1) {
                    $scope.statusMessage = "A report must have an owner. To remove this owner please first add another user.";
                }
                else {
                    // remove the owner from the report
                    ReportService.removeReportOwner($scope.reportId, option.Id).then(
                                            function successCallback(response) {
                                                $scope.refreshLists();
                                            },
                                            function errorCallback(response) {
                                                // called asynchronously if an error occurs
                                                // or server returns response with an error status.
                                                $scope.statusMessage = "An error occurred please contact support."
                                            }
                                        );
                }
            }
        }

        $scope.refreshLists();
    }

})();