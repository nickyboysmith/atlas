(function () {
    'use strict';

    angular
        .module('app')
        .controller('addPaymentNoteCtrl', addPaymentNoteCtrl);

    addPaymentNoteCtrl.$inject = ['$scope', '$location', '$window', '$http', 'activeUserProfile']

    function addPaymentNoteCtrl($scope, $location, $window, $http, activeUserProfile) {

        $scope.noteSaved = false;
        $scope.paymentNote = {};
        $scope.noteTypes = {};

        
        /**
         * Set the user Id on the activeProfileUser object
         */
        $scope.paymentNote.UserId = activeUserProfile.UserId;
        $scope.paymentNote.PaymentId = $scope.paymentId;
        $scope.paymentNote.PaymentAmount = $scope.$parent.paymentDetail.PaymentAmount;


        $scope.saveNote = function () {
            $scope.validationMessage = '';
            $http.post(apiServer + '/paymentNote/', $scope.paymentNote)
                .then(
                    function (data) {
                        $scope.noteSaved = true;
                        if ($scope.getNotes) { // refresh the list of notes in the parent modal
                            $scope.getNotes();
                        }
                }, function (data) {
                    // called asynchronously if an error occurs
                    $scope.validationMessage = "An error occurred please try again.";
                    $scope.noteSaved = false;
                });
        }

        $scope.loadNoteTypes = function () {
            $http.get(apiServer + '/PaymentNote/GetTypes')
                .then(
                    function (data) {
                    // this callback will be called asynchronously
                    // when the response is available

                    $scope.noteTypes = data;
                    $scope.paymentNote.NoteTypeId = $scope.noteTypes[0].Id;
                }, function(data) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }
        
        $scope.loadNoteTypes();

    }



})();