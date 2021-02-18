(function () {

    'use strict';

    angular
        .module("app")
        .controller("clientRescheduleCourseConfirmCtrl", clientRescheduleCourseConfirmCtrl);

    clientRescheduleCourseConfirmCtrl.$inject = ["$scope", "$window"];

    function clientRescheduleCourseConfirmCtrl($scope, $window) {

        $scope.closeAndRedirectToProfilePage = function() {
            $('button.close').last().trigger('click');
            $window.location.href = "/";
        }

    }

})();