using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.IO;
using System.Web.Http;
using System.Dynamic;
using RestSharp;
using Newtonsoft.Json;
using IAM.Atlas.Data;
using System.Data.Entity.Validation;
using System.Reflection;
using IAM.Atlas.Scheduler.WebService.Classes;
using IAM.Atlas.Scheduler.WebService.Models;
using IAM.Atlas.Scheduler.WebService.Classes.Email;
using System.Data.Entity;
using IAM.Atlas.Scheduler.WebService.Models.Email;
using System.Text;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XEmailController : XBaseController
    {
        private SystemControl _systemControl = null;

        SystemControl systemControl
        {
            get
            {
                if (_systemControl == null)
                {
                    _systemControl = atlasDB.SystemControls.FirstOrDefault();
                }
                return _systemControl;
            }
        }

        public enum emailStatus
        {
            Failed = 0,
            Pending,
            Sent
        }
        public object Get()
        {

            var emailsProcessed = false;
            var emailScheduleDisabled = true;
            var schedulerControl = atlasDB.SchedulerControl.FirstOrDefault();

            if (schedulerControl != null)
            {
                emailScheduleDisabled = schedulerControl.EmailScheduleDisabled == null ? true : (bool)schedulerControl.EmailScheduleDisabled;
            }
            if (!emailScheduleDisabled)
            {
                DateTime currentDate = System.DateTime.Now;

                // Get the list of Specified and Non Specfied Emails
                var pendingEmails = new
                {
                    Specified = atlasDBViews.vwEmailsReadyToBeSents
                        .Where(
                            pending =>
                                currentDate >= pending.SendEmailAfter &&
                                !string.IsNullOrEmpty(pending.EmailServiceName)
                        )
                        .ToList(),
                    NotSpecified = atlasDBViews.vwEmailsReadyToBeSents
                        .Where(
                            pendingEmail =>
                                currentDate >= pendingEmail.SendEmailAfter &&
                                string.IsNullOrEmpty(pendingEmail.EmailServiceName)
                        )
                        .ToList()
                };

                // Send the Specified Emails
                foreach (var email in pendingEmails.Specified)
                {
                    ProcessEmailSend((int)email.EmailServiceId, email);
                }

                // Deal with the Non Specified Emails
                var emailServiceProviders = GetEmailServiceProviders();
                var emailProviderIndex = 0;

                var serviceProviderCount = emailServiceProviders.Count;

                if (serviceProviderCount != 0)
                {
                    foreach (var email in pendingEmails.NotSpecified)
                    {
                        var currentEmailServiceId = emailServiceProviders[emailProviderIndex].Id;

                        // Process the email send
                        ProcessEmailSend(currentEmailServiceId, email);

                        emailProviderIndex++;
                        if (emailProviderIndex == emailServiceProviders.Count)
                        {
                            emailProviderIndex = 0;
                        }
                    }
                    emailsProcessed = true;
                }
                else
                {
                    emailsProcessed = false;
                }


            }
            return emailsProcessed;
        }

        private void ProcessEmailSend(int EmailServiceId, vwEmailsReadyToBeSent Email)
        {

            var emailServiceDisabled = IsEmailServiceDisabled(EmailServiceId);
            var emailServiceCredentials = new Object();
            var emailResponse = new EmailResult();

            // If the email service is disabled
            if (emailServiceDisabled == true)
            {
                LogDisabledEmailServiceProvider(Email);
            }

            // If the email service is not disabled
            if (emailServiceDisabled == false)
            {

                var getEmailServiceDetail = atlasDB.EmailService.Find(EmailServiceId);


                // get the credentials
                emailServiceCredentials = GetEmailServiceCredentials(EmailServiceId);

                // Do stuff based upon the email response
                emailResponse = SendEmail(Email, EmailServiceId, getEmailServiceDetail.Name, emailServiceCredentials);

                // Process the email Failure or success
                // @todo change method here
                // TO accommodate new EmailResult Object

                HandleEmailSentResponse(emailResponse.HasEmailSucceded, emailResponse.Message, Email.EmailId, EmailServiceId, Email.OrganisationId);
            }

        }

        // Check to see if the email service is disabled Returns a boolen
        private bool IsEmailServiceDisabled(int EmailServiceId)
        {
            var theEmailServiceCredentials = atlasDB.EmailService
                .Where(
                    service =>
                        service.Id == EmailServiceId
                )
                .FirstOrDefault();

            if (theEmailServiceCredentials == null)
            {
                return true;
            }

            return Convert.ToBoolean(theEmailServiceCredentials.Disabled);
        }

        // Creates a new dynamic object with the Email service credentials 
        private object GetEmailServiceCredentials(int EmailServiceId)
        {

            var theEmailServiceCredentials =
                atlasDB.EmailServiceCredentials
                .Where(
                    credentials =>
                        credentials.EmailServiceId == EmailServiceId
                )
                .Select(
                    serviceCredentials => new
                    {
                        Key = serviceCredentials.Key,
                        Value = serviceCredentials.Value
                    }
                )
                .ToList();


            // Create New Expando Object
            dynamic emailKeys = new ExpandoObject();
            var emailObject = emailKeys as IDictionary<String, object>;

            // Loop through the keys
            foreach (var theKey in theEmailServiceCredentials)
            {
                emailObject[theKey.Key] = theKey.Value;
            }

            return emailKeys;

        }

        private List<EmailService> GetEmailServiceProviders()
        {
            return atlasDB.EmailService
                .Where(
                    email =>
                        email.Exclusive != true &&
                        email.Disabled == false
                )
                .ToList();
        }

        // If the Service provider is disabled
        // Create a new entry in the message table
        // Get all email addressess of support users
        // Then send an email to them
        private void LogDisabledEmailServiceProvider(vwEmailsReadyToBeSent EmailDetails)
        {

            var emailDetails = EmailDetails as IDictionary<String, object>;

            var messageSubject = (EmailDetails.EmailServiceName) + " is disabled";
            var messageContent = "This email service has been flagged as disabled. The user will need to do somehting in order to make this happen";
            var organisationId = EmailDetails.OrganisationId;


            try
            {

                // Add to the message Table
                Message message = new Message();
                message.Title = messageSubject;
                message.Content = messageContent;
                message.MessageCategoryId = 4;
                message.DateCreated = DateTime.Now;
                message.Disabled = false;
                message.AllUsers = false;
                message.CreatedByUserId = 1;

                atlasDB.Message.Add(message);


                // Get a list of the support users
                var supportUserEmails = atlasDB
                    .SystemSupportUsers
                    .Include("Users")
                    .Select(support =>
                        new
                        {
                            support.User.Email,
                            support.User.Name
                        })
                    .ToList();

                // If there are support users in the table 
                // Add to Email Queue 
                if (supportUserEmails.Count > 0)
                {
                    foreach (var emailToSend in supportUserEmails)
                    {

                        ScheduledEmail scheduledEmail = new ScheduledEmail();
                        scheduledEmail.FromName = "";
                        scheduledEmail.FromEmail = "";
                        scheduledEmail.Content = messageContent;
                        scheduledEmail.Subject = messageSubject;
                        scheduledEmail.DateCreated = DateTime.Now;
                        scheduledEmail.Disabled = false;
                        scheduledEmail.ASAP = false;
                        scheduledEmail.ScheduledEmailStateId = 1; // 1 is Pending (As of 09/02/2016)
                        scheduledEmail.SendAtempts = 0;
                        scheduledEmail.SendAfter = DateTime.Now;
                        scheduledEmail.DateScheduledEmailStateUpdated = DateTime.Now;


                        ScheduledEmailTo scheduledEmailTo = new ScheduledEmailTo();
                        scheduledEmailTo.ScheduledEmail = scheduledEmail;
                        scheduledEmailTo.Name = emailToSend.Name;
                        scheduledEmailTo.Email = emailToSend.Email;
                        scheduledEmailTo.BCC = false;
                        scheduledEmailTo.CC = false;

                        OrganisationScheduledEmail organisationScheduledEmail = new OrganisationScheduledEmail();
                        organisationScheduledEmail.ScheduledEmail = scheduledEmail;
                        organisationScheduledEmail.OrganisationId = organisationId;

                        atlasDB.ScheduledEmailTo.Add(scheduledEmailTo);
                        atlasDB.OrganisationScheduledEmails.Add(organisationScheduledEmail);
                    }

                }

                atlasDB.SaveChanges();



            }
            catch (DbEntityValidationException ex)
            {
                CreateSystemTrappedErrorDBEntry(systemControl.AtlasSystemType + ", LogDisabledEmailServiceProvider"
                                                , "ERROR: " + ex.Message
                                                    + "\r\n ........ StackTrace: " + ex.StackTrace
                                                );
            }

        }

        private void HandleEmailSentResponse(
            bool EmailSentSuccessfully,
            string EmailResponseMessage,
            int EmailId,
            int EmailServiceId,
            int? OrganisationId)
        {


            // If a Boolean is returned
            // There are no errors
            // So Update the successful message
            if (EmailSentSuccessfully == true)
            {
                UpdateOnSuccessfulSend(EmailId);
            }

            // If a string  is returned
            // Then there is an error
            // Update the failures
            if (EmailSentSuccessfully == false)
            {
                UpdateOnFailedSend(EmailId, EmailServiceId, EmailResponseMessage, OrganisationId);
            }
        }

        private EmailSenderDetails EmailFromDetails(int? OrganisationId)
        {
            var emailDetails = new EmailSenderDetails();

            //  Set the email and name as empty strings
            // if there isnt a valid record 
            // The email sending log will pick it up
            emailDetails.FromEmail = "";
            emailDetails.FromName = "";

            try
            {
                var organisationSystemConfig = atlasDB.OrganisationSystemConfigurations
                .Where(
                    configuation => configuation.OrganisationId == OrganisationId
                );

                // Check to see if 
                // There is a record int he system config
                // For the sepecified organisation
                if (organisationSystemConfig.Count() != 0)
                {

                    emailDetails = organisationSystemConfig
                        .Select(
                            config => new EmailSenderDetails
                            {
                                FromEmail = config.FromEmail,
                                FromName = config.FromName
                            }
                        )
                        .FirstOrDefault();
                }
            }
            catch (Exception ex)
            {
                // do something else
                CreateSystemTrappedErrorDBEntry(systemControl.AtlasSystemType + ", EmailSenderDetails"
                                                , "ERROR: " + ex.Message
                                                    + "\r\n ........ StackTrace: " + ex.StackTrace
                                                );
            }

            return emailDetails;

        }

        private EmailResult SendEmail(vwEmailsReadyToBeSent EmailDetails, int EmailServiceId, string EmailServiceName, object EmailCredentials)
        {
            var emailCredentials = EmailCredentials as IDictionary<String, object>;
            var emailServiceEndPoint = emailCredentials["url"].ToString();

            var emailSenderDetails = EmailFromDetails(EmailDetails.OrganisationId);

            // Cr3eate a dynamic object
            // To hold the Data to pass to the email service profile
            dynamic ProfileDetails = new ExpandoObject();
            var profileObject = ProfileDetails as IDictionary<String, object>;

            profileObject["Content"] = EmailDetails.EmailContent;
            profileObject["Subject"] = EmailDetails.EmailSubject;
            profileObject["FromEmail"] = EmailDetails.EmailFromEmail;
            profileObject["FromName"] = EmailDetails.EmailFromName;
            profileObject["SendEmailTo"] = EmailDetails.EmailToAddress;
            profileObject["Attachment1"] = EmailDetails.EmailAttachmentPath1;
            profileObject["Attachment2"] = EmailDetails.EmailAttachmentPath2;
            profileObject["Attachment3"] = EmailDetails.EmailAttachmentPath3;
            profileObject["Attachment4"] = EmailDetails.EmailAttachmentPath4;
            profileObject["Attachment5"] = EmailDetails.EmailAttachmentPath5;
            profileObject["Attachment6"] = EmailDetails.EmailAttachmentPath6;
            profileObject["Attachment7"] = EmailDetails.EmailAttachmentPath7;
            profileObject["Attachment8"] = EmailDetails.EmailAttachmentPath8;
            profileObject["Attachment9"] = EmailDetails.EmailAttachmentPath9;

            // Now Loop through the Credentials 
            // Then add them to the dynamic object
            foreach (var profileDetails in emailCredentials)
            {
                profileObject[profileDetails.Key] = profileDetails.Value;
            }

            var processEmail = new ProcessEmail();
            EmailResult send = processEmail.Start(EmailServiceName, emailServiceEndPoint, ProfileDetails, EmailDetails.EmailId, "Send");

            // Log the email service processed by Id here
            UpdateEmailProcessedByService(EmailServiceId, EmailDetails.EmailId);

            // Execute the request
            return send;
        }


        private void UpdateEmailProcessedByService(int EmailServiceId, int EmailId)
        {
            // Put in a try catch
            var emailDetails = atlasDB.ScheduledEmails.Find(EmailId);
            emailDetails.EmailProcessedEmailServiceId = EmailServiceId;
            var entry = atlasDB.Entry(emailDetails);
            entry.State = System.Data.Entity.EntityState.Modified;
            atlasDB.SaveChanges();
        }

        private void UpdateOnSuccessfulSend(int EmailId)
        {
            // Put in a try catch
            var emailDetails = atlasDB.ScheduledEmails.Find(EmailId);
            emailDetails.ScheduledEmailStateId = 2; // 2 is Sent (As of 09/02/2016)
            emailDetails.DateScheduledEmailStateUpdated = DateTime.Now;
            var entry = atlasDB.Entry(emailDetails);
            entry.State = System.Data.Entity.EntityState.Modified;
            atlasDB.SaveChanges();
        }

        private void UpdateOnFailedSend(int EmailId, int EmailServiceId, string ErrorMessage, int? OrganisationId)
        {
            try
            {
                // Get ScheduledEmailObject from  EmailId
                var emailDetails = atlasDB.ScheduledEmails.Find(EmailId);
                emailDetails.ScheduledEmailStateId = 3; // 3 is Failed - Retrying (As of 16/02/2016)
                emailDetails.DateScheduledEmailStateUpdated = DateTime.Now;
                emailDetails.SendAfter = DateTime.Now.AddMinutes(30);
                emailDetails.SendAtempts = (emailDetails.SendAtempts) + 1;
                var entry = atlasDB.Entry(emailDetails);
                entry.State = System.Data.Entity.EntityState.Modified;

                // Insert into the email sending failure
                EmailServiceSendingFailure emailSendingFailure = new EmailServiceSendingFailure();
                emailSendingFailure.DateFailed = DateTime.Now;
                emailSendingFailure.EmailServiceId = EmailServiceId;
                emailSendingFailure.FailureInfo = ErrorMessage;
                atlasDB.EmailServiceSendingFailures.Add(emailSendingFailure);

                atlasDB.SaveChanges();

                var errorMessageToSend = "EmailId: " + EmailId + " failed to send via EmailServiceId: " + EmailServiceId + "\r\n\r\nError Message:\r\n" + ErrorMessage;

                CreateSystemTrappedErrorDBEntry(systemControl.AtlasSystemType + ", Email Sending", errorMessageToSend);

                // notify all the SystemSupportUsers for the Organisation of the failed email.
                //if (systemControl != null)
                //{
                //    var systemSupportUsers = atlasDB.SystemSupportUsers
                //                                    .Include(ssu => ssu.User)
                //                                    .Where(ssu => ssu.OrganisationId == OrganisationId).ToList();
                //    foreach (var systemSupportUser in systemSupportUsers)
                //    {
                //        if (systemSupportUser.User != null)
                //        {
                //            if (!string.IsNullOrEmpty(systemSupportUser.User.Email))
                //            {
                //                //atlasDB.uspSendEmail(requestedByUserId: systemControl.AtlasSystemUserId, 
                //                //    fromName: systemControl.AtlasSystemFromName, 
                //                //    fromEmailAddresses: systemControl.AtlasSystemFromEmail, 
                //                //    toEmailAddresses: systemSupportUser.User.Email, 
                //                //    ccEmailAddresses: "", 
                //                //    bccEmailAddresses: "", 
                //                //    emailSubject: "Atlas - Error sending email", 
                //                //    emailContent: "EmailId: " + EmailId + " failed to send via EmailServiceId: " + EmailServiceId + "\r\n\r\nError Message:\r\n" + ErrorMessage, 
                //                //    asapFlag: true, 
                //                //    sendAfterDateTime: null, 
                //                //    emailServiceId: null, 
                //                //    organisationId: OrganisationId);                            
                //            }
                //        }
                //    }
                //}
            } catch(Exception ex)
            {
                CreateSystemTrappedErrorDBEntry(systemControl.AtlasSystemType + ", UpdateOnFailedSend"
                                                , "ERROR: " + ex.Message
                                                    + "\r\n ........ StackTrace: " + ex.StackTrace
                                                );
            }
        }

        [HttpGet]
        [Route("api/Email/ArchiveAndDelete")]

        public string ArchiveAndDeleteEmail()
        {
            var message = "";
            var schedulerControl = atlasDB.SchedulerControl.FirstOrDefault();
            if (schedulerControl != null)
            {
                var emailArchiveDisabled = schedulerControl.EmailArchiveDisabled;

                if (!emailArchiveDisabled)
                {
                    try
                    {
                        atlasDB.uspArchiveEmails();
                        atlasDB.uspDeleteOldArchivedEmails();
                    }
                    catch (Exception ex)
                    {
                        message = "ArchiveEmails or DeleteOldArchivedEmails failed to run";
                    }
                }
                else
                {
                    message = "Not run as Archive Email is flagged on DB as disabled or is null";
                }
            }
            else
            {
                message = "No entry on SchedulerControl";
            }
            return message;
        }

        [HttpGet]
        [Route("api/Email/RemoveOldEmailChangeRequests")]

        public bool RemoveOldEmailChangeRequests()
        {
            try
            {
                atlasDB.uspRemoveOldClientEmailChangeRequests();
            }
            catch (Exception ex)
            {
                return false;
            }

            return true;
        }

        [HttpGet]
        [Route("api/Email/SendRefundRequestReminder")]

        public bool RefundRequestReminders()
        {
            var errorMessage = new StringBuilder();
            var itemName = "SendRefundRequestReminder";

            var vwRefundRequestRemindersDues = atlasDBViews.vwRefundRequestRemindersDues.ToList();

            foreach (var refundRequestReminder in vwRefundRequestRemindersDues)
            {
                try
                {
                    atlasDB.uspSendRefundRequestNotificationReminder(refundRequestReminder.RefundRequestId);
                }
                catch (Exception ex)
                {
                    errorMessage.AppendLine(string.Format("Unable to run uspSendRefundRequestNotificationReminder for Refund Request Id {0}. Error {1}", refundRequestReminder.RefundRequestId, ex.Message));
                }
                finally
                {
                    if (errorMessage != null && errorMessage.Length > 0)
                    {
                        CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
                        atlasDB.SaveChanges();
                    }
                }
            }

            return true;
        }
    }
}
