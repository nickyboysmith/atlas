(function () {

    'use strict';

    angular
        .module('app')
        .controller('VenueCostCtrl', VenueCostCtrl);

    VenueCostCtrl.$inject = ["$scope", "VenueCostService", "VenueCostTypeService", "ModalService", "DateFactory"];

    function VenueCostCtrl($scope, VenueCostService, VenueCostTypeService, ModalService, DateFactory) {

        $scope.modalService = ModalService;
        $scope.venueCostService = VenueCostService;

        $scope.organisationId = -1;
        $scope.displayToCalendar = false;
        $scope.displayFromCalendar = false;
        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        $scope.venueCost = {};
        $scope.venueCost.VenueId = $scope.venue.id;
        
        $scope.refreshVenueCostTypes = function () {
            return $scope.venueCostTypeService.getVenueCostTypes($scope.organisationId)
                .then(function (data, status, headers, config) {
                    $scope.venueCostTypes = data;
                }, function(data, status, headers, config) {
                });
        }

        $scope.venueCostTypes = {};
        $scope.venueCostTypeService = VenueCostTypeService;
        if ($scope.venue.selectedOrganisation != undefined && $scope.venue.id != undefined) {
            $scope.organisationId = Number($scope.venue.selectedOrganisation);
            $scope.refreshVenueCostTypes();
        }
        
        $scope.addVenueCostType = function () {
            $scope.selectedOrganisation = $scope.venue.selectedOrganisation;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Venue Cost Types",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/venueCostType/update.html",
                controllerName: "VenueCostTypeCtrl",
                cssClass: "UpdateVenueCostTypeModal",
                buttons: {
                label: 'Close',
                cssClass: 'closeModalButton',
                action: function (dialogItself) {
                    dialogItself.close();
                }
            }
            });
        }

        $scope.getName = function (venueCostTypeId) {
            var name = "Unknown";
            for (var i = 0; i < $scope.venueCostTypes.length; i++)
            {
                if ($scope.venueCostTypes[i].Id == venueCostTypeId) {
                    name = $scope.venueCostTypes[i].Name;
                }
            }
            return name;
        }

        $scope.toggleFromCalendar = function () {
            $scope.displayFromCalendar = !$scope.displayFromCalendar;
        }

        $scope.toggleToCalendar = function () {
            $scope.displayToCalendar = !$scope.displayToCalendar;
        }

        $scope.saveVenueCost = function () {
            if ($scope.venueCost.ValidFromDate &&
                $scope.venueCost.ValidToDate &&
                $scope.venueCost.Cost &&
                $scope.venueCost.CostTypeId &&
                $scope.venueCost.VenueId)
            {
                $scope.venueCostService.saveVenueCost($scope.venueCost)
                        .then(function (data) {

                            $scope.showSuccessFader = true;
                       
                            $scope.saveMessage = "Venue Cost saved"
                            $scope.refreshVenueModalVenueCosts();
                        });
            }
            else {
                alert('Please fill in all the fields.');
            }
        }

        $scope.getToday = function(){
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth()+1; //January is 0!
            var yyyy = today.getFullYear();

            if(dd<10) {
                dd='0'+dd
            } 

            if(mm<10) {
                mm='0'+mm
            } 

            today = dd+'/'+mm+'/'+yyyy;
            return today;
        }

        $scope.getAYearFromToday = function(){
            var yearFromToday = new Date();
            var dd = yearFromToday.getDate();
            var mm = yearFromToday.getMonth()+1; //January is 0!
            var yyyy = yearFromToday.getFullYear()+1;

            if(dd<10) {
                dd='0'+dd
            } 

            if(mm<10) {
                mm='0'+mm
            } 

            yearFromToday = dd+'/'+mm+'/'+yyyy;
            return yearFromToday;
        }

        $scope.formatDate = function (date) {
            return DateFactory.formatDateSlashes(date);
        };

        $scope.parseDate = function (s) {
            return DateFactory.parseDateDashes(s);
        };

        if($scope.addingVenueCost)
        {
            $scope.venueCost = {};
            $scope.venueCost.VenueId = $scope.venue.id;
            $scope.selectedVenueCost = -1;
            $scope.venueCost.ValidFromDate = $scope.getToday();
            $scope.venueCost.ValidToDate = $scope.getAYearFromToday();
        }

        if ($scope.selectedVenueCost)
        {
            if ($scope.selectedVenueCost > 0) {
                // load the venueCost for editing
                
                if ($scope.organisationId.substring)    // is organisationId a string?  check if this function exists off the var
                {
                    $scope.organisationId = parseInt(Number($scope.organisationId));
                }
                $scope.venueCostService.getVenueCost($scope.selectedVenueCost)
                        .then(function (data) {
                            $scope.venueCost = data;

                            $scope.venueCost.ValidFromDate = $scope.formatDate(new Date(Date.parse($scope.venueCost.ValidFromDate)));
                            $scope.venueCost.ValidToDate = $scope.formatDate(new Date(Date.parse($scope.venueCost.ValidToDate)));
                        });
            }
        }
    }
})();