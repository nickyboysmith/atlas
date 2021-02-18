(function () {

    angular
        .module("app")
        .service("EmailConfirmationService", EmailConfirmationService);


    EmailConfirmationService.$inject = ["$http", "$timeout", "$window",  "ModalService", "$rootScope"];

    function EmailConfirmationService($http, $timeout, $window, ModalService, $rootScope) {

        var emailConfirmation = this;

        emailConfirmation.updateEmailConfirmation = function (ReferenceNumber) {

           
            $http.post(apiServer + '/Client/ConfirmEmail', {reference:ReferenceNumber})
           
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);

                        ModalService.displayModal({
                            scope: $rootScope,
                            title: "Client Email Confirmation",
                            cssClass: "emailConfirmationModal",
                            filePath: "/app/components/emailConfirmation/confirm.html",
                            controllerName: "ShowEmailConfirmationCtrl"
                        });


                    $timeout(function () {
                        ModalService.closeCurrentModal("emailConfirmationModal");
                        $window.location.href = "/login";
                    }, 3000);

                },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                        $window.location.href = "/login";
                    }
            );

        }
    }
})();