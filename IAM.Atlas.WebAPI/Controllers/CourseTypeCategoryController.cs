using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Web.Http;
using System.Data.Entity;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseTypeCategoryController : AtlasBaseController 
    {
        // GET: api/CourseTypeCategory
        public IEnumerable<CourseTypeCategory> Get()
        {
            return atlasDB.CourseTypeCategories.ToList();
        }

        // GET: api/CourseTypeCategory/5
        public string Get(int id)
        {
            return "value";
        }

        [Route("api/CourseTypeCategory/GetByOrganisation/{OrganisationId}/{UserId}")]
        public object GetByOrganisation(int OrganisationId, int UserId)
        {
            // UserId redundant

          
            return atlasDB.CourseTypeCategories
                .Include("CourseType")
                .Where(ct => ct.CourseType.OrganisationId == OrganisationId)
                .Select(
                    ctc => new
                    {
                        Id = ctc.Id,
                        CourseTypeId = ctc.CourseTypeId,
                        Name = ctc.Name,
                        Disabled = ctc.Disabled

                    })
                    .OrderBy(ctc => ctc.Name)
                    .ToList();
            
        }

        [Route("api/CourseTypeCategory/GetByCourseType/{CourseTypeId}/{UserId}")]
        public object GetByCourseType(int CourseTypeId, int UserId)
        {

            // UserId redundant

            return atlasDB.CourseTypeCategories
               .Include("CourseType")
               .Where(ct => ct.CourseType.Id == CourseTypeId)
               .Select(
                   ctc => new
                   {
                       Id = ctc.Id,
                       Name = ctc.Name,
                       Disabled = ctc.Disabled,
                       DaysBeforeCourseLastBooking = ctc.DaysBeforeCourseLastBooking

                   })
                   .OrderBy(ctc => ctc.Name)
                   .ToList();

        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/CourseTypeCategory/AddCourseTypeCategory")]
        public string AddCourseTypeCategory([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var CourseTypeId = StringTools.GetInt("CourseTypeId", ref formData);
            var Name = StringTools.GetString("Name", ref formData);
            var DaysBeforeCourseLastBooking = StringTools.GetInt("DaysBeforeCourseLastBooking", ref formBody);

            // Default to 1 if value is 0
            if (DaysBeforeCourseLastBooking < 1) { DaysBeforeCourseLastBooking = 1; }

            string status = "";

            try
            {
                CourseTypeCategory courseTypeCategory = new CourseTypeCategory();

                courseTypeCategory.CourseTypeId = CourseTypeId;
                courseTypeCategory.Name = Name;
                courseTypeCategory.Disabled = false;
                courseTypeCategory.DaysBeforeCourseLastBooking = DaysBeforeCourseLastBooking;

                atlasDB.CourseTypeCategories.Add(courseTypeCategory);
                
                atlasDB.SaveChanges();

                status = "Course Type Category Saved Successfully";

            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error adding the Course Type Category. Please retry.";
            }

            return status;

        }

        
        [HttpPost]
        [AuthorizationRequired]
        [Route("api/CourseTypeCategory/EditCourseTypeCategory")]
        public string EditCourseTypeCategory([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var CourseTypeCategoryId = StringTools.GetInt("Id", ref formData);
            var Name = StringTools.GetString("Name", ref formData);
            var Disabled = StringTools.GetBool("Disabled", ref formData);
            var DaysBeforeCourseLastBooking = StringTools.GetInt("DaysBeforeCourseLastBooking", ref formBody);

            // Default to 1 if value is 0
            if (DaysBeforeCourseLastBooking < 1) { DaysBeforeCourseLastBooking = 1; }
            

            string status = "";

            try
            {
                CourseTypeCategory courseTypeCategory = atlasDB.CourseTypeCategories.Find(CourseTypeCategoryId);

                if (courseTypeCategory != null)
                {

                    atlasDB.CourseTypeCategories.Attach(courseTypeCategory);
                    var entry = atlasDB.Entry(courseTypeCategory);

                    courseTypeCategory.Name = Name;
                    atlasDB.Entry(courseTypeCategory).Property("Title").IsModified = true;
                    courseTypeCategory.Disabled = Disabled;
                    atlasDB.Entry(courseTypeCategory).Property("Disabled").IsModified = true;
                    courseTypeCategory.DaysBeforeCourseLastBooking = DaysBeforeCourseLastBooking;
                    atlasDB.Entry(courseTypeCategory).Property("DaysBeforeCourseLastBooking").IsModified = true;

                    atlasDB.SaveChanges();

                    status = "Course Type Category Saved Successfully";
                }
                else
                {
                    status = "Course Type Category could not be found";
                }
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error updating the Course Type Category. Please retry.";
            }

            return status;
        }
        
        // PUT: api/CourseTypeCategory/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/CourseTypeCategory/5
        public void Delete(int id)
        {
        }
    }
}
