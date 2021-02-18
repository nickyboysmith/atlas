(function () {

    'use strict';

    angular
        .module("app")
        .factory("DashboardFactory", DashboardFactory);

    function DashboardFactory() {


        /**
         * For chart data
         */
        this.createKeyValue = function (responseObject) {
            var newObject = {};
            var theKeys = [];
            var theValues = [];
            angular.forEach(responseObject, function (value, key) {
                key = key.replace(/([a-z])([A-Z])/g, '$1 $2').replace(/_/g, ' ');
                theKeys.push(key);
                theValues.push(value);
            });
            newObject["labels"] = theKeys;
            newObject["values"] = theValues;

            return newObject;
        };

        /**
         * 
         */
        this.getHighestRefreshRate = function (meters) {
            var refreshRate = 0;
            angular.forEach(meters, function (value, index) {
                if (value.Refresh > refreshRate) {
                    refreshRate = value.Refresh;
                }
            });
            if (refreshRate === 0) {
                return 5000;
            } else {
                return refreshRate;
            }
        };

        return {
            keyValue: this.createKeyValue,
            getRefreshRate: this.getHighestRefreshRate
        };

    }

})();