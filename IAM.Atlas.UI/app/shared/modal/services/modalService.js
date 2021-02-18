(function () {

    'use strict';

    angular
        .module('app')
        .service('ModalService', ModalService);

    ModalService.$inject = ["$compile"];

    function ModalService($compile) {

        var modalService = this;

        //modalOptions: scope, title, cssClass, controllerName, buttons, filePath
        modalService.displayModal = function (modalOptions) {
            BootstrapDialog.show({
                scope: modalOptions.scope,
                title: modalOptions.title,
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                cssClass: modalOptions.cssClass,
                message: function (dialog) {
                    var pageToLoad = dialog.getData('pageToLoad');
                    return $compile('<div ng-app="app" ng-controller="' + modalOptions.controllerName + '" ng-include="\'' + pageToLoad + '\'"></div>')(modalOptions.scope);
                },
                onhide: modalOptions.onhide,
                buttons: [modalOptions.buttons],
                data: {
                    'pageToLoad': modalOptions.filePath,
                }
            });
            
        };

        modalService.getCurrentModals = function () {
            var returnData = 'Open modals: ';
            angular.forEach(BootstrapDialog.dialogs, function (dialog, id) {
               // if (dialog.defaultOptions.cssClass === modalClass) {
                    returnData = returnData + dialog.defaultOptions.title + '/';
                //};
            });

            return returnData;
        }


        /**
         * Close the current modal on click
         * [Parameter] modalClass
         */
        modalService.closeCurrentModal = function (modalClass) {
            angular.forEach(BootstrapDialog.dialogs, function (dialog, id) {
                if (dialog.defaultOptions.cssClass === modalClass) {
                    dialog.close();
                };
            });
        };

        /** Get Modal by modalClass */
        modalService.getCurrentModalByClass = function (modalClass) {
            angular.forEach(BootstrapDialog.dialogs, function (dialog, id) {
                if (dialog.defaultOptions.cssClass === modalClass) {
                    return dialog;
                };
            });
        };

    }
})();