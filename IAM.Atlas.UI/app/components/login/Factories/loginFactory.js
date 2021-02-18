(function () {

    'use strict';

    angular
        .module("app")
        .factory("LoginFactory", LoginFactory);

    function LoginFactory() {

        /**
         * If the path isnt the same
         * as what it expects it to be redirect 
         * Back to home page
         * 
         * @Todo: Include domain name check in the future
         */
        this.preventDirectAccess = function ($document, $window, allowedPathArray) {
            var fromUrl = $document[0].referrer;
            var fromUrlArray = fromUrl.split("/");
            var lastPage = fromUrlArray[(fromUrlArray.length - 1)];

            /**
             * Check to see if the page has come from 
             * The previous page
             * 
             */
            if (allowedPathArray.indexOf(lastPage) === -1) {
                $window.location.href = "/";
                exit();
            }

        };

        return {
            preventDirectAccess: this.preventDirectAccess
        };

    }


})();