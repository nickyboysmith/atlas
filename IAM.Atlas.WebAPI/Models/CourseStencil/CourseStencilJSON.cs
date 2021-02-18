using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is used to return a light weight serialized JSON object to course and caters both for new course (with type, venue language and category options)
    /// creation as well as clone course creation which returns all these as well as template course presets
    /// 
    /// </summary>
    public class CourseStencilJSON
    {
        public int Id { get; set; }
        public string actionMessage { get; set; }
        public bool valid { get; set; }
        public string name { get; set; }
        public int? versionNumber { get; set; }
        public int? maxCourses { get; set; }
        public bool? excludeBankHolidays { get; set; }
        public bool? excludeWeekends { get; set; }

        public DateTime? earliestStartDate { get; set; }
        public DateTime? latestStartDate { get; set; }
        public string sessionStartTime1 { get; set; }
        public string sessionEndTime1 { get; set; }
        public string sessionStartTime2 { get; set; }
        public string sessionEndTime2 { get; set; }
        public string sessionStartTime3 { get; set; }
        public string sessionEndTime3 { get; set; }

        public int? multiDayCourseDaysBetween { get; set; }
        public int? courseTypeId { get; set; }
        public int? courseTypeCategoryId { get; set; }
        public int? venueId { get; set; }
        public decimal? trainerCost { get; set; }
        public int? trainersRequired { get; set; }
        public int? coursePlaces { get; set; }
        public int? reservedPlaces { get; set; }
        public int? courseReferenceGeneratorId { get; set; }
        public string beginReferenceWith { get; set; }
        public string endReferenceWith { get; set; }

        public bool? weeklyCourses { get; set; }
        public int? weeklyCourseStartDay { get; set; }
        public bool? monthlyCourses { get; set; }
        public int? monthlyCoursesPreferredDayStart { get; set; }
        public bool? dailyCourses { get; set; }
        public int? dailyCoursesSkipDays { get; set; }

        public bool? excludeMonday { get; set; }
        public bool? excludeTuesday { get; set; }
        public bool? excludeWednesday { get; set; }
        public bool? excludeThursday { get; set; }
        public bool? excludeFriday { get; set; }
        public bool? excludeSaturday { get; set; }
        public bool? excludeSunday { get; set; }

        public string notes { get; set; }
        public bool? createCourses { get; set; }
        public int? ParentCourseStencilId { get; set; }

    }
}