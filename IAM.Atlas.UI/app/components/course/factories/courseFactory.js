(function () {

    'use strict';


    angular
        .module("app")
        .factory("CourseFactory", CourseFactory);



    function CourseFactory() {

        var course = this;


        /**
         * Put the factory methods in here
         */

        course.checkCookieExistance = function () {
            console.log("This factory might be able to be removed");
        };

       
        

    }
        
        

})();