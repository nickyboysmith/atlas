using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;
using System.Net.Http;
using System.Net;
using System.Web;
using System.Reflection;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ArchiveControlController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/ArchiveControl/Get")]
        [HttpGet]
        public object Get()
        {

            var systemControl = atlasDB.SystemControls
                    .Where(sc => sc.Id == 1)
                    .Select(sc => new
                    {
                        ArchiveEmailsAfterDaysDefault = sc.ArchiveEmailsAfterDaysDefault,
                        ArchiveSMSsAfterDaysDefault = sc.ArchiveSMSsAfterDaysDefault,
                        DeleteEmailsAfterDaysDefault = sc.DeleteEmailsAfterDaysDefault,
                        DeleteSMSsAfterDaysDefault = sc.DeleteSMSsAfterDaysDefault
                    }).Single();

            return systemControl;
        }

        [AuthorizationRequired]
        [Route("api/ArchiveControl/GetArchiveSettingsByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetArchiveSettingsByOrganisation(int OrganisationId)
        {

            var organisationArchiveControl = atlasDB.OrganisationArchiveControls
                    .Where(sc => sc.OrganisationId == OrganisationId)
                    .Single();

            return organisationArchiveControl;
        }


        [AuthorizationRequired]
        [Route("api/ArchiveControl/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {
            var archiveFields = (from fb in formBody
                                 where fb.Key.Contains("AfterDaysDefault")
                                 select new { fb.Key, fb.Value });

            var archiveControl = atlasDB.SystemControls.Find(1);
            atlasDB.SystemControls.Attach(archiveControl);
            var entry = atlasDB.Entry(archiveControl);

            foreach (PropertyInfo property in typeof(SystemControl).GetProperties())
            {
                foreach (var field in archiveFields)
                {
                    if (property.Name == field.Key)
                    {
                        // Change the field value to it's underlying type
                        var newFieldValue = Convert.ChangeType(field.Value, property.PropertyType);

                        if (!Equals(property.GetValue(archiveControl, null), newFieldValue))
                        {
                            property.SetValue(archiveControl, newFieldValue);
                            entry.Property(field.Key).IsModified = true;
                        }  
                    }
                }
            }
            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }


        [AuthorizationRequired]
        [Route("api/ArchiveControl/SaveArchiveSettingsByOrganisation")]
        [HttpPost]
        public void SaveArchiveSettingsByOrganisation([FromBody] FormDataCollection formBody)
        {


            var Id = StringTools.GetInt("Id", ref formBody);

            var archiveFields = (from fb in formBody
                                 where fb.Key.Contains("AfterDays")
                                 select new { fb.Key, fb.Value });

            //Int32.Parse(Id)


            var organisationArchiveControl = atlasDB.OrganisationArchiveControls.Find(Id);


            atlasDB.OrganisationArchiveControls.Attach(organisationArchiveControl);
            var entry = atlasDB.Entry(organisationArchiveControl);

            foreach (PropertyInfo property in typeof(OrganisationArchiveControl).GetProperties())
            {
                foreach (var field in archiveFields)
                {
                    if (property.Name == field.Key)
                    {
                        // Change the field value to it's underlying type
                        var newFieldValue = Convert.ChangeType(field.Value, property.PropertyType);

                        if (!Equals(property.GetValue(organisationArchiveControl, null), newFieldValue))
                        {
                            property.SetValue(organisationArchiveControl, newFieldValue);
                            entry.Property(field.Key).IsModified = true;
                        }
                    } 
                }
            }
            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }
    }
}