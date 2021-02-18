(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientCoursePaymentVerificationCtrl", ClientCoursePaymentVerificationCtrl);

    ClientCoursePaymentVerificationCtrl.$inject = ["$scope", "$sce", "$http"];

    function ClientCoursePaymentVerificationCtrl($scope, $sce, $http) {

        var formSubmitted = localStorage.getItem("hasBeenSubmitted");

        console.log(formSubmitted);
        console.log($("#verification").length);

        /**
         * 
         */
        $scope.trustSrc = function (src) {
            return $sce.trustAsResourceUrl(src);
        }

        /**
         * Session data
         */
        var sessionData = JSON.parse(sessionStorage.getItem("registrationDetails"));

        /**
         * 
         */
        $scope.threeDSecure = sessionData["3D"];

        /**
         * Before the response has been returned
         */
        if (formSubmitted === null) {


            /** 
             *
             */ 
            var check = setInterval(function () {
                var element = document.getElementById('form');
                if (element !== null) {
                    clearInterval(check);

                    localStorage.setItem("hasBeenSubmitted", "yes");

                    $(element).submit();

                }
            }, 500);
        } else {

            /**
             * Remove the localStorage item 
             * Telling browser form has been submitted
             */

            localStorage.removeItem("hasBeenSubmitted");

            /**
             * Get the Pares & MD from 3D Response
             */
            var PaRes = encodeURIComponent($("#verificationSecret").html());
            var MD = encodeURIComponent($("#verificationPublic").html());

            /**
             * Add session data
             */
            sessionData["3DResponse"] = {
                PaRes: PaRes,
                MD: MD
            };

            /**
             * Save Session Data to the window
             */
            sessionStorage.setItem("registrationDetails", JSON.stringify(sessionData));

            /**
             * remove the verfification container
             */
            $("#verification").remove();
            
           /**
            * Close the iFrame
            */
            parent.window.postMessage("removeTheiFrame", "*");

        }



    }

})();