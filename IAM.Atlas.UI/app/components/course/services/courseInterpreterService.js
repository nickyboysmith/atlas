(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseInterpreterService", CourseInterpreterService);


    function CourseInterpreterService($http) {


        var courseInterpreterService = this;

        /**
         * Get all the selected Interpreters
         */
        this.getSelectedInterpreters = function (courseID, organisationID) {
            return $http.get(apiServer + "/InterpreterLanguage/selected/" + courseID + "/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         *  Get all the available Interpreters
         */
        this.getAvailableInterpreters = function (courseID, organisationID) {
            return $http.get(apiServer + "/InterpreterLanguage/available/" + courseID + "/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /** 
        * Depending on the action 
        * Send to a different end point
        */
        this.updateAllocatedInterpreters = function (interpreterDetails) {

            return $http.post(apiServer + "/courseInterpreter", interpreterDetails)
               .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

    }

})();