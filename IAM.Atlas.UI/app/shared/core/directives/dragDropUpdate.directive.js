(function () {

	'use strict';

	angular
        .module("app.directives")
        .directive("dragDropUpdate", dragDropUpdate);

	function dragDropUpdate() {

		return {
			restrict: 'EA', //E = element, A = attribute, C = class, M = comment         
			scope: {
				//@ reads the attribute value, = provides two-way binding, & works with functions
				listOneHeader: '@',
				listTwoHeader: '@',
				showReferenceHeader: '=',
				referenceOneTitle: '@',
				referenceOneValue: '@',
				referenceTwoTitle: '@',
				referenceTwoValue: '@',
				from: "@",
				to: "@",
				fromDataSource: '=',
                toDataSource: '='
			},
			// template: '<div>{{ myVal }}</div>',
			templateUrl: '/app/shared/core/dragDropUpdate.html',
			controller: "DragDropUpdateCtrl", //Embed a custom controller in the directive
			//link: function ($scope, element, attrs) { } //DOM manipulation
		}

    }


})();