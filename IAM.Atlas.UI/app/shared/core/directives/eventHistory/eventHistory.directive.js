(function () {

    'use strict';


    angular
        .module("app.directives")
        .directive("eventHistory", eventHistory);


    function eventHistory() {

        return {
            scope: {
                typeName: "@",
                typeId: "@",
                courseReference: "@",
                courseTypeTitle: "@",

                courseDate: "@",
                updateClientHistory: "@"
            },
            restrict: 'EA', //E = element, A = attribute, C = class, M = comment         
            templateUrl: '/app/shared/core/directives/eventHistory/eventHistory.html',
            controller: "EventHistoryCtrl",
            link: function ($scope) {
                $scope.$watch('updateClientHistory', function () {
                    if ($scope.updateClientHistory == "true") {
                        if ($scope.typeName.toLowerCase() == "client") {
                            $scope.loadClientHistory();
                            $scope.loadClientHistoryOptions();

                        } else if ($scope.typeName.toLowerCase() == "course") {
                            $scope.loadCourseHistory();
                            $scope.loadCourseHistoryOptions();

                        }
                    }
                });
            }
        }

    }

})();