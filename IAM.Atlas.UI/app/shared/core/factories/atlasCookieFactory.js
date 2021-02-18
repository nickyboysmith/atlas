(function () {

    'use strict';

    angular
        .module("app")
        .factory("AtlasCookieFactory", AtlasCookieFactory);


    function AtlasCookieFactory() {



        var atlasCookie = this;

        /*
         * Cookie Prefix
         */
        atlasCookie.cookiePrefix = "Atlas_";
        
        /**
         * 
         */
        function getCookie(cookieName) {
            var prefixCookieName = atlasCookie.cookiePrefix + cookieName;
            var theCookie = Cookies.get(prefixCookieName);
            if (theCookie === undefined) {
                return false;
            }
            return theCookie;
        }

        /**
         * Create a cookie
         * To use the options:
         * https://github.com/carhartl/jquery-cookie#cookie-options
         */
        function createCookie(cookieName, value, options) {
            var prefixCookieName = atlasCookie.cookiePrefix + cookieName;

            if (options === undefined) {
                Cookies.set(prefixCookieName, value);
            }
            if (options !== undefined) {
                Cookies.set(prefixCookieName, value, options);
            }
        }

        /**
         * 
         */
        function removeCookie(cookieName, options) {

            var prefixCookieName = atlasCookie.cookiePrefix + cookieName;

            if (options === undefined) {
                Cookies.remove(prefixCookieName);
            }
            if (options !== undefined) {
                Cookies.remove(prefixCookieName, options);
            }

        }


        return {
            getCookie: getCookie,
            createCookie: createCookie,
            removeCookie: removeCookie
        };

    }


})();