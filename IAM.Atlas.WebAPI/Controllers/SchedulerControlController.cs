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
using System.Reflection;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SchedulerControlController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/SchedulerControl/Get")]
        [HttpGet]
        public object Get()
        {
            var schedulerControl =
                  atlasDB.SchedulerControl.Where(sc => sc.Id == 1).FirstOrDefault();

            return schedulerControl;
        }


        [AuthorizationRequired]
        [Route("api/SchedulerControl/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {

            var fieldToUpdate = StringTools.GetString("FieldToUpdate", ref formBody);
            var value = StringTools.GetBool("Value", ref formBody);
            var UserId = StringTools.GetInt("UserId", ref formBody);

            var schedulerControl = atlasDB.SchedulerControl.Find(1);
            atlasDB.SchedulerControl.Attach(schedulerControl);
            var entry = atlasDB.Entry(schedulerControl);

            schedulerControl.DateUpdated = DateTime.Now;
            schedulerControl.UpdatedByUserId = UserId;

            foreach (PropertyInfo property in typeof(SchedulerControl).GetProperties())
            {
                if (property.Name == fieldToUpdate)
                {
                    property.SetValue(schedulerControl, value);
                    entry.Property(fieldToUpdate).IsModified = true;
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
