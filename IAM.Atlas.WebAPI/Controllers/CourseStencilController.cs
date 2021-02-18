using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Web.Script.Serialization;
using System.Web;
using System.Configuration;
using System.IO;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseStencilController : AtlasBaseController
    {
        protected FormDataCollection formData;

        [AuthorizationRequired]
        public CourseStencilJSON Post([FromBody] FormDataCollection formBody)
        {
            //Cater for 2 functions: fetch and add
            this.formData = formBody;
            var courseReturnData = new CourseStencilJSON();

            if (formBody.Count() > 0)
            {
                string operation = StringTools.GetString("operation", ref formData).ToUpper();
                int userID = StringTools.GetInt("userId", ref formData);
                int courseStencilId = StringTools.GetInt("organisationId", ref formData);
                int organisationId = StringTools.GetInt("organisationId", ref formData);

                if (userID > 0)
                {
                    return this.SaveCourse(userID, organisationId, courseReturnData, formBody);
                }
            }
            return courseReturnData;
        }

        public CourseStencilJSON Get(int courseStencilId, int userId)
        {
            CourseStencilJSON courseStencilJSON = null;

            var courseStencil = atlasDB.CourseStencils
                                .Where(c => c.Id == courseStencilId)
                                .FirstOrDefault();

            if (courseStencil != null)
            {
                courseStencilJSON = new CourseStencilJSON();
                courseStencilJSON.Id = courseStencil.Id;
                courseStencilJSON.name = courseStencil.Name;
                courseStencilJSON.versionNumber = courseStencil.VersionNumber;
                courseStencilJSON.maxCourses = courseStencil.MaxCourses;
                courseStencilJSON.excludeBankHolidays = courseStencil.ExcludeBankHolidays;
                courseStencilJSON.excludeWeekends = courseStencil.ExcludeWeekends;

                courseStencilJSON.earliestStartDate = courseStencil.EarliestStartDate;
                courseStencilJSON.latestStartDate = courseStencil.LatestStartDate;
                courseStencilJSON.sessionStartTime1 = courseStencil.SessionStartTime1;
                courseStencilJSON.sessionEndTime1 = courseStencil.SessionEndTime1;
                courseStencilJSON.sessionStartTime2 = courseStencil.SessionStartTime2;
                courseStencilJSON.sessionEndTime2 = courseStencil.SessionEndTime2;
                courseStencilJSON.sessionStartTime3 = courseStencil.SessionStartTime3;
                courseStencilJSON.sessionEndTime3 = courseStencil.SessionEndTime3;

                courseStencilJSON.multiDayCourseDaysBetween = courseStencil.MultiDayCourseDaysBetween;
                courseStencilJSON.courseTypeId = courseStencil.CourseTypeId;
                courseStencilJSON.courseTypeCategoryId = courseStencil.CourseTypeCategoryId;
                courseStencilJSON.venueId = courseStencil.VenueId;
                courseStencilJSON.trainerCost = courseStencil.TrainerCost;
                courseStencilJSON.trainersRequired = courseStencil.TrainersRequired;
                courseStencilJSON.coursePlaces = courseStencil.CoursePlaces;
                courseStencilJSON.reservedPlaces = courseStencil.ReservedPlaces;
                courseStencilJSON.courseReferenceGeneratorId = courseStencil.CourseReferenceGeneratorId;
                courseStencilJSON.beginReferenceWith = courseStencil.BeginReferenceWith;
                courseStencilJSON.endReferenceWith = courseStencil.EndReferenceWith;

                courseStencilJSON.weeklyCourses = courseStencil.WeeklyCourses;
                courseStencilJSON.weeklyCourseStartDay = courseStencil.WeeklyCourseStartDay;
                courseStencilJSON.monthlyCourses = courseStencil.MonthlyCourses;
                courseStencilJSON.monthlyCoursesPreferredDayStart = courseStencil.MonthlyCoursesPreferredDayStart;
                courseStencilJSON.dailyCourses = courseStencil.DailyCourses;
                courseStencilJSON.dailyCoursesSkipDays = courseStencil.DailyCoursesSkipDays;

                courseStencilJSON.excludeMonday = courseStencil.ExcludeMonday;
                courseStencilJSON.excludeTuesday = courseStencil.ExcludeTuesday;
                courseStencilJSON.excludeWednesday = courseStencil.ExcludeWednesday;
                courseStencilJSON.excludeThursday = courseStencil.ExcludeThursday;
                courseStencilJSON.excludeFriday = courseStencil.ExcludeFriday;
                courseStencilJSON.excludeSaturday = courseStencil.ExcludeSaturday;
                courseStencilJSON.excludeSunday = courseStencil.ExcludeSunday;

                courseStencilJSON.notes = courseStencil.Notes;
                courseStencilJSON.createCourses = courseStencil.CreateCourses;
            }
            return courseStencilJSON;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/courseStencil/GetAvailableCourseStencils/{organisationId}/{userId}")]
        public List<CourseStencilJSON> GetAvailableCourseStencils(int organisationId, int userId)
        {
            List<CourseStencilJSON> availableCourseStencils = null;

            var user = atlasDB.SystemAdminUsers.Where(sau => sau.UserId == userId).FirstOrDefault();

            var courseStencils = atlasDB.CourseStencils
                                .Where(x => x.Disabled != true && x.OrganisationCourseStencils.Any(c => c.OrganisationId == organisationId))
                                .ToList();

            if (courseStencils.Count() > 0)
            {
                availableCourseStencils = courseStencils.Select(courseStencil => new CourseStencilJSON()
                {
                    Id = courseStencil.Id,
                    name = courseStencil.Name
                }).ToList();
            }
            return availableCourseStencils;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/courseStencil/SetCreateCourses/{courseStencilId}/{userId}/{organisationId}")]
        public string SetCreateCourses(int courseStencilId, int userId, int organisationId)
        {

            var actionMessage = "Create Courses Flag Set";

            var courseStencil = new CourseStencil();
            courseStencil.Id = courseStencilId;
            courseStencil.CreateCourses = true;
            courseStencil.DateUpdated = DateTime.Now;
            courseStencil.UpdatedByUserId = userId;
            courseStencil.DateCourseCreationInitiated = DateTime.Now;
            courseStencil.CourseCreationInitiatedByUserId = userId;

            try
            {
                atlasDB.CourseStencils.Attach(courseStencil);
                atlasDB.Entry(courseStencil).Property("CreateCourses").IsModified = true;
                atlasDB.Entry(courseStencil).Property("DateUpdated").IsModified = true;
                atlasDB.Entry(courseStencil).Property("UpdatedByUserId").IsModified = true;
                atlasDB.Entry(courseStencil).Property("CourseCreationInitiatedByUserId").IsModified = true;
                atlasDB.Entry(courseStencil).Property("DateCourseCreationInitiated").IsModified = true;
                atlasDB.SaveChanges();
                atlasDB.Entry(courseStencil).State = EntityState.Detached;
            }
            catch (Exception ex)
            {
                throw new Exception("There was an error creating courses. Please retry. If the problem persists! Contact support!");
            }

            return actionMessage;
        }

        private CourseStencilJSON SaveCourse(int userId, int organisationId, CourseStencilJSON courseReturnData, FormDataCollection formBody)
        {
            var courseStencil = formBody.ReadAs<CourseStencil>();
            var courseStencilJSON = formBody.ReadAs<CourseStencilJSON>();

            courseStencil.CreatedByUserId = userId;
            courseStencil.DateCreated = DateTime.Now;

            //only need on of the following
            if (courseStencil.MonthlyCourses == false)
            {
                courseStencil.MonthlyCoursesPreferredDayStart = null;
            }
            if (courseStencil.WeeklyCourses == false)
            {
                courseStencil.WeeklyCourseStartDay = null;
            }
            if (courseStencil.DailyCourses == false)
            {
                courseStencil.DailyCoursesSkipDays = null;
            }

            var extraValidationSrings = new ExtraValidationSrings();

            //need this as ReadAs loses int if string passed in
            extraValidationSrings.coursePlaces = StringTools.GetString("coursePlaces", ref formData);
            extraValidationSrings.maxCourses = StringTools.GetString("maxCourses", ref formData);
            extraValidationSrings.trainersRequired = StringTools.GetString("trainersRequired", ref formData);
            extraValidationSrings.reservedPlaces = StringTools.GetString("reservedPlaces", ref formData);
            extraValidationSrings.trainerCost = StringTools.GetString("trainerCost", ref formData);

            var validationMessage = string.Empty;
            var valid = ValidCourseStencil(courseStencilJSON, extraValidationSrings, ref validationMessage);

            if (!valid)
            {
                courseStencilJSON.valid = valid;
                courseStencilJSON.actionMessage = validationMessage;
                return courseStencilJSON;
            }
            else
            {
                //set diasbled to false if null
                courseStencil.Disabled = courseStencil.Disabled != null ? courseStencil.Disabled : false;

                atlasDB.CourseStencils.Attach(courseStencil);
                var entry = atlasDB.Entry(courseStencil);

                //if a new stencil then stencil Id will be zero so addCourseStencil is true
                var addCourseStencil = courseStencil.Id > 0 ? false : true;
                if (addCourseStencil)
                {
                    entry.State = System.Data.Entity.EntityState.Added;
                    var organisationCourseStencil = new OrganisationCourseStencil() { OrganisationId = organisationId, CourseStencilId = courseStencil.Id };
                    courseStencil.OrganisationCourseStencils.Add(organisationCourseStencil);

                    //if this is a new version we need to set the parent to disabled
                    if (courseStencilJSON.ParentCourseStencilId > 0)
                    {
                        SetParentToDisabled(userId, courseStencilJSON);
                    }
                }
                else
                {
                    entry.State = System.Data.Entity.EntityState.Modified;
                }

                try
                {
                    atlasDB.SaveChanges();
                    courseReturnData = Get(courseStencil.Id, userId);
                    courseReturnData.actionMessage = addCourseStencil ? "Course Stencil added successfully." : "Course Stencil saved successfully.";
                    courseReturnData.valid = true;
                }
                catch (Exception ex)
                {
                    courseReturnData = courseStencilJSON;
                    courseReturnData.actionMessage = "An unxpected error occured. Please contact the system administartor";
                    courseReturnData.valid = true;
                }
                return courseReturnData;
            }

        }

        private void SetParentToDisabled(int userId, CourseStencilJSON courseStencilJSON)
        {
            var parentCourseStencil = new CourseStencil();
            parentCourseStencil.Id = (int)courseStencilJSON.ParentCourseStencilId;
            parentCourseStencil.DateUpdated = DateTime.Now;
            parentCourseStencil.UpdatedByUserId = userId;
            parentCourseStencil.Disabled = true;

            atlasDB.CourseStencils.Attach(parentCourseStencil);
            atlasDB.Entry(parentCourseStencil).Property("DateUpdated").IsModified = true;
            atlasDB.Entry(parentCourseStencil).Property("UpdatedByUserId").IsModified = true;
            atlasDB.Entry(parentCourseStencil).Property("Disabled").IsModified = true;
        }

        private bool ValidCourseStencil(CourseStencilJSON courseStencil, ExtraValidationSrings extraValidationSrings, ref string validationMessage)
        {
            var today = DateTime.Now;
            int ret;

            if (courseStencil.name == null)
            {
                validationMessage = "The Name is required.";
            }

            if (courseStencil.coursePlaces == null || courseStencil.coursePlaces < 1 || (int.TryParse(extraValidationSrings.coursePlaces, out ret)) == false)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "Course Places must be greater than zero.";
            }

            if (courseStencil.earliestStartDate == null)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "The Earliest Start Date is required.";
            }

            if (courseStencil.earliestStartDate != null && today.AddDays(2) > courseStencil.earliestStartDate)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "The Earliest Start Date must be at least 2 days into the future.";
            }

            if ((courseStencil.earliestStartDate >= courseStencil.latestStartDate) && courseStencil.latestStartDate != null)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "The Earliest End Date must after the Earliest Start Date.";
            }

            if (courseStencil.courseTypeId == null)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "Course Type must be selected.";
            }

            if ((courseStencil.monthlyCourses == null ? false : courseStencil.monthlyCourses) == false
                && (courseStencil.weeklyCourses == null ? false : courseStencil.weeklyCourses) == false
                && (courseStencil.dailyCourses == null ? false : courseStencil.dailyCourses) == false)
            {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Please select daily, weekly or monthly courses";
            }

            // Session time validations
            var validSessionStartTime1 = false;
            var validSessionEndTime1 = false;
            var validSessionStartTime2 = false;
            var validSessionEndTime2 = false;
            var validSessionStartTime3 = false;
            var validSessionEndTime3 = false;
            var reTime = "^([0-1][0-9]|2[0-3]):[0-5][0-9]$";
            var reCurrency = "(?=.)^(([1-9][0-9]{0,2}(,[0-9]{3})*)|[0-9]+)?(\\.[0-9]{1,2})?$";

            // session 1
            if (!String.IsNullOrEmpty(courseStencil.sessionStartTime1))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(courseStencil.sessionStartTime1, reTime);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Session Start Time 1 is as invalid time (HH:MM)";
                }
                else
                {
                    validSessionStartTime1 = true;
                }
            }

            if (!String.IsNullOrEmpty(courseStencil.sessionEndTime1))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(courseStencil.sessionEndTime1, reTime);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Session End Time 1 is as invalid time (HH:MM)";
                }
                else
                {
                    validSessionEndTime1 = true;
                }
            }

            if (validSessionStartTime1 && validSessionEndTime1)
            {
                if (TimeSpan.Parse(courseStencil.sessionStartTime1) > TimeSpan.Parse(courseStencil.sessionEndTime1))
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Sesion End Time 1 has to be after Session Start Time 1.";
                }
            }

            // session 2
            if (!String.IsNullOrEmpty(courseStencil.sessionStartTime2))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(courseStencil.sessionStartTime2, reTime);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Session Start Time 2 is as invalid time (HH:MM)";
                }
                else
                {
                    validSessionStartTime2 = true;
                }
            }

            if (!String.IsNullOrEmpty(courseStencil.sessionEndTime2))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(courseStencil.sessionEndTime2, reTime);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Session End Time 2 is as invalid time (HH:MM)";
                }
                else
                {
                    validSessionEndTime2 = true;
                }
            }


            if (validSessionStartTime2 && validSessionEndTime2)
            {
                if (TimeSpan.Parse(courseStencil.sessionStartTime2) > TimeSpan.Parse(courseStencil.sessionEndTime2))
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Sesion End Time 2 has to be after Session Start Time 2.";
                }
            }

            // session 3
            if (!String.IsNullOrEmpty(courseStencil.sessionStartTime3))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(courseStencil.sessionStartTime3, reTime);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Session Start Time 3 is as invalid time (HH:MM)";
                }
                else
                {
                    validSessionStartTime3 = true;
                }
            }

            if (!String.IsNullOrEmpty(courseStencil.sessionEndTime3))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(courseStencil.sessionEndTime3, reTime);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Session End Time 3 is as invalid time (HH:MM)";
                }
                else
                {
                    validSessionEndTime3 = true;
                }
            }

            if (validSessionStartTime3 && validSessionEndTime3)
            {
                if (TimeSpan.Parse(courseStencil.sessionStartTime3) > TimeSpan.Parse(courseStencil.sessionEndTime3))
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Sesion End Time 3 has to be after Session Start Time 3.";
                }
            }

            //extra validations
            if (string.IsNullOrEmpty(extraValidationSrings.maxCourses) == false && (int.TryParse(extraValidationSrings.maxCourses, out ret)) == false)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "Maximum courses must be a number.";
            }

            if (string.IsNullOrEmpty(extraValidationSrings.trainersRequired) == false && (int.TryParse(extraValidationSrings.trainersRequired, out ret)) == false)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "Trainers required must be a number.";
            }

            if (string.IsNullOrEmpty(extraValidationSrings.reservedPlaces) == false && (int.TryParse(extraValidationSrings.reservedPlaces, out ret)) == false)
            {
                validationMessage += validationMessage != "" ? "\n" : "";
                validationMessage += "Reserved places must be a number.";
            }

            if (!String.IsNullOrEmpty(extraValidationSrings.trainerCost))
            {
                var match = System.Text.RegularExpressions.Regex.IsMatch(extraValidationSrings.trainerCost, reCurrency);
                if (!match)
                {
                    validationMessage += validationMessage != "" ? "\n" : "";
                    validationMessage += "Trainer Cost is as invalid amount.";
                }
            }

            if (validationMessage == "")
                return true;
            else
                return false;
        }
    }

    class ExtraValidationSrings
    {
        public string coursePlaces { get; set; }
        public string maxCourses { get; set; }
        public string trainersRequired { get; set; }
        public string reservedPlaces { get; set; }
        public string trainerCost { get; set; }
    }
}