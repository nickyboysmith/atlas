(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerProfilePictureService", TrainerProfilePictureService);

    TrainerProfilePictureService.$inject = ["$http"];


    function TrainerProfilePictureService($http) {

        var profile = this;

        /**
         * Gret the profile pic url from the db based on the users profile
         */
        profile.getProfilePicture = function (trainerId) {
            return $http.get(apiServer + "/trainer/getprofilepicture/" + trainerId)
                .then(function () {}, function() {});
        };

    }


})();