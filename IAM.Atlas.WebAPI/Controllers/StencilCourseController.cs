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
    public class StencilCourseController : AtlasBaseController
    {
        protected FormDataCollection formData;

        //POST: api/stencilcourse/removestencilcourses
        [AuthorizationRequired]
        [HttpPost]
        [Route("api/stencilcourse/removestencilcourses")]
        public object RemoveStencilCourses([FromBody] FormDataCollection formBody)
        {
            this.formData = formBody;

            if (formBody.Count() > 0)
            {
                int userID = StringTools.GetInt("userId", ref formData);
                int stencilId = StringTools.GetInt("stencilId", ref formData);
                var requestingUserId = this.GetUserIdFromToken(Request);
                if (!requestingUserId.HasValue)
                {
                    return null;
                }

                if (userID > 0 && userID == requestingUserId && stencilId > 0)
                {
                    var stencil = atlasDB.CourseStencils
                                    .Where(x => x.Id == stencilId)
                                    .FirstOrDefault();
                    stencil.RemoveCourses = true;
                    stencil.CourseRemoveInitiatedByUserId = userID;
                    stencil.DateCourseRemoveInitiated = DateTime.Now;
                    stencil.UpdatedByUserId = userID;
                    stencil.DateUpdated = DateTime.Now;

                    try
                    {
                        atlasDB.SaveChanges();
                        return "";
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("There was an error removing courses. Please retry. If the problem persists! Contact support!");
                    }
                }
            }

            throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.InternalServerError)
                        {
                            Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
        }

        //POST: api/stencilcourse/createstencilcourses
        [AuthorizationRequired]
        [HttpPost]
        [Route("api/stencilcourse/createstencilcourses")]
        public object CreateStencilCourses([FromBody] FormDataCollection formBody)
        {
            this.formData = formBody;

            if (formBody.Count() > 0)
            {
                int userID = StringTools.GetInt("userId", ref formData);
                int stencilId = StringTools.GetInt("stencilId", ref formData);
                var requestingUserId = this.GetUserIdFromToken(Request);
                if (!requestingUserId.HasValue)
                {
                    return null;
                }

                if (userID > 0 && userID == requestingUserId && stencilId > 0)
                {
                    var courseStencil = atlasDB.CourseStencils
                                    .Where(x => x.Id == stencilId)
                                    .FirstOrDefault();
                    courseStencil.CreateCourses = true;
                    courseStencil.CourseCreationInitiatedByUserId = userID;
                    courseStencil.DateCourseCreationInitiated = DateTime.Now;
                    courseStencil.UpdatedByUserId = userID;
                    courseStencil.DateUpdated = DateTime.Now;

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
                        return "";
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("There was an error creating courses. Please retry. If the problem persists! Contact support!");
                    }

                }
            }

            throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.InternalServerError)
                        {
                            Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/stencilCourse/GetAvailableCourseStencils/{organisationId}/{userId}")]
        /// <summary>
        /// Returns a list of Available Courses Stencils
        /// </summary>
        /// <returns></returns>
        public object GetAvailableCourseStencils(int organisationId, int userId)
        {
            var requestingUserId = this.GetUserIdFromToken(Request);
            if (!requestingUserId.HasValue)
            {
                return null;
            }

            if (requestingUserId != userId)
            {
                return null;
            }

            var courseStencils = atlasDB.CourseStencils
                                .Include(X => X.OrganisationCourseStencils)
                                .Include("CourseStencilCourses.Course.CourseDate")
                                .Where(x => x.Disabled == false
                                    && x.OrganisationCourseStencils.Any(y => y.OrganisationId == organisationId))
                                .Select(x => new
                                {
                                    x.Name,
                                    x.Id,
                                    x.Notes,
                                    x.DateCreated,
                                    x.VersionNumber,
                                    showCreateCourses = x.CreateCourses == true ? false : true,
                                    showRemoveCourses = (x.RemoveCourses == true ? false : true) && !(x.CourseStencilCourses.Any(y => y.Course.CourseClients.Any())),
                                    showEditStencil = (x.CreateCourses == true ? false : true) && (x.EarliestStartDate > DateTime.Now),
                                })
                                .ToList()
                                .OrderBy(x=>x.Name);

            return courseStencils;
        }
    }
}