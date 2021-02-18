(function () {

    'use strict';


    angular
        .module("app")
        .controller("DragDropUpdateCtrl", DragDropUpdateCtrl);

    DragDropUpdateCtrl.$inject = ["$scope", "CourseTrainerFactory"];

    function DragDropUpdateCtrl($scope, CourseTrainerFactory) {


        $scope.dropInNewArea = function (option, event, from, to) {



            /**
             * If there is no data associated 
             * With the selected option then do nothing further
             */
            if (option === null) {
                return false;
            }

            $scope.$parent.$parent.processDataMove(option, event, from, to);

        };

    }

})();