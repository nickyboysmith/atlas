(function(){

    angular
        .module("app")
        .factory("UnAuthorizedAccessFactory", UnAuthorizedAccessFactory);

    UnAuthorizedAccessFactory.$inject = ["$q", "$injector", "$location", "SignOutFactory", "$timeout", "$rootScope"];

    function UnAuthorizedAccessFactory($q, $injector, $location, SignOutFactory, $timeout, $rootScope) {
        return {
            // optional method
            'responseError': function (rejection) {

                // if modal already open do not create any others
                if (!$rootScope.timeout){ 

                    if (rejection.status === 401) {

                        if (rejection.statusText == "For security reasons your session has timed out and you will be logged out.") {
                            var uibModal = $injector.get('$uibModal')

                            $rootScope.timeout = uibModal.open({
                                templateUrl: '/app/shared/navigation/timeout-dialog.html',
                                windowClass: 'modal-danger'
                            });

                            $timeout(closeModals, 5000);  //5 seconds
                        }
                        else if (rejection.statusText == "You've been signed in, in another location. You will be signed out.") {
                            var uibModal = $injector.get('$uibModal')

                            $rootScope.timeout = uibModal.open({
                                templateUrl: '/app/shared/navigation/alreadySignedIn-dialog.html',
                                windowClass: 'modal-danger'
                            });

                            $timeout(closeModals, 5000);  //5 seconds
                        }

                        function closeModals() {
                            if ($rootScope.timeout) {
                                $rootScope.timeout.close();
                                $rootScope.timeout = null;
                            }

                            var path = $location.$$absUrl;

                            if (path.indexOf("/admin") > -1) {

                                SignOutFactory.admin();

                            }
                            else if (path.indexOf("/trainer") > -1) {

                                SignOutFactory.trainer();

                            }
                            else {

                                SignOutFactory.client();
                            }
                        }
                    }
                }

                return $q.reject(rejection);
            }
        };
    }

})();