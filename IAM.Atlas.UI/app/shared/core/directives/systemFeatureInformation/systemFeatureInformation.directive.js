(function () {

    'use strict';


    angular
        .module("app.directives")
        .directive("systemFeatureInformation", systemFeatureInformation);


    function systemFeatureInformation() {

        return {
            scope: {
                title: "@",
                controller: "@",
                addFavourite: "=",
                openInModal: "=",
                viewPath: "@",
                pageName: "@" // Used for the Information Name
            },
            restrict: 'EA', //E = element, A = attribute, C = class, M = comment         
            templateUrl: '/app/shared/core/directives/systemFeatureInformation/view.html',
            controller: "SystemFeatureInformationDirectiveCtrl"
        }

    }


})();