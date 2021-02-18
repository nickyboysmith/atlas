(function () {

    'use strict';

    angular
        .module("app")
        .factory("UserDashBoardMeterFactory", UserDashBoardMeterFactory);

    function UserDashBoardMeterFactory() {

        /**
         * Loop through object to find the index of the property 
         * That holds the user id
         */
        this.findObjectID = function (objectToSearch, userID)
        {
            var theID;

            angular.forEach(objectToSearch, function (value, index) {
                if (value.Id === userID) {
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