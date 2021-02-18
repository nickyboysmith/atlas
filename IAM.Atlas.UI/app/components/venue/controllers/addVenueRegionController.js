(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddVenueRegionCtrl", AddVenueRegionCtrl);

    AddVenueRegionCtrl.$inject = ["$scope", "VenueService", "activeUserProfile"];

    function AddVenueRegionCtrl($scope, VenueService, activeUserProfile) {

        $scope.venue = {};
        $scope.selectedRegionId = -1;
        $scope.statusMessage = '';

        if ($scope.venueId)
        {
            VenueService.getVenue($scope.venueId, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        $scope.venue = response[0];
                    },
                    function errorCallback(response) {
                        $scope.statusMessage = 'Error when getting Venue.';
                    }
                );
        }

        $scope.addRegion = function (selectedRegionId) {
            VenueService.addVenueRegion($scope.venueId, selectedRegionId, activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        if (response.data == true) {
                            $scope.statusMessage = 'Region added to venue.';
                            $scope.loadVenueModal();
                        }
                        else {
                            $scope.statusMessage = 'Only administrators can add a Region to a Venue.';
                        }
                    },
                    function errorCallback(response) {
                        $scope.statusMessage = 'An Error occurred, please contact support.';
                    }
                );
        }

        $scope.filterAllItem = function (item) {
            var showItem = true;
            if (item.name == '*ALL*') showItem = false;
            return showItem;
        }
    }

})();