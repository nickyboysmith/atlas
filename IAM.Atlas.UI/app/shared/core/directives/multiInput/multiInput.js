'use strict';

angular.module('app.directives')

.directive('multiInput', function ($compile, $parse) {
    return {
        restrict: 'E',
        require: 'ngModel',
        link: function (scope, element) {

            String.prototype.allReplace = function (obj) {
                var retStr = this;
                for (var x in obj) {
                    retStr = retStr.replace(new RegExp(x, 'g'), obj[x]);
                }
                return retStr;
            };
            var template = "";
            switch (scope.input.parameterType) {

                case "Currency":
                case "String":
                case "Number":
                case "Decimal":
                    template = "<div class='row col-sm-12'><label class='col-sm-2 control-label'>" + scope.input.parameterTitle + ": </label><div class='col-sm-10'><input class='reportparameter' type = 'text' ng-model = '$parent.$parent.reportInputs.p" + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + "' ></div></div>"; //standard textbox input
                    break;
                case "Date":
                    //Create calendar variable and assign false
                    var calendarDisplayVariable = 'displayCalendar' + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' });

                    //Create the toggle function specific to the calendar instance
                    var calendarToggleFunctionName = 'toggleCalendar' + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' });
                    var tempMethod = $parse(calendarToggleFunctionName);
                    tempMethod.assign(scope, function () {
                        scope[calendarDisplayVariable] = !scope[calendarDisplayVariable];
                    });

                    var parameterVariable = "$parent.$parent.reportInputs.p" + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' });

                    template = "<div class='row col-sm-12'><label class='col-sm-2 control-label'>" + scope.input.parameterTitle
                                + ":</label><div class='col-sm-3'><input class='form-control cm-sm-5' type='text' ng-model='"
                                + parameterVariable + "' ng-click='" + calendarToggleFunctionName + "()' /></div><div class='col-sm-2 element-overflow-0'><a ng-click='"
                                + calendarToggleFunctionName + "()' ng-show='!" + calendarDisplayVariable + "' class='calendar-button col-sm-12' title='Show Calendar'></a><a ng-click='"
                                + calendarToggleFunctionName + "()' ng-show='" + calendarDisplayVariable + "' class='calendar-button col-sm-12' title='Hide Calendar'></a></div></div>"
                                + "<div class='row col-sm-12' style='z-index:10;'><div class='col-sm-3'></div><div class='col-sm-9'><div style='position:absolute;' ng-show='"
                                + calendarDisplayVariable + "'><date-picker ng-model='" + parameterVariable + "' ng-mouseleave='" + calendarToggleFunctionName + "()' ></date-picker></div></div></div>";
                    break;
                case "BDate":
                    //Create calendar 'from' variable and assign false
                    var calendarDisplayVariable = 'displayCalendar' + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + 'From';
                    
                    //Create the toggle function specific to the calendar 'from' instance
                    var calendarToggleFunctionName = 'toggleCalendar' + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + 'From';
                    var tempMethod = $parse(calendarToggleFunctionName);

                    tempMethod.assign(scope, function () {
                        scope[calendarDisplayVariable] = !scope[calendarDisplayVariable];
                    });

                    var parameterVariable = "$parent.$parent.reportInputs.p" + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + 'From';

                    //Create calendar 'to' variable and assign false
                    var calendar2DisplayVariable = 'displayCalendar' + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + 'To';
                    
                    //Create the toggle function specific to the calendar 'to' instance
                    var calendar2ToggleFunctionName = 'toggleCalendar' + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + 'To';
                    var temp2Method = $parse(calendar2ToggleFunctionName);

                    temp2Method.assign(scope, function () {
                        scope[calendar2DisplayVariable] = !scope[calendar2DisplayVariable];
                    });

                    var parameter2Variable = "$parent.$parent.reportInputs.p" + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + 'To';

                    template = "<div class='col-sm-6'>"
                                + "     <label class='col-sm-4 control-label'>" + scope.input.parameterTitle + ": "+ "</label>"
                                + "     <div class='col-sm-6'>"
                                + "         <input class='form-control cm-sm-12' type='text' ng-model='" + parameterVariable + "' ng-click='" + calendarToggleFunctionName + "()' />"
                                + "         <div style='position:absolute; z-index:100000;' ng-show='" + calendarDisplayVariable + "'>"
                                + "             <date-picker ng-model='" + parameterVariable + "' ng-mouseleave='" + calendarToggleFunctionName + "()' ></date-picker>"
                                + "         </div>"
                                + "     </div>"
                                + "     <div class='col-sm-2 element-overflow-0'>"
                                + "         <a ng-click='" + calendarToggleFunctionName + "()' ng-show='!" + calendarDisplayVariable + "' class='calendar-button col-sm-12' title='Show Calendar'></a>"
                                + "         <a ng-click='" + calendarToggleFunctionName + "()' ng-show='" + calendarDisplayVariable + "' class='calendar-button col-sm-12' title='Hide Calendar'></a>"
                                + "     </div>"
                                + "</div>"

                                + "<div class='col-sm-6'>"
                                + "     <label class='col-sm-4 control-label'>To:</label>"
                                + "     <div class='col-sm-6'>"
                                + "         <input class='form-control cm-sm-12' type='text' ng-model='" + parameter2Variable + "' ng-click='" + calendar2ToggleFunctionName + "()' />"
                                + "         <div style='position:absolute; z-index:100000;' ng-show='" + calendar2DisplayVariable + "'>"
                                + "             <date-picker ng-model='" + parameter2Variable + "' ng-mouseleave='" + calendar2ToggleFunctionName + "()' ></date-picker>"
                                + "         </div>"
                                + "     </div>"
                                + "     <div class='col-sm-2 element-overflow-0'>"
                                + "         <a ng-click='" + calendar2ToggleFunctionName + "()' ng-show='!" + calendar2DisplayVariable + "' class='calendar-button col-sm-12' title='Show Calendar'></a>"
                                + "         <a ng-click='" + calendar2ToggleFunctionName + "()' ng-show='" + calendar2DisplayVariable + "' class='calendar-button col-sm-12' title='Hide Calendar'></a>"
                                + "     </div>"
                                + "</div>"
                                ;
                    break;
                case "CourseType":
                case "CourseTypeCategory":
                case "PaymentMethod":
                case "PaymentType":
                case "PaymentProvider":
                    var dropDownOptions = "";
                    for (i = 0; i < scope.input.parameterOptions.length; i++) {
                        dropDownOptions = dropDownOptions + "<option value = '" + scope.input.parameterOptions[i].optionId + "'>" + scope.input.parameterOptions[i].optionDescription + "</option>";
                    }
                    template = "<div class='row col-sm-12'><label class='col-sm-2 control-label'>" + scope.input.parameterTitle + ": </label><div class='col-sm-5'><select ng-model = '$parent.$parent.reportInputs.p" + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' }) + "'><option value='0'>"
                        + scope.input.parameterTitle + "</option>" + dropDownOptions + "</select></div></div>";
                    break;
                case "CourseTypeMultiple":
                case "CourseTypeCategoryMultiple":
                case "PaymentMethodMultiple":
                case "PaymentTypeMultiple":
                case "PaymentProviderMultiple":
                    var checkBoxOptions = "";
                    for (i = 0; i < scope.input.parameterOptions.length; i++) {
                        checkBoxOptions = checkBoxOptions + "<input type='checkbox' checklist-model='$parent.$parent.reportInputs.p" + scope.input.parameterTitle.allReplace({ ' ': '', '_': 'underscore', '&': 'ampersand' })+ "' value = '"
                            + scope.input.parameterOptions[i].optionId + "'/><span> " + scope.input.parameterOptions[i].optionDescription + "</span><br/>";
                    }
                    template = "<div class='row col-sm-12'><label class='col-sm-2 control-label'>" + scope.input.parameterTitle + ": </label><div class='col-sm-5'><div class='reportparameter reportparametermselect' style='overflow-y: scroll; height: 150px;'>" + checkBoxOptions + "</div></div></div>";
                    break;
            }

            var linkFn = $compile(template);
            var content = linkFn(scope);
            element.append(content);
        }
    };
});