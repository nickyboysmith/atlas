(function () {

    "use strict";

    angular
        .module("app")
            .service("CourseTrainersService", CourseTrainersService);

    CourseTrainersService.$inject = ["$http"];

    function CourseTrainersService($http) {

        var courseTrainersService = this;


        this.getCourses = function (searchCriteria) {
            return $http.post(apiServer + "/coursetrainers", searchCriteria)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

    }
})();