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
using System.Data.Entity;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{

    public class CourseTypeController : AtlasBaseController
    {
        // Returns the course type available to a particular organisation
        [HttpGet]
        public object Get(int Id)
        {
            var courseTypes = atlasDBViews.vwCourseTypeDetails
                .Where(
                    courseType => courseType.OrganisationId == Id
                )
                .Select(
                    courseType => new
                    {
                        courseType.Id,
                        courseType.Title,
                        courseType.Code,
                        courseType.Description,
                        courseType.Disabled,
                        courseType.DORSOnly,
                        courseType.AdditionalInformation,
                        courseType.DaysBeforeCourseLastBooking,
                        courseType.MaxPracticalTrainers,
                        courseType.MaxTheoryTrainers
                    }
                )
                .ToList();

            return courseTypes;
        }

        [AuthorizationRequired]
        [Route("api/coursetype/GetCourseTypesByOrganisationId/{OrganisationId}")]
        [HttpGet]
        public object GetCourseTypesByOrganisationId(int OrganisationId)
        {
            var courseTypes = atlasDB.CourseType
                .Where(
                    courseType => courseType.OrganisationId == OrganisationId
                )
                .Select(
                    courseType => new
                    {
                        courseType.Id,
                        courseType.Title,
                        courseType.Code,
                        courseType.Description,
                        courseType.Disabled,
                        courseType.DORSOnly,
                        courseType.DaysBeforeCourseLastBooking
                    }
                )
                .ToList();

            return courseTypes;
        }



        // Returns the course type for that Id
        [Route("api/coursetype/getbyid/{Id}")]
        [HttpGet]
        public CourseTypeJSON GetById(int Id)
        {
            var courseType = atlasDB.CourseType
                                    .Include(c => c.Organisation)
                                    .Where(c => c.Id == Id)
                                    .Select(c => new CourseTypeJSON(){
                                        Id = c.Id,
                                        OrganisationName = c.Organisation.Name,
                                        Title = c.Title,
                                        CourseTypeName = c.Title,
                                        OrganisationId = c.OrganisationId,
                                        DORSOnly = c.DORSOnly,
                                        MaxPracticalTrainers = c.MaxPracticalTrainers,
                                        MaxTheoryTrainers = c.MaxTheoryTrainers,
                                        MinPracticalTrainers = c.MinPracticalTrainers,
                                        MinTheoryTrainers = c.MinTheoryTrainers,
                                        Code = c.Code,
                                        MaxPlaces = c.MaxPlaces,
                                        Disabled = c.Disabled
                                    })
                                    .FirstOrDefault();
            return courseType;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="courseTypeId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("api/coursetype/GetDORSScheme/{courseTypeId}")]
        public DORSScheme GetDORSScheme(int courseTypeId)
        {
            var dorsScheme = atlasDB.DORSSchemes
                                    //.Include(ds => ds.DORSSchemeCourseTypes)
                                    .Where(ds => ds.DORSSchemeCourseTypes.Any(dsct => dsct.CourseTypeId == courseTypeId))
                                    .FirstOrDefault();
            return dorsScheme;
        }

        [HttpGet]
        [Route("api/coursetype/GetCourseType/{dorsSchemeId}/{organisationId}")]
        public CourseType GetCourseType(int dorsSchemeId, int organisationId)
        {
            var courseType = atlasDB.CourseType
                                    .Include(ct => ct.DORSSchemeCourseTypes)
                                    .Where(ct => ct.OrganisationId == organisationId && ct.DORSSchemeCourseTypes.Any(dsct => dsct.DORSSchemeId == dorsSchemeId))
                                    .FirstOrDefault();
            return courseType;
        }

        // GET api/area/5
        [Route("api/coursetype/related/{Id}")]
        [HttpGet]
        public object related(int Id)
        {
            var searchResults =
            (
                from organisationUser in atlasDB.OrganisationUsers
                join organisation in atlasDB.Organisations on organisationUser.OrganisationId equals organisation.Id
                where organisationUser.UserId == Id
                select new { organisation.Id, organisation.Name }
            ).ToList();

            return searchResults;
        }

        //GET api/area/venuerelated/5
        [Route("api/coursetype/venuerelated/{VenueId}")]
        [HttpGet]
        public object venuerelated(int venueId)
        {

            var venueCourseTypes = (
                                   from vct in atlasDB.VenueCourseType
                                   join ct in atlasDB.CourseType on vct.CourseTypeId equals ct.Id
                                   where vct.VenueId == venueId
                                   select new
                                   {
                                       id = vct.Id,
                                       courseTypeName = ct.Title
                                   }
                                   ).ToList();

            return venueCourseTypes;
        }


        [HttpPost]
        [AuthorizationRequired]
        [Route("api/coursetype/AddCourseType")]
        public string AddCourseType([FromBody] FormDataCollection formBody)
        {
            
            var formData = formBody;

            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var Title = StringTools.GetString("Title", ref formData);
            var Code = StringTools.GetString("Code", ref formData);
            var Description = StringTools.GetString("Description", ref formData);
            var DORSCourse = StringTools.GetBool("DORSCourse", ref formData);
            var DORSSchemeId = StringTools.GetInt("DORSSchemeId", ref formData);
            
            string status = "";

            try
            {
                CourseType courseType = new CourseType();
                
                courseType.OrganisationId = OrganisationId;
                courseType.Title = Title;
                courseType.Code = Code;
                courseType.Description = Description;
                courseType.Disabled = false;
                courseType.DORSOnly = DORSCourse;

                //courseType.DaysBeforeCourseLastBooking = daysBeforeCourseLastBooking;

                atlasDB.CourseType.Add(courseType);
                
                if (DORSSchemeId != 0)
                {
                   
                    var dorsSchemeCourseType = new DORSSchemeCourseType();
                    dorsSchemeCourseType.CourseTypeId = courseType.Id;
                    dorsSchemeCourseType.DateCreated = DateTime.Now;
                    dorsSchemeCourseType.DORSSchemeId = DORSSchemeId;
                    atlasDB.DORSSchemeCourseTypes.Add(dorsSchemeCourseType);
                    
                }

                atlasDB.SaveChanges();

                status = "Course Type Saved Successfully";

            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error adding the Course Type. Please retry.";
            }
            
            return status;

        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/coursetype/EditCourseType")]
        public string EditCourseType([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var CourseTypeId = StringTools.GetInt("CourseTypeId", ref formData);
            var Title = StringTools.GetString("Title", ref formData);
            var Code = StringTools.GetString("Code", ref formData);
            var Description = StringTools.GetString("Description", ref formData);
            var Disabled = StringTools.GetBool("Disabled", ref formData);
            var DaysBeforeCourseLastBooking = StringTools.GetInt("DaysBeforeCourseLastBooking", ref formBody);

            string status = "";

            try
            {
                CourseType courseType = atlasDB.CourseType.Find(CourseTypeId);

                if (courseType != null)
                {

                    atlasDB.CourseType.Attach(courseType);
                    var entry = atlasDB.Entry(courseType);

                    courseType.Title = Title;
                    atlasDB.Entry(courseType).Property("Title").IsModified = true;
                    courseType.Code = Code;
                    atlasDB.Entry(courseType).Property("Code").IsModified = true;
                    courseType.Description = Description;
                    atlasDB.Entry(courseType).Property("Description").IsModified = true;
                    courseType.Disabled = Disabled;
                    atlasDB.Entry(courseType).Property("Disabled").IsModified = true;
                    courseType.DaysBeforeCourseLastBooking = DaysBeforeCourseLastBooking;
                    atlasDB.Entry(courseType).Property("DaysBeforeCourseLastBooking").IsModified = true;

                    atlasDB.SaveChanges();

                    status = "Course Type Saved Successfully";
                }
                else
                {
                    status = "Course Type could not be found";
                }
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error updating the courseType. Please retry.";
            }
            
            return status;
        }
        
        [Route("api/venuecoursetype/{VenueId}/{CourseTypeId}")]
        public string Post(int venueId, int courseTypeId)
        {

            string status = "";

            //var obj = objVenueCourseType;

            //var courseTypeId = 0;
            //var venueId = 0;

            VenueCourseType venueCourseType = new VenueCourseType();

            // just try to insert. No point checking for existence first. ???

            venueCourseType.CourseTypeId = courseTypeId;
            venueCourseType.VenueId = venueId;

            status = "success";

            try
            {

                atlasDB.VenueCourseType.Add(venueCourseType);
                atlasDB.SaveChanges();

            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error updating the venue course type. Please retry.";
            }

            return status;


        }

        [HttpGet]
        [Route("api/venuecoursetype/delete/{VenueCourseTypeId}")]
        public void Delete(int venueCourseTypeId)
        {
            var venueCourseType = atlasDB.VenueCourseType.Where(vct => vct.Id == venueCourseTypeId).FirstOrDefault();
            if (venueCourseType != null)
            {
                atlasDB.VenueCourseType.Remove(venueCourseType);
                atlasDB.SaveChanges();
            }
        }

    }
}
