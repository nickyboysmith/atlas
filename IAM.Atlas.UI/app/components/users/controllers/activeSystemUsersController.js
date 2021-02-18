(function () {
    'use strict';

    angular
        .module('app')
        .controller('ActiveSystemUsersCtrl', ActiveSystemUsersCtrl);

    ActiveSystemUsersCtrl.$inject = ["$scope", "UserService", "activeUserProfile", "ModalService"];

    function ActiveSystemUsersCtrl($scope, UserService, activeUserProfile, ModalService) {
                
        $scope.activeUsers = {};

        $scope.getActiveSystemSupportUsersForOrganisation = function () {            
            UserService.getActiveSystemUsers(activeUserProfile.selectedOrganisation.Id, activeUserProfile.UserId)
                 .then(
                     function successCallback(data) {
                         $scope.activeUsers = data;
                     },
                     function errorCallback(data) {

                     }
                 );
        };        

        $scope.getActiveSystemSupportUsersForOrganisation();
    }

})();