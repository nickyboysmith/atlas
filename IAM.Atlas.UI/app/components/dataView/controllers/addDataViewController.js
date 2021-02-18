(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('addDataViewCtrl', addDataViewCtrl);

    addDataViewCtrl.$inject = ["$scope", "DataViewService", "ModalService"];

    function addDataViewCtrl($scope, DataViewService, ModalService) {


        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        $scope.successMessage = '';
        $scope.dataView = {};
        $scope.dataViewService = DataViewService;
        $scope.modalService = ModalService;
        
        /**
         * Save the data
         * To send back to the web api
         */
        $scope.save = function () {
            /**
             * Send the request to the web api
             */
            $scope.dataView.UserId = $scope.userId;
            $scope.dataViewService.saveDataViewDetails($scope.dataView)
                .then(function (data) {
                    $scope.successMessage = data;

                    $scope.showSuccessFader = true;

                    if (data == 'Data View Added!') {
                        //Refresh parent page data views
                        $scope.$parent.refreshDataViews();
                        //Close the modal
                        $scope.cancel('addDataView');
                    }
                }, function(response) {

                    $scope.showErrorFader = true;

                    $scope.successMessage = "An Error Ocurred whilst saving the Data View. Please inform your support contact."
                    console.log("Error Message: " + response);
                });
        };

        $scope.cancel = function (modalClass) {
            $scope.modalService.closeCurrentModal(modalClass);
        };
    }

})();