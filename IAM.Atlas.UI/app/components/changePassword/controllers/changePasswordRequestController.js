(function () {

    'use strict';

    angular
    .module('app.controllers')
    .controller('ChangePasswordRequestCtrl', ChangePasswordRequestCtrl);

    ChangePasswordRequestCtrl.$inject = ['ChangePasswordRequestService', '$scope'];

    function ChangePasswordRequestCtrl(ChangePasswordRequestService, $scope) {
        $scope.requestSent = false;
        $scope.user = {};
        $scope.sendEmailRequest = function () {
            $scope.user.statusMessage = "";
            if ($scope.user.loginId && $scope.user.loginId.length > 2) {
                ChangePasswordRequestService.sendPasswordChangeToWebAPI($scope.user)
                    .then(
                            function successCallback(response) {
                                $scope.user.statusMessage = response;
                                $scope.user.requestSent = true;
                                $scope.requestSent = true;
                            }
                            ,
                            function errorCallback() {
                                $scope.user.statusMessage = "An error occured. Please contact your administrator.";
                            }
                     );
            }
            else {
                $scope.user.statusMessage = "Please enter a valid Login Id";
            }
        };
    }
})();