(function () {

    'use strict';


    angular
        .module("app.directives")
        .directive("inputNumberValidation", inputNumberValidation);

    function inputNumberValidation() {
        return {
            restrict: 'C', //E = element, A = attribute, C = class, M = comment        
            link: function ($scope, element, attrs) {
                element.keyup(function (event) {
                    var inputValue = $(element).val();
                    var validatedInput = parseInt(inputValue);
                    /**
                     * Check that the number has been parsed
                     * & that it's greater than 1
                     * 
                     * If not set number to 1
                     */
                    if (isNaN(validatedInput) || validatedInput < 1) {
                        $(element).val(1);
                    } else {
                        $(element).val(validatedInput);
                    }
                });
            }
        };
    }

})();