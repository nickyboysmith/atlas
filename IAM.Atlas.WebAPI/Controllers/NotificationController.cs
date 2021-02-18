using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using System.Web.Http.Cors;
using System.Net.Http.Formatting;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class NotificationController : AtlasBaseController
    {

        // First Part Union - Get Messages flagged for AllUsers NOT been Acknowledged/Disabled.
        // Second Part Union - Get Specific Messages for a User NOT been Acknowledged/Disabled .

        [AuthorizationRequired]
        public NotificationJSON Get(int Id)
        {

            var allmessages = (
                               from m in atlasDB.Message
                               join mc in atlasDB.MessageCategory on m.MessageCategoryId equals mc.Id
                               where !atlasDB.MessageAcknowledgement.Any(ma => (ma.MessageId == m.Id && ma.UserId == Id))
                               && (m.AllUsers == true) & (m.Disabled == false)
                               select new 
                               {
                                   Id = m.Id,
                                   Title = m.Title,
                                   Content = m.Content,
                                   Disabled = m.Disabled,
                                   AllUsers = m.AllUsers,
                                   CategoryId = mc.Id,
                                   CategoryName = mc.Name,
                                   CategoryColour = mc.CategoryColour
                               }
                           )
                    .Union(
                               from m in atlasDB.Message
                               join mr in atlasDB.MessageRecipient on m.Id equals mr.MessageId
                               join mc in atlasDB.MessageCategory on m.MessageCategoryId equals mc.Id
                               where !atlasDB.MessageAcknowledgement.Any(ma => (ma.MessageId == m.Id && ma.UserId == Id))
                               && (m.AllUsers == false) && (mr.UserId == Id) && (m.Disabled == false)
                               select new 
                               {
                                   Id = m.Id,
                                   Title = m.Title,
                                   Content = m.Content,
                                   Disabled = m.Disabled,
                                   AllUsers = m.AllUsers,
                                   CategoryId = mc.Id,
                                   CategoryName = mc.Name,
                                   CategoryColour = mc.CategoryColour
                               }
                           );
            
            List<MessageCategoryJSON> mcvArray = new List<MessageCategoryJSON>();
            List<MessageJSON> mvArray = new List<MessageJSON>();
            NotificationJSON nv = new NotificationJSON();
            MessageCategoryJSON mcv = new MessageCategoryJSON();
            MessageJSON mv = new MessageJSON();

            if (allmessages.Count() > 0)
            {
                
                var categories = (
                    
                    from am in allmessages select new { CategoryId = am.CategoryId, 
                                                        CategoryName = am.CategoryName, 
                                                        CategoryColour = am.CategoryColour }
                    ).Distinct();

                foreach (var category in categories)
                {

                    mcv = new MessageCategoryJSON();

                    mcv.CategoryId = category.CategoryId;
                    mcv.CategoryName = category.CategoryName;
                    mcv.CategoryColour = category.CategoryColour;

                    var categoryMessages = allmessages
                                            .Where(msg => msg.CategoryId == mcv.CategoryId)
                                            .Take(20)
                                            .Select(msg => new MessageJSON()
                                            {
                                                Id = msg.Id,
                                                Title = msg.Title,
                                                Content = msg.Content,
                                                Disabled = msg.Disabled,
                                                AllUsers = msg.AllUsers
                                            })
                                            .ToArray();
                    
                    mcv.message = categoryMessages;
                    mcvArray.Add(mcv);

                    nv.messageCategory = mcvArray.ToArray();

                    mvArray.Clear();
                   
                }
 
            }
            
            return nv;
        }


        [Route("api/Notification")]
        public string Post([FromBody] FormDataCollection formBody)
        {

            // Check thhat the data is correct
            var userId = StringTools.GetIntOrFail("userId", ref formBody, "Please select a valid User Id");
            var messageId = StringTools.GetIntOrFail("messageId", ref formBody, "The message you tried to acknowledge doesn't exist.");

            // Process status
            var status = "";

            try
            {

                MessageAcknowledgement acknowledged = new MessageAcknowledgement();
                acknowledged.UserId = userId;
                acknowledged.MessageId = messageId;
                acknowledged.DateAcknowledged = DateTime.Now;

                atlasDB.MessageAcknowledgement.Add(acknowledged);

                atlasDB.SaveChanges();

                status = "Your message has been acknowledged successfully";

            } catch (DbEntityValidationException ex) {
                Error.FrontendHandler(
                    HttpStatusCode.InternalServerError, 
                    "There has been a problem processing your request please try again shortly."
                );
            }

            return status;

        }


    }
}
       
       

    



