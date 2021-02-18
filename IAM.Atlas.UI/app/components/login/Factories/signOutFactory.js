(function () {

    'use strict';

    angular
        .module("app")
        .factory("SignOutFactory", SignOutFactory);

    SignOutFactory.$inject = ["$window", "AtlasCookieFactory"]

    function SignOutFactory($window, AtlasCookieFactory) {


        function signUserOut (requestPath, redirectPath) {
            sessionStorage.removeItem("userDetails");
            AtlasCookieFactory.removeCookie("userSession", { path: requestPath });
            $window.location.href = redirectPath;
        }

        /**
         * Remove the session 
         * for the user
         * go to the admin login
         */
        this.logOutAdmin = function () {
            signUserOut("/admin", "/admin/login");
        };

        /**
         * Remove the session 
         * for the user
         * go to the trainer login
         */
        this.logOutTrainer = function () {
            signUserOut("/trainer", "/trainer/login");
        };

        /**
         * Remove the session 
         * for the user
         * go to the client login
         */
        this.logOutClient = function () {
            signUserOut("/", "/login");
        };


        /**
         * Creeate the html 
         * For the signout container
         */
        this.signOutHTMLContainer = function () {
            var htmlContent = "";
            htmlContent = "<div id='SignOutContainer>";
            htmlContent = "</div> ";
            return 
        };


        return {
            admin: this.logOutAdmin,
            client: this.logOutClient,
            trainer: this.logOutTrainer
        }


    }



})();