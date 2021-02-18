(function () {

    'use strict';

    angular
        .module('app')
        .service('CloneReportService', CloneReportService);

    CloneReportService.$inject = ["$http"];

    function CloneReportService($http) {

        var action = this;

        action.cloneSourceReport = function (cloneData) {
            return $http.post(apiServer + "/report/clonereport", cloneData);
        };
    }
})();