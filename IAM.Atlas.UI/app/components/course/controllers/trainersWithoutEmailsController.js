(function () {
    'use strict';
    angular
        .module('app')
        .controller('TrainersWithoutEmailsCtrl', ['$scope', '$filter', 'activeUserProfile', 'DateFactory', 'ModalService', TrainersWithoutEmailsCtrl]);

    function TrainersWithoutEmailsCtrl($scope, $filter, activeUserProfile, DateFactory, ModalService) {

        $scope.trainersWithoutEmailsCollection = $scope.trainersWithoutEmails;

        $scope.formatDate = function (date) {
            if (date) {
                return DateFactory.formatDateddMONyyyy(DateFactory.parseDate(date));
            }
        }

        $scope.openTrainerModal = function (trainerId) {
            $scope.trainerId = trainerId;
            $scope.isModal = true;
            ModalService.displayModal({
                scope: $scope,
                title: "Trainer Details",
                cssClass: "trainerEditModal",
                filePath: "/app/components/trainer/about/view.html",
                controllerName: "TrainerAboutCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };
    }
})();