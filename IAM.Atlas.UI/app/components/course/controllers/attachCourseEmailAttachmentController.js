(function () {
    'use strict';

    angular
        .module('app')
        .controller('attachCourseEmailAttachmentCtrl', attachCourseEmailAttachmentCtrl);

    attachCourseEmailAttachmentCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'activeUserProfile', 'CourseService', 'OrganisationSystemConfigurationService']

    function attachCourseEmailAttachmentCtrl($scope, $location, $window, $http , $filter, activeUserProfile, CourseService, OrganisationSystemConfigurationService) {

       
        $scope.refreshDocuments = function () {
            return CourseService.getCourseDocuments($scope.course.courseId)
                    .then(
                        function successCallback(response) {
                            $scope.documents = response;
                        }
                    );
        }

        $scope.setSelectedDocument = function (document) {

            document.isSelected ? document.isSelected = false : document.isSelected = true;
        };

  
        $scope.closeModal = function () {
            $('button.close').last().trigger('click');
        }

        $scope.uploadNew = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Course Document",
                cssClass: "courseDocumentModal",
                filePath: "/app/components/course/addCourseEmailAttachment.html",
                controllerName: "addCourseEmailAttachmentCtrl"
            });
        }



        // Attach Selected Documents
        $scope.AttachSelected = function () {

            var attachments = {
                titles: '',
                Ids: []
            };

        // Filter out Selected Documents for removal
            var selectedAttachments = $filter("filter")($scope.documents, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedAttachments.forEach(function (arrayItem) {
                var x = arrayItem.Id
                var y = arrayItem.Title + ', ';

                attachments.titles = attachments.titles + y;
                attachments.Ids.push(x);
            });

            // remove last ', '
            attachments.titles = attachments.titles.slice(0, attachments.titles.length - 2);

            if ($scope.emailTypeForAttachmentUpdate == 'Client') {
                // add to scope
                $scope.clientEmail.Attachments = attachments.titles;
                $scope.clientEmail.AttachmentIds = attachments.Ids;
            }
            else if ($scope.emailTypeForAttachmentUpdate == 'Trainer') {
                // add to scope
                $scope.trainerEmail.Attachments = attachments.titles;
                $scope.trainerEmail.AttachmentIds = attachments.Ids;
            }

            // close the window
            $scope.closeModal();

        }

        $scope.HasAttachmentsSelected = function () {

            if ($scope.documents.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }



        $scope.refreshDocuments();

    }

    

})();