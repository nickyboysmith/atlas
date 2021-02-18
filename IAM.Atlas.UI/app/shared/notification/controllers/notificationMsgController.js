(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('NotificationMsgCtrl', NotificationMsgCtrl)

    NotificationMsgCtrl.$inject = ['$scope', '$http', '$location', '$window', "NotificationService", "activeUserProfile"];

    function NotificationMsgCtrl($scope, $http, $location, $window, NotificationService, activeUserProfile) {


        NotificationService.getMessages(activeUserProfile.UserId)
                       .then(function (notifications) {
                           $scope.notificationMessages = notifications;

                           $scope.notificationHelperArray = new Array();

                           if (!notifications.messageCategory == false) {
                               for (var i = 0; i < notifications.messageCategory.length; i++) {
                                   $scope.notificationHelperArray[i] = 0;
                               }
                           }

                       }, function (response) {
                           console.log("error");
                       });

        // increment current message index
        $scope.next = function (catIndex) {
            $scope.notificationHelperArray[catIndex]++;
        };

        // decrement current message index
        $scope.previous = function (catIndex) {
            $scope.notificationHelperArray[catIndex]--;
        };

        // Repeater on the view iterates over all the messages.
        // If our current message index equals that of the repeater then this is the message we want to show
        $scope.CheckCategoryIndex = function (catIndex, msgIndex) {
            if ($scope.notificationHelperArray[catIndex] == msgIndex) {
                return true;
            }
            else {
                return false;
            }
        };

        // Hides tab when messages all acknowledged
        $scope.HasMessages = function (catIndex) {
            if ($scope.notificationMessages.messageCategory[catIndex].message.length == 0) {
                return false;
            }
            else {
                return true;
            }
        };


        // Removes a message 
        $scope.messageAcknowledged = function (messageid, catIndex, msgIndex) {

            /**
             * Build an object
             * To send to the web api
             */
            var messageObject = {
                userId: activeUserProfile.UserId,
                messageId: messageid
            };

            /**
             * Send data to the web api to service
             */
            NotificationService.messageAcknowledged(messageObject)
            .then(
                function(response) {

                    /**
                     * Remove message from array
                     */
                    $scope.notificationMessages.messageCategory[catIndex].message.splice(msgIndex, 1);

                    /**
                     * Resetd the position of message
                     * @TODO: Might have to clarify that does what it does at a later date
                     */
                    if (!$scope.notificationHelperArray[catIndex] == 0) {
                        $scope.notificationHelperArray[catIndex]--;
                    }

                },
                function(reason) {
                    console.log(reason);
                }
            );
        }

        
        $scope.messageTabOpen = function (tabPanelId, contentPanelId) {
            var contentPanel = $('#' + contentPanelId)
            var pos = $('#' + tabPanelId).position();
            var panelOffSet = $('#' + tabPanelId).offset();
            var panelParentOffSet = $('#sidePanel').offset();
            var panelPosition = panelOffSet.top - panelParentOffSet.top;
            contentPanel.css({
                position: "absolute",
                top: panelPosition + "px",
                right: "30px"
            }).show('slide', { direction: 'right' });
            $('#' + tabPanelId).fadeOut();
        };

        $scope.messageTabClose = function (tabPanelId, contentPanelId) {
            var tabPanel = $('#' + tabPanelId)
            $('#' + contentPanelId).fadeOut();
            tabPanel.fadeIn();
        };
     };
    
})();