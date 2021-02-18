(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('OrganisationDisplayCtrl', OrganisationDisplayCtrl);

    OrganisationDisplayCtrl.$inject = ["$scope", "$window", "$compile", "ModalService", "OrganisationDisplayService", "OrganisationDisplaySortService"];

    function OrganisationDisplayCtrl($scope, $window, $compile, ModalService, OrganisationDisplayService, OrganisationDisplaySortService)
    {

        /**
         * Set logo src attribute to empty
         */
        $scope.organisationLogo = "";

        /**
         * Pull from the active userObject
         */
        $scope.organisationId = 100;

        $scope.organisationDisplay = OrganisationDisplayService.getOrganisationConfiguration($scope.organisationId);
        $scope.organisationDisplay
            .then(function (response) {

                $scope.organisationConfig = OrganisationDisplaySortService.sortConfigurationOptions(response);

                //$("#organisationLogo").css("border", "0px");

                if ($scope.organisationConfig.logo !== undefined) {
                    $scope.organisationLogo = apiServerImagePath + "/" + $scope.organisationConfig.logo.imageSrc;
                    $("#organisationLogo").css($scope.organisationConfig.logo.css);
                }

                if ($scope.organisationConfig.logo === undefined) {
                    $("#organisationLogo").hide();
                    $("#organisationName").css("width", "100%");
                }

                //if ($scope.organisationConfig.displayName !== undefined) {
                //    $scope.organisationDisplayName = $scope.organisationConfig.displayName.text;
                //    $("#organisationName").css($scope.organisationConfig.displayName.css);
                //}

                //if ($scope.organisationConfig.border !== undefined) {
                //    $("#organisationDisplay").css($scope.organisationConfig.border.css);
                //}

                //if ($scope.organisationConfig.background !== undefined) {
                //    $("#organisationDisplay").css($scope.organisationConfig.background.css);
                //}

                

            }, function (data) { });

        /**
         * 
         */


        /**
      * Open the Add Trainer Vehicle Modal
      */
        $scope.openConfigureOrganisationOptions = function ($event) {
            ModalService.displayModal({
                scope: $scope,
                title: "Configure Organisation",
                closable: true,
                filePath: "app/components/organisation/Update.html",
                controllerName: "ConfigureOrganisationCtrl",
                cssClass: "AtlasModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };




        $scope.xopenConfigureOrganisationOptions = function ($event) {
            if ($event.originalEvent.detail === 2) {
                BootstrapDialog.show({
                    scope: $scope,
                    title: "Configure Organisation",
                    closable: true,
                    closeByBackdrop: false,
                    closeByKeyboard: false,
                    draggable: true,
                    cssClass: "AtlasModal",
                    message: function (dialog) {
                        var pageToLoad = dialog.getData('pageToLoad');
                        return $compile('<div ng-app="app" ng-controller="ConfigureOrganisationCtrl" ng-include="\'' + pageToLoad + '.html\'"></div>')($scope);
                    },
                    data: {
                        'pageToLoad': "app/components/organisation/Update.html"
                    },
                    onshown: function () {

                        /**
                         * Bit hacky but for now it gets it done
                         * The div below:
                         * 
                         * ".companyLogo"
                         * ".image-preview"
                         * Now exist.
                         * in the "configureOrganisationController" set the "companyImage" property on the window
                         * 
                         * 
                         */
                        $(".companyLogo > img").attr("src", $window.companyImage);
                        $(".image-preview > img").attr("src", $window.companyImage);

                        /**
                         * Removes the window.company property
                         */
                        delete $window.companyImage;

                    }
                });
            }


        };

    }


})();