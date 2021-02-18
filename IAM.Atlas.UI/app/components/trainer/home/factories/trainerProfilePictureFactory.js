(function () {

    'use strict';

    angular
        .module('app')
        .factory('TrainerProfilePictureFactory', TrainerProfilePictureFactory);

    function TrainerProfilePictureFactory() {

        var profilePicturePlaceholder = "/app_assets/images/profile-picture-large.png";

        /**
         * Convert the picture name to a readble URL
         */
        this.convertPictureName = function (profilePicture) {

            
            if (profileImage === null || profilePicture == undefined) {
                return "/app_assets/images/profile-picture-large.png";
            }
            else {
                var profileImage = profilePicture[0]["PictureName"];
                return apiServerImagePath + "/" + profileImage;
            }
        };

        /**
         * Get the placeholder image
         * If the user doesnt have profile picture stored
         */
        this.getPlaceholder = function () {
            return profilePicturePlaceholder;
        };

        return {
            get: this.getPlaceholder,
            convert: this.convertPictureName
        }
    }

})();