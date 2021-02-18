using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseCloneRequestController : AtlasBaseController
    {

        

        [Route("api/courseclonerequest")]
        [HttpPost]
        public string Post([FromBody] FormDataCollection formBody)
        {
            try
            {
                // Require fields
                var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Please select a valid organisation.");
                var userId = StringTools.GetIntOrFail("userId", ref formBody, "Please use a valid user.");
                var startDate = StringTools.GetDateOrFail("startDate", ref formBody, "Please select a valid Start date");
                var endDate = StringTools.GetDateOrFail("endDate", ref formBody, "Please select a valid End date");
                var courseId = StringTools.GetIntOrFail("courseId", ref formBody, "Please choose a valid course.");
                var courseTypeId = StringTools.GetIntOrFail("courseTypeId", ref formBody, "Please choose a valid course type.");
                var maximumCourseAmount = StringTools.GetIntOrFail("maximumCourses", ref formBody, "Please select a valid maximum course amount.");
                var sameReference = StringTools.GetBoolOrFail("sameReference", ref formBody, "Please use a valid representative for this.");
                var sameTrainers = StringTools.GetBoolOrFail("sameTrainers", ref formBody, "Please use a valid representative for this.");
                var weeklyCourses = StringTools.GetBoolOrFail("weeklyCourses", ref formBody, "Please tick or untick the weekly courses checkbox to proceed.");
                var monthlyCourses = StringTools.GetBoolOrFail("monthlyCourses", ref formBody, "Please tick or untick the monthly courses checkbox to proceed.");

                // Create object to add to db
                var clone = new CourseCloneRequest();

                clone.CourseId = courseId;
                clone.OrganisationId = organisationId;
                clone.RequestedByUserId = userId;
                clone.CourseTypeId = courseTypeId;
                clone.DateRequested = DateTime.Now;
                clone.StartDate = startDate;
                clone.EndDate = endDate;
                clone.MaxCourses = maximumCourseAmount;
                clone.UseSameReference = sameReference;
                clone.UseSameTrainers = sameTrainers;
                clone.MonthlyCourses = monthlyCourses;
                clone.WeeklyCourses = weeklyCourses;


                // Optional fields
                // Now do the optional field checks
                if (!String.IsNullOrEmpty(formBody["courseTypeCategoryId"]))
                {
                    var courseTypeCategoryId = StringTools.GetIntOrFail("courseTypeCategoryId", ref formBody, "Please choose a valid course type category.");
                    clone.CourseTypeCategoryId = courseTypeCategoryId;
                }

                // If a reference template has been selected
                if (!String.IsNullOrEmpty(formBody["referenceTemplate"]))
                {
                    var referenceTemplateId = StringTools.GetIntOrFail("referenceTemplate", ref formBody, "Please select a valid template.");
                    clone.CourseReferenceGeneratorId = referenceTemplateId;
                }


                // If a reference template has been selected
                if (!String.IsNullOrEmpty(formBody["createCourseEveryWeek"]))
                {
                    var courseAmountEveryWeek = StringTools.GetIntOrFail("createCourseEveryWeek", ref formBody, "Please select a number for Every week.");
                    clone.EveryNWeeks = courseAmountEveryWeek;
                }

                // If a reference template has been selected
                if (!String.IsNullOrEmpty(formBody["createCourseEveryMonth"]))
                {
                    var courseAmountEveryMonth = StringTools.GetIntOrFail("createCourseEveryMonth", ref formBody, "Please select a number for Every month.");
                    clone.EveryNMonths = courseAmountEveryMonth;
                }


                atlasDB.CourseCloneRequests.Add(clone);
                atlasDB.SaveChanges();
            } catch (Exception ex) {
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "There has been an error cloning your course.");
            }

            return "Your courses have been cloned successfully";
        }

        
    }
}