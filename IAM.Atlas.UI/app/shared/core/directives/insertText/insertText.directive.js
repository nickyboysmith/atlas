'use strict';

angular.module('app.directives')

.directive('myText', ['$rootScope', function($rootScope) {
    return {
    require: 'ngModel', // request our containing ng-model controller
    link: function(scope, element, attrs, ngModelCtrl) { // DI
        $rootScope.$on('insertText', function(e, val) {
            var domElement = element[0];

            if (document.selection) {
                domElement.focus();
                var sel = document.selection.createRange();
                sel.text = val;
                domElement.focus();
            } else if (domElement.selectionStart || domElement.selectionStart === 0) {
                var startPos = domElement.selectionStart;
                var endPos = domElement.selectionEnd;
                var scrollTop = domElement.scrollTop;
                domElement.value = domElement.value.substring(0, startPos) + val + domElement.value.substring(endPos, domElement.value.length);
                domElement.focus();
                domElement.selectionStart = startPos + val.length;
                domElement.selectionEnd = startPos + val.length;
                domElement.scrollTop = scrollTop;
            } else {
                domElement.value += val;
                domElement.focus();
            }
            // inform ng-model that the value has changed
            ngModelCtrl.$setViewValue(domElement.value);
        });
    }
}
}])