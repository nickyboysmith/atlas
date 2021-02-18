(function () {

    'use strict';

    angular
        .module("app")
        .factory("TrainerAttendanceFactory", TrainerAttendanceFactory);

    TrainerAttendanceFactory.$inject = ["CourseTrainerFactory"];

    function TrainerAttendanceFactory(CourseTrainerFactory) {

        /**
         * Takes the attendance data and 
         * Groups it by Course TIME 
         */
        this.transformAttendanceData = function (trainerAttendance) {
            
            /**
             * 
             */
            var groupedCategories = [];
            var groupCategoryCourseData = [];


            angular.forEach(trainerAttendance, function (attendance, attendanceKey) {
 

                /**
                 * Check if the course type Id
                 * Is already in the array
                 */
                var alreadyInCategory = CourseTrainerFactory.find(groupedCategories, attendance.CourseTypeId);

                /**
                 * If the courseTypeId hasnt been added to the [groupCategories] array
                 * Then push a new object to the [groupCategories] array
                 */
                if (alreadyInCategory === undefined) {
                    groupedCategories.push({
                        Id: attendance.CourseTypeId,
                        CourseName: attendance.CourseTypeName,
                        CourseCategoryName: attendance.CourseTypeCategoryName,
                    });
                };

                /**
                 * Check to see if the Group category
                 * Has Been added to the array
                 * If it hasn't create an empty object for the groupcategory property
                 */
                if (groupCategoryCourseData[attendance.CourseTypeId] === undefined) {
                    groupCategoryCourseData[attendance.CourseTypeId] = {};
                }

                /**
                 * Fill the object property
                 */
                groupCategoryCourseData[attendance.CourseTypeId]["CourseTypeId"] = attendance.CourseTypeId;
                groupCategoryCourseData[attendance.CourseTypeId]["CourseName"] = attendance.CourseTypeName;
                groupCategoryCourseData[attendance.CourseTypeId]["CourseCategoryName"] = attendance.CourseTypeCategoryName;


                /**
                 * Create variable for course array check 
                 */
                var doesCourseArrayExist = groupCategoryCourseData[attendance.CourseTypeId].Courses;

                /**
                 * Check to see if the course property 
                 * Exists on the object
                 * If it doesnt we'll create it
                 */
                if (doesCourseArrayExist === undefined) {
                    groupCategoryCourseData[attendance.CourseTypeId]["Courses"] = [];
                }

                /**
                 * Add the course to the object
                 * Grouped by the category key
                 */
                groupCategoryCourseData[attendance.CourseTypeId]["Courses"].push(attendance.Course);


            });


            return {
                categories: groupedCategories,
                courseList: groupCategoryCourseData
            };

        };

        this.getCategoryIndexID = function (objectToSearch, searchableID) {
            return CourseTrainerFactory.find(objectToSearch, searchableID);
        };

        return {
            transform: this.transformAttendanceData,
            getCategoryIndex: this.getCategoryIndexID
        };

    }

})();