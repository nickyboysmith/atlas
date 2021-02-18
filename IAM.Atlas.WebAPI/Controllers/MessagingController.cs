using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using System.Linq.Dynamic;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.Data;
using System;
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class MessagingController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/messaging/getCategories/")]
        [HttpGet]
        public object GetCategories()
        {
            try
            {
                return atlasDB.MessageCategory.ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/messaging/getUserDetails/{OrganisationId}/{SearchText}")]
        [HttpGet]
        public object GetUserDetails(int OrganisationId, string SearchText)
        {
            var updatedSearchText = SearchText.ToString().Replace("%20", " ");
            
            try
            {
                return atlasDBViews
                    .vwUserDetails
                    .Where(
                        ud => ud.OrganisationId == OrganisationId &&
                        ud.UserName.Contains(updatedSearchText)
                    )
                    .Select(
                        username => new
                        {
                            username.UserId,
                            username.UserName
                        }
                    )
                    .Distinct()
                    .Take(15)
                    .ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }
        

        [AuthorizationRequired]
        [Route("api/messaging/Send")]
        [HttpPost]
        public void Send([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var CategoryId = StringTools.GetInt("CategoryId", ref formData);
            var UserId = StringTools.GetInt("UserId", ref formData);
            var UserLevel = StringTools.GetString("UserLevel", ref formData);
            var MessageContent = StringTools.GetString("Message", ref formData);
            var CreatedByUserId = StringTools.GetInt("CreatedByUserId", ref formData);

            // Create the message
            Message message = new Message();
            message.Title = "Internal System Message";
            message.Content = MessageContent;
            message.CreatedByUserId = CreatedByUserId;
            message.DateCreated = DateTime.Now;
            message.MessageCategoryId = CategoryId;
            message.Disabled = false;

            // Construct dynamic where clause
            string wherecondition = "";

            if (UserLevel == "All")
            {
                message.AllUsers = true;
                wherecondition = "OrganisationId == " + OrganisationId;
   
            }
            else if (UserLevel == "Individual")
            {
                message.AllUsers = false;
                wherecondition = "OrganisationId == " + OrganisationId + " && UserId == " + UserId;

            }
            else
            {
                message.AllUsers = false;
                wherecondition = "OrganisationId == " + OrganisationId + " && " + UserLevel + " == true ";
            }


            // Add Message
            atlasDB.Message.Add(message);

            // Retrieve Recipients
            var toInsert = atlasDBViews
                   .vwUserDetails
                   .Where(wherecondition)
                   .Select(
                       username => new
                       {
                           UserId = username.UserId,
                           MessageId = message.Id
                       }
                   ).Distinct();


            // Add Recipients
            foreach (var mr in toInsert)
            {
                MessageRecipient newMessageRecipient = new MessageRecipient();
                newMessageRecipient.UserId = mr.UserId;
                newMessageRecipient.MessageId = mr.MessageId;
                atlasDB.MessageRecipient.Add(newMessageRecipient);
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


