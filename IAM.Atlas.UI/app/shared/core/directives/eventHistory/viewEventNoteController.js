(function () {
    'use strict';

    angular
        .module('app')
        .controller('viewEventNoteCtrl', viewEventNoteCtrl);

    viewEventNoteCtrl.$inject = ['$scope', '$location', '$window', '$http', '$sce', 'activeUserProfile']

    function viewEventNoteCtrl($scope, $location, $window, $http, $sce, activeUserProfile) {
        
        $scope.selectedNote = $scope.$parent.selectedNote;

        $scope.$parent.selectedNote.DisplayDetailsLabel = $scope.$parent.typeName;

        $scope.trustAsHtml = $sce.trustAsHtml;

        if ($scope.$parent.typeName.toLowerCase() == 'client') {
            $scope.selectedNote.DisplayDetails = $scope.$parent.selectedNote.ClientName + " (Id: " + $scope.$parent.selectedNote.ClientId + ")" 
        }
        else if ($scope.$parent.typeName.toLowerCase() == 'course') {
            $scope.selectedNote.DisplayDetails = "Ref: " + $scope.$parent.courseReference + " " + $scope.$parent.courseDate
            $scope.selectedNote.courseTypeTitle = $scope.$parent.courseTypeTitle
        }
    }

})();