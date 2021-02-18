'use strict';

angular.module('app.services', [])

    .service('SystemService', function () {

        this.CurrentBrowserName = function () {
            return navigator.appName;
        }
        this.CurrentBrowserVersion = function () {
            return '' + parseFloat(navigator.appVersion);
        }

        this.CurrentBrowser = function () {
            return this.CurrentBrowserName() + ' ' + this.CurrentBrowserVersion();
        }

        this.CurrentOperatingSystem = function () {
            return navigator.platform;
        }
        
        this.CookiesEnabled = function () {
            return navigator.cookieEnabled;
        }
        
    });