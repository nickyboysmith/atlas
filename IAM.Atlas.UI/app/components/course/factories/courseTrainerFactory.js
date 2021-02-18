(function () {

    'use strict';

    angular
        .module("app")
        .factory("CourseTrainerFactory", CourseTrainerFactory);

    function CourseTrainerFactory() {

        /**
         * Loop through object to find the index of the property 
         * That holds the trainer id
         */
        this.findObjectID = function (objectToSearch, trainerID)
        {
            var theID;

            angular.forEach(objectToSearch, function (value, index) {
                if (value.Id === trainerID) {
                    theID = index;
                }
            });

            return theID;
        };

        return {
            find: this.findObjectID
        }
    }

})();