(function () {

    'use strict';

    angular
        .module('app')
        .service('SchedulerControlService', SchedulerControlService);


    SchedulerControlService.$inject = ["$http"];

    function SchedulerControlService($http) {

        var schedulerControlService = this;

        /**
         * Get the schedulerControl
         */
        schedulerControlService.Get = function () {
            return $http.get(apiServer + "/schedulerControl/Get")
        };

        /**
        * updates the schedulerControl
        */
        schedulerControlService.Save = function (schedulerControlSettings) {
            return $http.post(apiServer + "/schedulerControl/Save", schedulerControlSettings)
        };

    }



})();