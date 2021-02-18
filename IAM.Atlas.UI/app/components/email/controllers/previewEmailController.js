(function () {

    'use strict';

    angular
        .module("app")
        .controller("PreviewEmailCtrl", PreviewEmailCtrl);

    PreviewEmailCtrl.$inject =["$scope", "SendEmailService", "ModalService", "activeUserProfile"];


    function PreviewEmailCtrl($scope, SendEmailService, ModalService, activeUserProfile) {


        /* uspSendMail is hardcoded to replaces these and only these tags upon sending an email. 
           Can remove from uspSendMail if the preview content is passed in. 
           Needs data driven solution as new tags will currently require a change to code base */
                
        $scope.preview = $scope.email.content.replace(/<!FirstName!>/g, $scope.client.FirstName);
        $scope.preview = $scope.preview.replace(/<!Surname!>/g, $scope.client.Surname);
    }

})();