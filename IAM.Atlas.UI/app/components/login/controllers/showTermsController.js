(function () {

    'use strict';

    angular
        .module("app")
        .controller("ShowTermsCtrl", ShowTermsCtrl);

    ShowTermsCtrl.$inject = ["$scope", "ClientRegistrationService"];

    function ShowTermsCtrl($scope, ClientRegistrationService) {

        var organisationId = $scope.$parent.registrationDetails.Login[0]["OrganisationIds"]["Id"];

        ClientRegistrationService.getOnlineTerms(organisationId)
        .then(
            function (response) {
                $("#addTermsToDOM").html(response.data);
            },
            function (reason) {
                console.log(reason);
            }
        );

    }

})();