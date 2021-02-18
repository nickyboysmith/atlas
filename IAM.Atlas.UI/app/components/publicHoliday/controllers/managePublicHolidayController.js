(function () {

    'use strict';

    angular
        .module('app')
        .controller('PublicHolidayCtrl', PublicHolidayCtrl);

    PublicHolidayCtrl.$inject = ["$scope", "$compile", "$timeout", "$filter", "ModalService", "PublicHolidayManagementService"];

    function PublicHolidayCtrl($scope, $compile, $timeout, $filter, ModalService, PublicHolidayManagementService) {


        $scope.publicHolidayManagementService = PublicHolidayManagementService;

        $scope.modalService = ModalService;

        $scope.selectedCountry = 0;
        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.Countries = [{ id: 0, name: 'ALL' },
                            { id: 1, name: 'Wales'},
                            { id: 2, name: 'England'},
                            { id: 3, name: 'Scotland'},
                            { id: 4, name: 'Nothern Ireland'}
                            ];

        $scope.selectedCountries = {
            Countries: []
        };

        $scope.manage = {
            thePublicHoliday: {
                Title: "",
                Date: ""
            }
        };
       
        $scope.selectTheCountry = function (selected) {
            $scope.publicHolidayManagementService.getPublicHolidays(selected).then(function (response) {
           
                // clear validation message
                $scope.removeValidationMessage = '';
                $scope.selectedCountry = selected;
                $scope.publicHolidayCollection = response;
            });
        };


        $scope.selectThePublicHoliday = function (publicHoliday) {

            // clear validation message
            $scope.removeValidationMessage = '';

            $scope.manage.thePublicHoliday = publicHoliday;

        };

       
        $scope.isDistantDate = function () {

            /*
                If the selected date is in the past disable the remove button 
            */
            var today = $filter('date')(new Date(), 'yyyy-MM-dd');
            var publicHolidayDate = $filter('date')(new Date($scope.manage.thePublicHoliday.Date), 'yyyy-MM-dd');

            if (publicHolidayDate < today) {
                return true;
            }
            else {
                return false;
            }
            
         
        }

        $scope.removePublicHoliday = function () {

            $scope.publicHolidayManagementService.removePublicHoliday($scope.manage.thePublicHoliday.Id)
                        .then(function (response) {
                              /**
                             * Refresh the public holiday collection
                             * On Success
                             */
                              $scope.showSuccessFader = true;
                              $scope.removeValidationMessage = "Public Holiday Removed Successfully.";

                              $scope.publicHolidayManagementService.getPublicHolidays($scope.selectedCountry).then(function (response) {
                                  $scope.publicHolidayCollection = response;
                              });
                        }, function (response) {

                            $scope.showErrorFader = true;

                              $scope.removeValidationMessage = "An error occurred please try again.";
                        });

        };

        // used by child modals to refresh this page
        $scope.refreshPublicHolidayModal = function () {
            $scope.publicHolidayManagementService.getPublicHolidays($scope.selectedCountry).then(function (response) {

                //$scope.selectedCountry = selected;
                $scope.publicHolidayCollection = response;
            });
        }

        $scope.addPublicHoliday = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Public Holiday",
                cssClass: "addPublicHolidayModal",
                filePath: "/app/components/publicHoliday/add.html",
                controllerName: "AddPublicHolidayCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        };
            
        $scope.selectTheCountry(0);

    }

})();