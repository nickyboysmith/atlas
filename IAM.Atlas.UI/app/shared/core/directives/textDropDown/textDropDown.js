'use strict';

angular.module('app.directives')

.directive('textDropDown', function () {

    return {
        require: '^ngModel',
        scope: {
            items: "=",
            showItems: "@",
            showOptionsClicked: "@",
            cssClass: "@"
        },
        templateUrl: '/app/shared/core/directives/textDropDown/textDropDown.html',
        link: function(scope, element, attrs, ngModel){
            scope.updateModel = function (item) {
                scope.txtItem = item;
                ngModel.$setViewValue(item);
                scope.showItems = false;
            }
            scope.showOptionsClicked = function () {
                scope.showItems = !scope.showItems;
            }
            scope.$watch(function () {
                //return ngModel.$modelValue;
                if (scope.txtItem != ngModel.$modelValue) {
                    scope.txtItem = ngModel.$modelValue;
                    ngModel.$setViewValue(ngModel.$modelValue);
                }
            })
            ngModel.$viewChangeListeners.push(function () {
                scope.$eval(attrs.ngChange);
            });
        }
    };
});