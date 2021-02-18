


    'use strict';

    angular
        .module('app.directives')
        .directive('myMsgfader', msgFader);


        function msgFader($timeout) {
        return {

            /*
            *
            */
            restrict: 'EA', //E = element, A = attribute, C = class, M = comment         
            //replace: true,
            scope: {
                status: '=',
                showFadeMessage: '=showFadeMessage',
                messageContent: '='
            },
            templateUrl: '/app/shared/core/directives/fadeMessage/fadeMessage.html',
            link: function (scope, element, attrs) {

                console.log(attrs);

                scope.$watch("showFadeMessage",
                    function (newValue, oldValue) {
                        console.log(oldValue);
                        console.log(newValue);

                        if (newValue) {
                            $timeout(function () {

                                scope.showFadeMessage = false;
                                scope.$apply();


                            }, 3000);
                        }
                    }
                );


            }
        };
    }


