(function () {

    'use strict';

    angular
        .module("app.directives")
        .directive('formatDateIam', function (dateFilter) {
            return {
                require: 'ngModel',
                link: function (scope, elm, attrs, ctrl) {

                    var dateFormat = attrs['formatDateIam'] || 'dd-MMM-yyyy';

                    ctrl.$formatters.push(function (modelValue) {
                        return dateFilter(modelValue, dateFormat);
                    });
                }
            };
        })

})();