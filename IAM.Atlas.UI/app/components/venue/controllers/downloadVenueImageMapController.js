(function () {
    'use strict';

    angular
        .module('app')
        .controller('DownloadVenueImageMapCtrl', DownloadVenueImageMapCtrl);

    DownloadVenueImageMapCtrl.$inject = ['$scope', 'ModalService', "activeUserProfile", 'VenueImageMapService'];

    function DownloadVenueImageMapCtrl($scope, ModalService, activeUserProfile, VenueImageMapService) {
        
        $scope.saveAsFileName = $scope.venueImageMap.FileName;

        $scope.download = function (saveAsFileName) {
            return VenueImageMapService.downloadVenueImageMap($scope.venueId, activeUserProfile.UserId, saveAsFileName);
        }
    }
})();