(function () {

    angular
        .module("app")
        .factory("UserFactory", UserFactory);

    function UserFactory() {

        this.getRoleSlug = function (role) {

            if (role.indexOf("Trainer") > -1) {
                return "trainer";
            }

            if (role.indexOf("User") > -1) {
                return "user";
            }

            if (role.indexOf("Client") > -1) {
                return "client";
            }

            if (role.indexOf("Administrator") > -1) {
                return "administrator";
            }


            if (role.indexOf("Atlas") > -1) {
                return "system_administrator";
            }

        };

        /**
         * 
         */
        this.processReponse = function (response) {



        };

        return {
            getRole: this.getRoleSlug,
            process: this.processReponse
        };

    }


})();