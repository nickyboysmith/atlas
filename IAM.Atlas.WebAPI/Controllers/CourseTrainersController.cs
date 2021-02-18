using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{

    [AllowCrossDomainAccess]
    public class CourseTrainersController : AtlasBaseController
    {

        // 
        [HttpPost]
        [AuthorizationRequired]
        [Route("api/coursetrainers")]
        public object getCourseSearchResults([FromBody] FormDataCollection formParams)
        {
            DateTime today = DateTime.Now;
            DateTime startOfDay = today.Date;

            var formData = formParams;

            var organisationId = StringTools.GetInt("organisationId", ref formData);
            var courseTypeId = StringTools.GetInt("courseTypeId", ref formData);
            var courseTypeCategoryId = StringTools.GetInt("courseTypeCategoryId", ref formData);
            var fromDate = StringTools.GetDate("fromDate", "dd MMM yyyy", ref formData);
            var toDate = StringTools.GetDate("toDate", "dd MMM yyyy", ref formData);
            var noTrainersAllocated = StringTools.GetBool("noTrainersAllocated", ref formData);

            var courseResultsQuery = atlasDBViews.vwCourseDetails
                                     .Where(
                                      x =>
                                      ((organisationId < 0) || (x.OrganisationId == organisationId)) && 
                                      (x.StartDate >= fromDate && x.StartDate <= toDate) &&
                                      (x.CourseTypeId == courseTypeId) &&
                                      ((courseTypeCategoryId == 0) || x.CourseTypeCategoryId == courseTypeCategoryId) &&
                                      (noTrainersAllocated ? (x.NumberOfTrainersBookedOnCourse == 0 || x.NumberOfTrainersBookedOnCourse == null) : true)
                                      )
                                      .Select(x => new
                                      {
                                          Id = x.CourseId,
                                          reference = x.CourseReference,
                                          available = x.CourseAvailable,
                                          cancelled = x.CourseCancelled == true ? "cancelled" : "non-cancelled",
                                          startDate = x.StartDate,
                                          endDate = x.EndDate,
                                          started = x.StartDate == null ? true : (DateTime)x.StartDate < DateTime.Now,
                                          venue = x.VenueName,
                                          trainers = x.NumberOfTrainersBookedOnCourse,
                                          remaining = x.PlacesRemaining,
                                          categoryId = x.CourseTypeCategoryId,
                                          courseType = x.CourseType,
                                          courseTypeId = x.CourseTypeId,
                                          courseTypeCategory = x.CourseTypeCategory,
                                          TheoryCourse = x.TheoryCourse,
                                          PracticalCourse = x.PracticalCourse,
                                          //SessionNumber = x.SessionNumber                              
                                      })
                                      .ToList();
            return courseResultsQuery;
        }
    }
}