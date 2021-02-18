(function () {

    'use strict';

    angular
        .module('app')
        .controller('AddPublicHolidayCtrl', AddPublicHolidayCtrl);


   



    AddPublicHolidayCtrl.$inject = ["$scope", "$compile", "$filter", "PublicHolidayManagementService", "DateFactory"];

    function AddPublicHolidayCtrl($scope, $compile, $filter, PublicHolidayManagementService, DateFactory) {

        $scope.publicHolidayManagementService = PublicHolidayManagementService;

        $scope.selectedCountry = "0";
        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.Countries =  [{ id: 1, name: 'Wales' },
                            { id: 2, name: 'England' },
                            { id: 3, name: 'Scotland' },
                            { id: 4, name: 'Nothern Ireland' }
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

        $scope.savePublicHoliday = function () {

            validateForm();

            if ($scope.addValidationMessage == "") {

                $scope.addObject = {

                    Title: $scope.manage.thePublicHoliday.Title,
                    Date: $scope.manage.thePublicHoliday.Date,
                    Country: $scope.selectedCountries.Countries
                };

                $scope.publicHolidayManagementService.savePublicHoliday($scope.addObject)
                    .then(function (response) {

                        /**
                         * Refresh the public holiday collection
                         * On Success
                         */
                        $scope.showSuccessFader = true;
                        
                        $scope.addValidationMessage = "Public Holiday Saved Successfully.";

                        $scope.refreshPublicHolidayModal();

                    }, function (response) {

                        $scope.showErrorFader = true;

                        $scope.addValidationMessage = "An error occurred please try again.";
                    });
            }
        };

        $scope.displayCalendar = false;

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }
        

        $scope.closeModal = function () {
            console.log("Close the modal");
        };
       
        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }

        function validateForm() {

            $scope.addValidationMessage = '';


            if ($scope.manage.thePublicHoliday.Title == "") {
                $scope.addValidationMessage = "Please enter a holiday title.";
            }

            else if ($scope.manage.thePublicHoliday.Date == "") {
                $scope.addValidationMessage = "Please enter a holiday date.";
            }
            
            else if ($scope.selectedCountries.Countries.length == 0) {
                $scope.addValidationMessage = "Please select a country.";
            }
           

        }

    }

})();