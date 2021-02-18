(function () {

    'use strict';


    angular
        .module("app.directives")
        .directive("myDirective", myDirective);


    function myDirective() {


        return {
            require: 'ngModel',
            link: function (scope, element, attrs, ngModelController) {
                ngModelController.$parsers.push(function (data) {
                    //convert data from view format to model format
                    //return data.toUpperCase(); //converted
                    return data.toLowerCase();
                });

                ngModelController.$formatters.push(function (data) {
                    //convert data from model format to view format

                    //if (data == null){ return ""; } 

                    //var newdate = $filter('date')(new Date(input),
                    //                            'MMM dd yyyy - HH:mm:ss');


                    return data; //converted
                });
            }
        }
    }
});

