using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class FeedbackController : AtlasBaseController
    {

        protected FormDataCollection formData;

        // GET api/<controller>
        public IEnumerable<UserFeedback> Get()
        {
            return atlasDB.UserFeedbacks.ToList();
        }

        // GET api/<controller>/5
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formBody)
        {
            string status = "";
            this.formData = formBody;

            UserFeedback feedback = new UserFeedback();

            feedback.Body = StringTools.GetString("body", ref formData);
            feedback.Title = StringTools.GetString("title", ref formData);
            feedback.UserId = StringTools.GetInt("userId", ref formData);
            var userAgent = StringTools.GetString("currentBrowser", ref formData);
            feedback.UserAgent = userAgent.Length <= 200 ? userAgent : userAgent.Substring(0, 200);
            feedback.CurrentUrl = StringTools.GetString("currentUrl", ref formData);
            feedback.OS = StringTools.GetString("currentOS", ref formData);
            feedback.PageIdentifier = StringTools.GetString("pageId", ref formData);
            // feedback.IPAddress = GetIPAddress();
            feedback.Email = StringTools.GetString("email", ref formData);
            feedback.CreationDate = DateTime.Now;
            feedback.ResponseRequired = StringTools.GetBool("responseRequired", ref formData);
            feedback.MessageSent = false;
            feedback.AdditionalInfo += StringTools.GetString("currentModals", ref formData);
            feedback.AdditionalInfo += ", Admin User:" + (StringTools.GetBool("isAdmin", ref formData) == true ? "True" : "False");
            try
            {
                atlasDB.UserFeedbacks.Add(feedback);
                atlasDB.SaveChanges();
                status = "success";
            }
            catch (DbEntityValidationException ex)
            {
                status = "error: data validation error";
            }

            return status;
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }
    }
}