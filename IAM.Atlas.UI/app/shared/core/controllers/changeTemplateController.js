(function () {

    'use strict';


    angular
        .module("app")
        .controller("ChangeTemplateCtrl", ChangeTemplateCtrl);

    ChangeTemplateCtrl.$inject = ["$scope", "AtlasCookieFactory"];

    function ChangeTemplateCtrl($scope, AtlasCookieFactory)
    {

        $scope.templates = [
            { "value": "*", "label": "Please select a colour" },
            { "value": "template-pink", "label": "Pink" },
            { "value": "template-blue", "label": "Blue" },
            { "value": "template-green", "label": "Green" },
            { "value": "template-red", "label": "Red" },
        ];
        $scope.colour = "*";


        $scope.changeTheTemplate = function () {

            AtlasCookieFactory.createCookie("template", $scope.colour);
            var template = new TemplateManager();
            template.update($scope.colour);

        };

    }

})();