(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerBookingsService", TrainerBookingsService);

    TrainerBookingsService.$inject = ["$http"];

    function TrainerBookingsService($http) {

        var trainerBookingService = this;

        /**
         * Get the list of bookings
         * For a trainer between a certain date
         */
        trainerBookingService.getBookings = function (dateRange) {
            return $http.post(apiServer + "/trainerBookings/getSelected", dateRange);
        };

        trainerBookingService.DownloadCourseRegister = function (UserId, CourseRegisterDocumentId) {
            var fileURL = apiServer + "/trainerBookings/DownloadCourseRegister/" + UserId + "/" + CourseRegisterDocumentId;

            $http({
                method: 'GET',
                url: fileURL,
                responseType: 'blob'
            })
            .then(
                function (response) {
                    var headers = response.headers();

                    var filename = headers['x-filename'];
                    var contentType = headers['content-type'];
                    var fileType = headers['x-file-type'];
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
                    } catch (ex) {
                        console.log(ex);
                    }

                    return response.data;
                }
                , function (response, status) { return response.data; }
            );
        }












    }




})();