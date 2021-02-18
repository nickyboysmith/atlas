using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SystemTaskController : AtlasBaseController
    {
        //    // GET: api/CourseTypeCategory
        //    public IEnumerable<CourseTypeCategory> Get()
        //    {
        //        return atlasDB.CourseTypeCategories.ToList();
        //    }

        //    // GET: api/CourseTypeCategory/5
        //    public string Get(int id)
        //    {
        //        return "value";
        //    }
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/SystemTask/GetByOrganisation/{organisationId}/{userId}")]
        public IEnumerable<object> GetByOrganisation(int organisationId, int userId)
        {
            var isAdmin = atlasDB.SystemAdminUsers.Any(x => x.UserId == userId);

            var searchResults = atlasDB.OrganisationSystemTaskMessagings
                                .Include("SystemTasks")
                                .Where(x => x.OrganisationId == organisationId && (x.Organisation.OrganisationUsers.Any(y => y.UserId == userId) || isAdmin))
                                .Select(z => new { z.Id, z.SystemTask.Title, z.SystemTask.Description, z.SendMessagesViaEmail, z.SendMessagesViaInternalMessaging, z.SystemTask.EmailOptionCaption, z.SystemTask.InternalMessageOptionCaption })
                                .ToList();
            return searchResults;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/SystemTask")]
        public void Post([FromBody] FormDataCollection formBody)
        {
            FormDataCollection formData = formBody;

            var Id = StringTools.GetInt("Id", ref formData);
            var UserId = StringTools.GetInt("UserId", ref formData);
            var SendMessagesViaEmail = StringTools.GetBool("SendMessagesViaEmail", ref formData);
            var SendMessagesViaInternalMessaging = StringTools.GetBool("SendMessagesViaInternalMessaging", ref formData);

            var organisationSystemTaskMessaging = atlasDB.OrganisationSystemTaskMessagings
                .Where(x => x.Id == Id)
                .FirstOrDefault();
            if (organisationSystemTaskMessaging != null)
            {
                organisationSystemTaskMessaging.SendMessagesViaEmail = SendMessagesViaEmail;
                organisationSystemTaskMessaging.SendMessagesViaInternalMessaging = SendMessagesViaInternalMessaging;
                organisationSystemTaskMessaging.UpdatedByUserId = UserId;
                organisationSystemTaskMessaging.DateUpdated = DateTime.Now;
            }
            atlasDB.SaveChanges();
        }
    }

    //// PUT: api/CourseTypeCategory/5
    //public void Put(int id, [FromBody]string value)
    //{
    //}

    //// DELETE: api/CourseTypeCategory/5
    //public void Delete(int id)
    //{
    //}
}

