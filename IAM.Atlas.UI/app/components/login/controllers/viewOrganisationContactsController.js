(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ViewOrganisationContactsCtrl', ViewOrganisationContactsCtrl);

    ViewOrganisationContactsCtrl.$inject = ['$scope', 'ModalService'];

    function ViewOrganisationContactsCtrl($scope, ModalService) {

        $scope.closeDialog = function () {
            ModalService.closeCurrentModal("organisationContactsModal");
        }
    }
})();

