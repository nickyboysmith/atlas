using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Globalization;
using IAM.Atlas.WebAPI.Models;
using System.Data.Entity;
using System.Web.Http.ModelBinding;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseReferenceController : AtlasBaseController
    {


        [AuthorizationRequired]
        [Route("api/CourseReference/Get")]
        [HttpGet]
        public object Get()
        {

            var courseReference = from crg in atlasDB.CourseReferenceGenerators
                                  select crg;

            return courseReference;

        }

        /**
        * Get the Course Reference Trainer Settings
        */

        [AuthorizationRequired]
        [Route("api/CourseReference/GetTrainerSettings/{OrganisationId}")]
        [HttpGet]
        public object GetTrainerSettings(int OrganisationId)
        {
            var trainerReferenceGeneratorSettings =
                  atlasDB.OrganisationTrainerSettings.Where(o => o.OrganisationId == OrganisationId).FirstOrDefault();

            return trainerReferenceGeneratorSettings;

        }
        /**
        * Get the Course Reference Interpreter Settings
        */
        [AuthorizationRequired]
        [Route("api/CourseReference/GetInterpreterSettings/{OrganisationId}")]
        [HttpGet]
        public object GetInterpreterSettings(int OrganisationId)
        {

            var interpreterReferenceGeneratorSettings =
                  atlasDB.OrganisationInterpreterSettings.Where(o => o.OrganisationId == OrganisationId).FirstOrDefault();

            return interpreterReferenceGeneratorSettings;

        }

        [AuthorizationRequired]
        [Route("api/CourseReference/HasTrainerSettings/{OrganisationId}")]
        [HttpGet]
        public bool HasTrainerSettings(int OrganisationId)
        {
            return atlasDB.OrganisationTrainerSettings
                  .Any(ots => ots.OrganisationId == OrganisationId);

        }
        /**
        * Get the Course Reference Interpreter Settings
        */
        [AuthorizationRequired]
        [Route("api/CourseReference/HasInterpreterSettings/{OrganisationId}")]
        [HttpGet]
        public bool HasInterpreterSettings(int OrganisationId)
        {

            return atlasDB.OrganisationInterpreterSettings
                   .Any(ois => ois.OrganisationId == OrganisationId);

        }

        
        [AuthorizationRequired]
        [Route("api/CourseReference/SaveTrainerSettings")]
        [HttpPost]
        public string SaveTrainerSettings([FromBody] FormDataCollection formBody)
        {
            string status = "";
            try
            {
                var organisationTrainerSetting = formBody.ReadAs<OrganisationTrainerSetting>();

                organisationTrainerSetting.DateUpdated = DateTime.Now;

                if (organisationTrainerSetting.ReferencesStartWithCourseTypeCode == true)
                {
                    organisationTrainerSetting.StartAllReferencesWith = null;
                }

                atlasDB.OrganisationTrainerSettings.Attach(organisationTrainerSetting);
                var entry = atlasDB.Entry(organisationTrainerSetting);
                entry.State = System.Data.Entity.EntityState.Modified;
           
                atlasDB.SaveChanges();
                status = "Trainer Settings Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }

        [AuthorizationRequired]
        [Route("api/CourseReference/SaveInterpreterSettings")]
        [HttpPost]
        public string SaveInterpreterSettings([FromBody] FormDataCollection formBody)
        {
            string status = "";
            try
            {
                var organisationInterpreterSetting = formBody.ReadAs<OrganisationInterpreterSetting>();

                organisationInterpreterSetting.DateUpdated = DateTime.Now;

                if (organisationInterpreterSetting.ReferencesStartWithCourseTypeCode == true)
                {
                    organisationInterpreterSetting.StartAllReferencesWith = null;
                }

                atlasDB.OrganisationInterpreterSettings.Attach(organisationInterpreterSetting);
                var entry = atlasDB.Entry(organisationInterpreterSetting);
                entry.State = System.Data.Entity.EntityState.Modified;

                atlasDB.SaveChanges();
                status = "Interpreter Settings Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }


    }
}