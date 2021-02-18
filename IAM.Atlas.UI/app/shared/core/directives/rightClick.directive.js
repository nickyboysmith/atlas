(function () {

    'use strict';


    angular
        .module("app")
        .directive("atlasRightClick", atlasRightClick);


    function atlasRightClick($parse) {

        return function (scope, element, attrs) {
            var fn = $parse(attrs.atlasRightClick);
            element.bind('contextmenu', function (event) {
                scope.$apply(function () {
                    event.preventDefault();
                    fn(scope, { $event: event });
                });
            });
        };

    }


})();