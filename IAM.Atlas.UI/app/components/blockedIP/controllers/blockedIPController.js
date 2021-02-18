(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('BlockedIPCtrl', BlockedIPCtrl);

    BlockedIPCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'BlockedIPService'];

    function BlockedIPCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, BlockedIPService) {

        $scope.userId = activeUserProfile.UserId;
        $scope.blockedIPs = [];


        //Get Blocked IPs 
        $scope.getBlockedIPs = function () {

            BlockedIPService.getBlockedIPs()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.blockedIPs = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Set Selected Blocked Emails 
        $scope.setSelectedBlockedIP = function (BlockedIP) {

            BlockedIP.isSelected ? BlockedIP.isSelected = false : BlockedIP.isSelected = true;

        }

        //Delete Blocked Emails 
        $scope.removeBlockedIPs= function () {

            var IP = {
                blockedIPs: []
            };

            IP.userId = $scope.userId;

            //Filter out Selected Emails for removal
            var selectedBlockedIPs = $filter("filter")($scope.blockedIPs, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedBlockedIPs.forEach(function (arrayItem) {
                var x = arrayItem.Id
                IP.blockedIPs.push(x);
            });

            BlockedIPService.Unblock(IP)
                .then(
                    function (response) {
                        // refresh the list 
                        $scope.getBlockedIPs();

                        $scope.successMessage = "Unblock Successful";
                        $scope.validationMessage = "";
                    },
                    function (response) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }

        $scope.HasBlockedIPs = function () {

            if ($scope.blockedIPs.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.getBlockedIPs();

    }

    })();