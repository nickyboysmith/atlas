(function () {

    'use strict';

    angular
        .module("app.directives")
        .directive('validDate', ['$filter', function ($filter)
            {
                return {
                    restrict: 'A',
                    require: 'ngModel',
                    link: function (scope, element, attrs, control) {
                        control.$parsers.push(function (viewValue) {
                            var newDate = control.$viewValue;
                            control.$setValidity("invalidDate", true);

                            if (typeof newDate === "object" || newDate == "")
                                return newDate;  // pass through if we clicked date from popup

                            var dateToTest = new Date(newDate).toLocaleDateString();;

                            if (dateToTest == "Invalid Date") {
                                control.$setValidity("invalidDate", false);
                                control.$setValidity("valid", false);
                                control.validationMessage = "Invalid Date";
                            }
                            return viewValue;
                        });
                    }
                };
        }])

})();