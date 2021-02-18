(function () {
    'use strict';

    angular
        .module('app')
        .controller('dataViewCtrl', ['$scope', '$timeout', '$location', '$window', '$http', 'DataViewService', 'UserService', 'ModalService', 'activeUserProfile', dataViewCtrl]);

    function dataViewCtrl($scope, $timeout, $location, $window, $http, DataViewService, UserService, ModalService, activeUserProfile, $route) {


        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        $scope.successMessage = '';
        $scope.dataView = {};
        $scope.selectedDataView = null;
        $scope.dataViewService = DataViewService;
        $scope.userService = UserService;
        $scope.modalService = ModalService;
        $scope.dataViews = {};
        $scope.dataView.dataViewColumns = {};
        
        /**
       * Get the DataViews 
       */
        $scope.getDataViews = function () {
            $scope.userId = activeUserProfile.UserId;
            //Reset the dataView
            $scope.dataView = {};

            $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (response) {
                $scope.isAdmin = JSON.parse(response);
            });
            
            $scope.dataViewService.getDataViews($scope.userId)
                .then(function (response) {
                 $scope.dataViews = response;
            });
        }

        /**
        * Get the details of the DataView that is selected
        */
        $scope.getDataViewDetails = function (dataViewId) {

            $scope.successMessage = '';
            $scope.validationMessage = '';

            //Call on DataViewService to get key dataView details for the selected dataView...
            $scope.dataViewService.getDataView(dataViewId, $scope.userId)
                .then(function (response) {
                    $scope.dataView = response[0];
                    
                    //get associated dataView columns.
                    $scope.dataViewService.getDataViewColumns(dataViewId, $scope.userId)
                        .then(function (response) {
                            $scope.dataView.dataViewColumns = response;
                        });

                    $scope.selectedDataView = dataViewId;
                });
        }

        // used by child modals to refresh this page's dataView list after deletion or addition
        $scope.refreshDataViewModalDataViewCosts = function () {
            $scope.dataViewService.getDataViewCosts($scope.dataView.id)
                        .then(function (response) {
                            $scope.selectedDataView = -1;
                            $scope.dataView.dataViewCosts = response;
                        });
        }


        //Save details that are amended for a selected Data View
        $scope.saveDataViewDetails = function () {
            $scope.dataView.UserId = $scope.userId;
            $scope.dataViewService.saveDataViewDetails($scope.dataView)
                .then(function (data, status) {

                    $scope.showSuccessFader = true;

                    if (data == 'Data View Saved!') {
                        $scope.successMessage = 'Data View Saved!';
                        $scope.refreshDataViews();
                    }
                    else {
                        $scope.validationMessage = data;
                    }

                }, function(data, status) {

                    $scope.showErrorFader = true;

                    $scope.validationMessage = 'Data View save failed!';
                });
            
            
        }

        $scope.addDataView = function () {
            //Clear the DataView to allow adding new
            $scope.dataView = {};
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Data View",
                cssClass: "addDataView",
                filePath: "/app/components/dataview/add.html",
                controllerName: "addDataViewCtrl"
            });
        }

        $scope.refreshDataViews = function () {
            $scope.getDataViews();
        }

        $scope.getDataViews();
    }
})();


