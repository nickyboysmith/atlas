(function () {

	'use strict';

	angular
		.module("app")
		.directive("uploadDocument", UploadDocument);

	function UploadDocument() {

		return {
		    restrict: "EA",
		    scope: {
		        maximumFileSize: "@",
		        theUploadLabel: "@",
                theUploadValue: "@"
		    },
			templateUrl: '/app/shared/core/directives/documentUpload/view.html',
			link: function ($scope, element, attrs) {


                /**
                 * Check file doesnt exceed max file size
                 */
			    function doesFileExceedMaximum(fileSize, maximumFileSize) {
			        if (fileSize > maximumFileSize) {
			            return true;
			        }
			        return false;
			    }

                /**
                 * Remove the extension
                 */
			    function removeExtension(fileName) {
			        var fileNameArray = fileName.split(".");
			        return fileNameArray[0];
			    }

                /**
                 * Process file upload
                 */
			    element.on("change", "input#fileUpload", function (event) {

			        var uploadedFile = document.getElementById('fileUpload').files[0];
			        var maxFileSize = $scope.maximumFileSize * 1000;

                    /**
                     * Show the error
                     */
			        $scope.document["ExceedsMaximum"] = doesFileExceedMaximum(uploadedFile.size, maxFileSize);

                    /**
                     * Show the uploaded file size information
                     */
			        $scope.document["FileUploaded"] = true;

                    /**
                     * Set uploaded file size
                     * On the scope
                     */
			        $scope.document["UploadedFileSize"] = $scope.convertToMegabytes(uploadedFile.size);

                    /**
                     * Set uploaded file name
                     * On the scope
                     */
			        $scope.document["FileName"] = uploadedFile.name;


                    /**
                     * Set the uploaded document name
                     * On on the scope with the extension
                     */
			        $scope.document["Name"] = $scope.formatFileName(uploadedFile.name);


			        /**
                     * Set the uploaded document name
                     * On on the scope without the extension
                     */
			        $scope.document["Title"] = removeExtension(uploadedFile.name);

                    /**
                     * Put the file on the scope
                     * On if the file hasnt exceeded the max file size
                     */
			        if ($scope.document["ExceedsMaximum"] === false) {
			            $scope.document["File"] = uploadedFile;
			        }

			    });

                /**
                 * Vaidate the filename
                 */
			    element.on("keyup", "#documentFileName", function (event) {
			        var string = $("#documentFileName").val();
			        var updatedString = $scope.formatFileName(string);

			        if (string !== updatedString) {
			            $scope.document["IncorrectFileName"] = true;
			        } else if (string === updatedString) {
			            $scope.document["IncorrectFileName"] = false;
			        }

			        $("#documentFileName").val(updatedString);

			    });

			},
			controller: "DocumentUploadCtrl"

		}

	}


})();