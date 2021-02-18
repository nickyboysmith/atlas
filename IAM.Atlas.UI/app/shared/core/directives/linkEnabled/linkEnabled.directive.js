'use strict';

angular.module('app.directives')
.directive('myLink', function () {
    return {
        restrict: 'A',
        scope: {
            enabled: '=myLink'
        },
        link: function (scope, element, attrs) {
            element.bind('click', function (event) {
                if (!scope.enabled) {
                    event.preventDefault();
                }
            });
        }
    };
});