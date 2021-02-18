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
using IAM.Atlas.WebAPI.Classes;
using System.ComponentModel.DataAnnotations;

namespace IAM.Atlas.WebAPI.Controllers
{

    public class SendEmailController : AtlasBaseController
    {

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/SendEmail/SendEmail")]
        public string SendEmail([FromBody] FormDataCollection formBody)
        {
            var userId = StringTools.GetIntOrFail("userId", ref formBody, "User needs to be present");
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "User needs to be present");
            var emailAddress = StringTools.GetStringOrFail("address", ref formBody, "You need to set an Email Address");
            var ccEmailAddress = StringTools.GetString("cc", ref formBody);
            var bccEmailAddress = StringTools.GetString("bcc", ref formBody);
            var subject = StringTools.GetStringOrFail("subject", ref formBody, "You need to set a subject");
            var content = StringTools.GetStringOrFail("content", ref formBody, "You need to enter some content");
            int? pendingEmailAttachmentId = null;
            int? clientId = StringTools.GetInt("clientId", ref formBody);
            if (clientId == 0)
            {
                clientId = null;
            }
            int? letterTemplateId = StringTools.GetInt("letterTemplateId", ref formBody);
            if (letterTemplateId == 0)
            {
                letterTemplateId = null;
            }
            string fromEmailAddress;
            string fromName;
            var sendAsap = true;
            var emailServiceId = 0;
            var attachedDocumentIds = new List<int>
            {
                StringTools.GetInt("documentId", ref formBody),
                StringTools.GetInt("documentId2", ref formBody),
                StringTools.GetInt("documentId3", ref formBody),
                StringTools.GetInt("documentId4", ref formBody),
                StringTools.GetInt("documentId5", ref formBody),
                StringTools.GetInt("documentId6", ref formBody),
                StringTools.GetInt("documentId7", ref formBody),
                StringTools.GetInt("documentId8", ref formBody),
                StringTools.GetInt("documentId9", ref formBody)

            };

            attachedDocumentIds.RemoveAll(adi => adi == 0);

            try
            {
                var systemController = new SystemControlController();
                var systemControl = systemController.Get();

                fromEmailAddress = (string)systemControl.GetType().GetProperty("AtlasSystemFromEmail").GetValue(systemControl, null);
                fromName = (string)systemControl.GetType().GetProperty("AtlasSystemFromName").GetValue(systemControl, null);
            }
            catch
            {
                throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                        {
                            Content = new StringContent("Unable to retieve System Conrol 'from email address' or 'from name'. Please contact your system administrator."),
                            ReasonPhrase = "Invalid call to System Control"
                        }
                    );
            }
            if (string.IsNullOrEmpty(ccEmailAddress) == false)
            {
                if (new EmailAddressAttribute().IsValid(ccEmailAddress) == false)
                {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                        {
                            Content = new StringContent("Please enter a valid cc emial address"),
                            ReasonPhrase = "Invalid cc email address"
                        }
                    );
                }
            }

            if (string.IsNullOrEmpty(bccEmailAddress) == false)
            {
                if (new EmailAddressAttribute().IsValid(bccEmailAddress) == false)
                {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                        {
                            Content = new StringContent("Please enter a valid bcc emaill address"),
                            ReasonPhrase = "Invalid bcc email address"
                        }
                    );
                }
            }

            if (attachedDocumentIds.Count > 0)
            {
                for (int i = 0; i < attachedDocumentIds.Count; i++)
                {
                    var pendingEmailAttachment = new PendingEmailAttachment();
                    pendingEmailAttachment.DocumentId = attachedDocumentIds[i];
                    pendingEmailAttachment.DateAdded = DateTime.Now;

                    if (i != 0)
                    {
                        pendingEmailAttachment.SameEmailAs_PendingEmailAttachmentId = pendingEmailAttachmentId;
                    }

                    atlasDB.PendingEmailAttachments.Add(pendingEmailAttachment);

                    if (i == 0)
                    {
                        atlasDB.SaveChanges();
                        pendingEmailAttachmentId = pendingEmailAttachment.Id;
                    }

                    // record the document's download in the ClientChangeLog
                    if(clientId != null)
                    {
                        var documentId = attachedDocumentIds[i];
                        var document = atlasDB.Documents.Where(d => d.Id == documentId).FirstOrDefault();
                        if (document != null)
                        {
                            var clientChangeLog = new ClientChangeLog();
                            clientChangeLog.DateCreated = DateTime.Now;
                            clientChangeLog.ChangeType = "Documents Emailed";
                            clientChangeLog.ClientId = (int) clientId;
                            clientChangeLog.Comment = "Document '" + document.Title + "' was emailed.";
                            clientChangeLog.AssociatedUserId = userId;

                            atlasDB.ClientChangeLogs.Add(clientChangeLog);
                        }
                    }
                }
                atlasDB.SaveChanges();
            }
            else
            {
                pendingEmailAttachmentId = null;
            }

            try
            {
                var emailService = atlasDB.OrganisationPrefferedEmailService
                .Where(
                    theEmailService => theEmailService.OrganisationId == organisationId
                )
                .First();
                emailServiceId = emailService.EmailServiceId;
            }
            catch (DbEntityValidationException ex)
            {
                // The exception
            }
            catch (Exception ex)
            {
                // The exception
            }

            // If the org hasnt set an email provider
            if (emailServiceId == 0)
            {
                try
                {
                    // find provider 
                    // that isnt disabled
                    var emailService = atlasDB.EmailService
                    .Where(
                        theEmailService => theEmailService.Disabled == false
                    )
                    .ToList();

                    var providerCount = emailService.Count;
                    var rnd = new Random();
                    var index = rnd.Next(0, providerCount);

                    emailServiceId = emailService[index].Id;


                }
                catch (DbEntityValidationException ex)
                {
                    emailServiceId = -1;
                }
                catch (Exception ex)
                {
                    emailServiceId = -1;
                }

            }

            // IF we cant find an email provider for whatever reason
            if (emailServiceId == -1)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("Our emailer is currently unavailable"),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }

            try
            {
                atlasDB.uspSendEmail(
                    userId,
                    fromName,
                    fromEmailAddress,
                    emailAddress,
                    ccEmailAddress,
                    bccEmailAddress,
                    subject,
                    content,
                    sendAsap,
                    DateTime.Now,
                    emailServiceId,
                    organisationId,
                    false,
                    pendingEmailAttachmentId,
                    letterTemplateId,
                    clientId
                );

                return "Email Scheduled";

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("Something has gone wrong trying to send your email"),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
            catch (Exception ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("Something has gone wrong trying to send your email"),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }


        }

    }
}