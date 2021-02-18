(function () {


    'use strict';

    angular
        .module('app.controllers')
        .controller('TrainerHomeCtrl', TrainerHomeCtrl);

    TrainerHomeCtrl.$inject = ["$scope", "$window", "$location", "$uibModal", "Idle", "SystemControlService", "SignOutFactory", "TrainerProfilePictureService", "TrainerProfilePictureFactory", "activeUserProfile"];

    function TrainerHomeCtrl($scope, $window, $location, $uibModal, Idle, SystemControlService, SignOutFactory, TrainerProfilePictureService, TrainerProfilePictureFactory, activeUserProfile) {
       
        /**
         * Get the trainer Id
         * From the active user profile
         */
        $scope.trainerId = activeUserProfile.TrainerId;

        /**
         * Get the profile picture from the web api
         */
        TrainerProfilePictureService.getProfilePicture($scope.trainerId)
            .then(function (response) {
                $scope.$root.trainerProfilePicture = TrainerProfilePictureFactory.convert(response)
            }, function (response) {
                $scope.$root.trainerProfilePicture = TrainerProfilePictureFactory.get();
            });

        /**
         * Get the idle and timeout settings
         */
        SystemControlService.Get()
            .then(
                function (reason) {
                    console.log("Success");
                    console.log(reason.data);

                    // check for nulls
                    Idle.setIdle(reason.data.SystemInactivityTimeout - reason.data.SystemInactivityWarning);
                    Idle.setTimeout(reason.data.SystemInactivityWarning);

                },
                function (reason) {
                    console.log(reason);
                }
            );

        /**
         * Handles Idle and Timeout  Section
         */
        function closeModals() {
            if ($scope.warning) {
                $scope.warning.close();
                $scope.warning = null;
            }
        }

        $scope.$on('IdleStart', function () {

            // the user appears to have gone idle
            closeModals();

            $scope.warning = $uibModal.open({
                templateUrl: '/app/shared/navigation/warning-dialog.html',
                windowClass: 'modal-danger'
            });

        });

        $scope.$on('IdleWarn', function (e, countdown) {
            // follows after the IdleStart event, but includes a countdown until the user is considered timed out
            // the countdown arg is the number of seconds remaining until then.
            // you can change the title or display a warning dialog from here.
            // you can let them resume their session by calling Idle.watch()
        });

        $scope.$on('IdleTimeout', function () {
            // the user has timed out (meaning idleDuration + timeout has passed without any activity)
            // this is where you'd log them

            closeModals();

            var path = $location.$$absUrl;

            if (path.indexOf("/trainer") > -1) {

                SignOutService.SignOut(activeUserProfile.UserId)
                    .then(function (data) {

                        SignOutFactory.trainer();

                    }, function (data) {

                    });

            }


        });

        $scope.$on('IdleEnd', function () {
            // the user has come back from AFK and is doing stuff. if you are warning them, you can use this to hide the dialog
            closeModals();

        });

        $scope.$on('Keepalive', function () {
            // do something to keep the user's session alive
        });
        /**
        * End Handles Idle and Timeout  Section
        */

        // If browser is closed (x) update ExpiresOn in LoginSession to Now() and Delete from Local Storage
        /*
        $scope.onExit = function () {

            //SignOutService.SignOut(activeUserProfile.UserId)
            //.then(function (data) {

            SignOutFactory.trainer();

            //}, function (data) {

            //});

        };

        // If browser is closed update 
        $window.onbeforeunload = $scope.onExit;
       */
    }

})();