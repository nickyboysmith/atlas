(function () {

    'use strict';

    angular
        .module("app")
        .factory("CourseInterpreterFactory", CourseInterpreterFactory);

    function CourseInterpreterFactory() {

        /**
         * Loop through object to find the index of the property 
         * That holds the Interpreter id
         */
        this.findObjectID = function (objectToSearch, InterpreterID)
        {
            var theID;

            angular.forEach(objectToSearch, function (value, index) {
                if (value.Id === InterpreterID) {
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