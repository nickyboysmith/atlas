(function () {

    'use strict';

    angular
        .module("app")
        .controller("DocumentUploadCtrl", DocumentUploadCtrl);

    DocumentUploadCtrl.$inject = ["$scope"];

    function DocumentUploadCtrl($scope) {

        /**
         * Simple function to convert file
         * from bytes to KB or MB
         */
        $scope.convertToMegabytes = function (fileSize) {
            var sizeType = "Kb";
            var size = (fileSize / 1000);
            if (size < 1) {
                size = 1;
            } else if (size < 999.999) {
                size = (size).toFixed();
                sizeType = "Kb";
            } else {
                size = (size / 1000).toFixed(2);
                sizeType = "Mb";
            }
            return size + "" + sizeType;
        }

        /**
         * 
         */
        $scope.formatFileName = function (string) {
            return string.replace(/[^a-z0-9-_.]/gi, '');
        }


        /**
         * Set the maximum filesize on the scop
         * In bytes
         */
        $scope.maximumFileSize = ($scope.maximumFileSize * 1000);

        /**
         * Instatiate the document object
         */
        $scope.document = {
            FileUploaded: false,
            IncorrectFileName: false,
            MaximumFileSize: $scope.convertToMegabytes($scope.maximumFileSize)
        };

        /**
         * 
         */
        $scope.processUpload = function () {
            /**
             * Has to go up two levels
             * To reach the controller assocated with the view
             * That the directive has been placed on
             */
            $scope.$parent.$parent.saveFile($scope.document);
        };


    }

})();