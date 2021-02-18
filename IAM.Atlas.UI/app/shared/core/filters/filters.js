'use strict';

function leftPadString(value, padding) {
    var s = padding + value;
    return s.substr(s.length - padding.length);
}

angular.module('app.filters', [])

    .filter('interpolate', ['version', function (version) {
        return function (text) {
            return String(text).replace(/\%VERSION\%/mg, version);
        }
    }])
    .filter("leftPad", function () {
        return function (value, padding) {
            return leftPadString(value, padding);
        };
    })


    .filter('time', function () {
    return function (input, from, to, interval) {
        from = parseInt(from, 10);
        to = parseInt(to, 10);
        interval = parseInt(interval, 10);

        for (var i = from, y = 0; i <= to; ++i, y += interval) {
            for (var y = 0; y < 60; y += interval) {

                if (i == 0)
                {
                    input.push( "0:" + (y === 0 ? '00' : y) + " am");
                }
                else {
                    input.push(((i % 12) || 12) + ":" + (y === 0 ? '00' : y) + " " + (i > 12 ? 'pm' : 'am'));
                }
                
            }
        }

        return input;
    };
});