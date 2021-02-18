(function () {

    'use strict';

    angular
        .module("app")
        .service("VenueImageMapService", VenueImageMapService);

    VenueImageMapService.$inject = ["$http"];

    function VenueImageMapService($http) {


        var venueImageMapService = this;

        /**
         * 
         */
        venueImageMapService.uploadVenueImageMap = function (venueImageMap) {
            return $http.post(apiServer + "/venueimagemap/uploadVenueImageMap", venueImageMap,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            );
        }

        venueImageMapService.updateVenueImageMap = function (venueImageMap) {
            return $http.post(apiServer + "/venueimagemap/updateVenueImageMap", venueImageMap);
        }

        venueImageMapService.getVenueImageMap = function (venueId) {
            return $http.get(apiServer + "/venueimagemap/getVenueImageMap/" + venueId);
        }

        venueImageMapService.downloadVenueImageMap = function (venueId, fileName) {
            return $http.get(apiServer + "/venueimagemap/downloadVenueImageMap/" + venueId);
        }

        venueImageMapService.downloadVenueImageMapBlob = function (venueId, userId, filename) {

            var fileURL = apiServer + "/venueimagemap/downloadVenueImageMap/" + venueId + "/" + userId;

            return $http({
                method: 'GET',
                url: fileURL,
                responseType: 'blob'
            });
        }

        venueImageMapService.VenueImageMapUrl = function (venueId, userId, filename) {

            var fileURL = apiServer + "/venueimagemap/downloadVenueImageMap/" + venueId + "/" + userId;

            return fileURL;
            //TODO: add a randomising variable to avoid file caching
        }

        venueImageMapService.downloadVenueImageMap = function (venueId, userId, filename) {
            
            var fileURL = apiServer + "/venueimagemap/downloadVenueImageMap/" + venueId + "/" + userId;

            $http({
                method: 'GET',
                url: fileURL,
                responseType: 'blob'
            })
            .then(
                function (response) {
                    var headers = response.headers();

                    //var filename = headers['x-filename'];
                    var contentType = headers['content-type'];
                    var fileType = headers['x-file-type'];
                    if (fileType.indexOf("jpg") > -1) {
                        contentType = "image/jpeg";
                    }
                    else if (fileType.indexOf("gif") > -1) {
                        contentType = "image/gif";
                    }
                    else if (fileType.indexOf("png") > -1) {
                        contentType = "image/png";
                    }
                    else if (fileType.indexOf("bmp") > -1) {
                        contentType = "image/bmp";
                    }
                    var linkElement = document.createElement('a');
                    try {
                        var blob = new Blob([response.data], { type: contentType });
                        var url = window.URL.createObjectURL(blob);

                        linkElement.setAttribute('href', url);
                        linkElement.setAttribute("download", filename);

                        var clickEvent;
                        if (window.navigator.msSaveOrOpenBlob) {
                            window.navigator.msSaveOrOpenBlob(blob, filename);
                        }
                        else {
                            clickEvent = new MouseEvent("click", {
                                "view": window,
                                "bubbles": true,
                                "cancelable": false
                            });
                            linkElement.dispatchEvent(clickEvent);
                        }
                    }
                    catch (ex) {
                        console.log(ex);
                    }
                }
                ,
                function (data) {
                    console.log(data);
                }
            );
        }

    }

})();