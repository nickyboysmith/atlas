(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerAttendanceService", TrainerAttendanceService);

    TrainerAttendanceService.$inject = ["$http"];

    function TrainerAttendanceService($http) {

        var attendance = this;

        attendance.getTrainerAttendance = function (trainerAttendanceOptions) {
            return $http.post(apiServer + "/TrainerAttendance/GetCourses/", trainerAttendanceOptions);
        };

        attendance.saveTrainerAttendance = function (trainerAttendance) {
            return $http.post(apiServer + "/TrainerAttendance", trainerAttendance);
        };


    }

})();