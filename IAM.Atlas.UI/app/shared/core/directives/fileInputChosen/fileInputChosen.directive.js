angular.module("app").directive('fileInputChosen', function () {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                var onChangeHandler = scope.$eval(attrs.fileInputChosen);
                element.bind('change', onChangeHandler);
            }
        };
    });
