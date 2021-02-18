(function () {

    'use strict';

    angular
        .module("app")
        .service("OrganisationDisplayService", OrganisationDisplayService);

    OrganisationDisplayService.$inject = ["$http"];

    function OrganisationDisplayService($http) {

        this.getOrganisationConfiguration = function (organistionId) {
            var webServiceEndpoint = apiServer + "/configureorganisation/" + organistionId;
            return $http.get(webServiceEndpoint)
                .then(function (response) {
                    //this.organisationConfigurationSuccess;
                    return response.data;
                }
                , function (response) {
                    //this.organisationConfigurationError;
                    return response.data;
                }
                );
        };

        this.organisationConfigurationSuccess = function (response) {};

        this.organisationConfigurationError = function (response) {};

        this.getImageBase64 = function (url, theCallBack, outputFormat) {
            var img = new Image();
            img.crossOrigin = 'Anonymous';
            img.onload = function () {
                var canvas = document.createElement('CANVAS');
                var ctx = canvas.getContext('2d');
                canvas.height = this.height;
                canvas.width = this.width;
                ctx.drawImage(this, 0, 0);
                var dataURL = canvas.toDataURL(outputFormat || 'image/png');
                theCallBack(dataURL);
                canvas = null;
            };
            img.src = url;
        };

    }

})();