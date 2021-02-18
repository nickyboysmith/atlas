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
using System.Data.Entity;
using IAM.Atlas.Scheduler.WebService.Classes.SMS;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XSMSController : XBaseController
    {

        [HttpGet]
        [Route("api/SMS/Send")]
        public object Get() {

            var checkSMSEnabled = 
                atlasDB.SchedulerControl.Where(
                    control => control.SMSScheduleDisabled == false
                )
                .Count();

            if (checkSMSEnabled == 1)
            {
                DateTime currentDate = System.DateTime.Now;

                // Get the list of Specified and Non Specfied Emails
                var pendingSMS = new
                {
                    Specified = atlasDBViews.vwSMSMessagesReadyToBeSents
                        .Where(
                            pending =>
                                currentDate >= pending.SendSMSAfter &&
                                !string.IsNullOrEmpty(pending.SMSServiceName)
                        )
                        .ToList(),
                    NotSpecified = atlasDBViews.vwSMSMessagesReadyToBeSents
                        .Where(
                            pendingSMSList =>
                                currentDate >= pendingSMSList.SendSMSAfter &&
                                string.IsNullOrEmpty(pendingSMSList.SMSServiceName)
                        )
                        .ToList()
                };


                // Send the Specified Emails
                foreach (var sms in pendingSMS.Specified)
                {
                    ProcessSMSSend((int)sms.SMSServiceId, sms);
                }

                // Deal with the Non Specified Emails
                var smsServiceProviders = GetSMSServiceProviders();
                var smsProviderIndex = 0;

                foreach (var sms in pendingSMS.NotSpecified)
                {
                    var smsEmailServiceId = smsServiceProviders[smsProviderIndex].Id;

                    // Process the email send
                    ProcessSMSSend(smsEmailServiceId, sms);

                    smsProviderIndex++;
                    if (smsProviderIndex == smsServiceProviders.Count)
                    {
                        smsProviderIndex = 0;
                    }
                }

                return "Done";
            } else {
                return "Not enabled";
            }

        }

        // Change to private completed Testing
        [Route("api/sms/create/{Amount}/{OrganisationId}")]
        [HttpGet]
        public bool CreateSMSMessages(int Amount, int OrganisationId)
        {
            CreateNotSpecifiedSMS(Amount, OrganisationId);
            return true;
        }

        private void CreateNotSpecifiedSMS(int amount, int organisationId)
        {

            for (int i = 1; i <= amount; i++)
            {


                ScheduledSM scheduledSMS = new ScheduledSM();

                scheduledSMS.Content = "Test data to send in SMS";
                scheduledSMS.DateCreated = DateTime.Now;
                //scheduledSMS.ScheduledSMSStatusId = 1;
                scheduledSMS.ScheduledSMSStateId = atlasDB.ScheduledSMSStates.FirstOrDefault(x => x.Name == "Pending").Id;
                scheduledSMS.Disabled = false;
                scheduledSMS.ASAP = true;
                scheduledSMS.SendAfterDate = DateTime.Now;
                scheduledSMS.OrganisationId = organisationId;

                ScheduledSMSTo scheduledSMSTo = new ScheduledSMSTo();

                scheduledSMSTo.ScheduledSM = scheduledSMS;
                scheduledSMSTo.PhoneNumber = "07981231456";
                scheduledSMSTo.IdentifyingId = 283829;
                scheduledSMSTo.IdentifyingName = "Client";
                scheduledSMSTo.IdType = "ClientId";



                atlasDB.ScheduledSMSToes.Add(scheduledSMSTo);


            }

            atlasDB.SaveChanges();
        }

        private void ProcessSMSSend(int SMSServiceId, vwSMSMessagesReadyToBeSent SMS)
        {

            var smsServiceDisabled = IsSMSServiceDisabled(SMSServiceId);
            var smsServiceCredentials = new Object();
            var smsResponse = new Object();
            var getSMSServiceDetail = atlasDB.SMSServices.Find(SMSServiceId);


            // If the email service is disabled
            if (smsServiceDisabled == true)
            {
                LogDisabledSMSServiceProvider(SMS, getSMSServiceDetail.Name);
            }

            // If the email service is not disabled
            if (smsServiceDisabled == false)
            {

                // get the credentials
                smsServiceCredentials = GetSMSServiceCredentials(SMSServiceId);

                // Send the response
                var SMSResponse = ProcessSMSSend(getSMSServiceDetail.Name, SMS, smsServiceCredentials);

                // Process the email Failure or success
                HandleSMSSentResponse(SMSResponse, SMS.SMSId, SMSServiceId);
            }

        }

        // 
        private object ProcessSMSSend(string ProviderName, vwSMSMessagesReadyToBeSent SMS, object SMSCredentials)
        {
            var SMSDisplayName = SMS.SMSDisplayName;
            dynamic credentialsWithDisplayName = SMSCredentials;
            credentialsWithDisplayName.SMSDisplayName = SMSDisplayName;
            var processSMS = new ProcessSMS();
            return processSMS.Start(ProviderName, SMS.PhoneNumber, credentialsWithDisplayName, "SendMessage", SMS.Content);
        }

        // Check to see if the email service is disabled Returns a boolen
        private bool IsSMSServiceDisabled (int SMSServiceId)
        {
            var theSMSServiceCredentials = atlasDB.SMSServices
                .Where(
                    service =>
                        service.Id == SMSServiceId
                )
                .FirstOrDefault();

            if (theSMSServiceCredentials == null)
            {
                return true;
            }

            return Convert.ToBoolean(theSMSServiceCredentials.Disabled);
        }

        // Creates a new dynamic object with the SMS service credentials 
        private object GetSMSServiceCredentials(int SMSServiceId)
        {

            var theSMSServiceCredentials = 
                atlasDB.SMSServiceCredentials
                .Where(
                    credentials =>
                        credentials.SMSServiceId == SMSServiceId
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
            dynamic smsKeys = new ExpandoObject();
            var smsObject = smsKeys as IDictionary<String, object>;

            // Loop through the keys
            foreach (var theKey in theSMSServiceCredentials)
            {
                smsObject[theKey.Key] = theKey.Value;
            }

            return smsKeys;

        }

        private List<SMSService> GetSMSServiceProviders()
        {
            return atlasDB.SMSServices
                .Where(
                    email =>
                        email.Disabled == false
                )
                .ToList();
        }

        // If the Service provider is disabled
        // Create a new entry in the message table
        // Get all email addresses of support users
        // Then send an email to them
        private void LogDisabledSMSServiceProvider(vwSMSMessagesReadyToBeSent SMS, string SMSServiceName)
        {

            var smsDetails = SMS as IDictionary<String, object>;

            var messageSubject = (SMSServiceName) + " is disabled";
            var messageContent = "This SMS service has been flagged as disabled. The user will need to do somehting in order to make this happen";
            var organisationId = SMS.OrganisationId;


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
                            support.User.Name,
                            support.UserId
                        })
                    .ToList();

                // If there are support users in the table 
                // Add to Email Queue 
                if (supportUserEmails.Count > 0)
                {
                    foreach (var emailToSend in supportUserEmails)
                    {

                        atlasDB.uspSendEmail(
                            emailToSend.UserId,
                            "", // @todo: hard coded
                            "", // @todo:  hard coded
                            emailToSend.Email,
                            "",
                            "",
                            messageSubject,
                            messageContent,
                            true,
                            DateTime.Now,
                            3,
                            SMS.OrganisationId,
                            false, 
                            null,
                            null,
                            null
                        );


                    }

                }

                atlasDB.SaveChanges();

            } catch (Exception ex) {
                throw ex;
            }

        }

        private void HandleSMSSentResponse(object SMSResponse, int SmsId, int SMSServiceId)
        {
            var checkResponseType = SMSResponse.GetType();

            // Update by Processed Service
            UpdateSMSProcessedByService(SMSServiceId, SmsId);

            // If a Boolean is returned
            // There are no errors
            // So Update the successful message
            if (checkResponseType.Name == "SMSSuccess")
            {
                UpdateOnSuccessfulSend(SmsId);
            }

            // If a string  is returned
            // Then there is an error
            // Update the failures
            if (checkResponseType.Name == "SMSError")
            {
                var smsFailure = SMSResponse as IDictionary<String, object>;

                var failureMessage = "Message is null";

                if (smsFailure != null) {
                    failureMessage = smsFailure["Message"].ToString();
                }
                  
                //var errorMessage = ConstructFailureMessage(SmsId, smsFailure["Message"].ToString());
                var errorMessage = ConstructFailureMessage(SmsId, failureMessage);
                UpdateOnFailedSend(SmsId, SMSServiceId, errorMessage);
            }
        }


        private void UpdateSMSProcessedByService (int SMSServiceId, int SMSId)
        {
            // Put in a try catch
            var smsDetails = atlasDB.ScheduledSMS.Find(SMSId);
            smsDetails.SMSProcessedSMSServiceId = SMSServiceId;
            var entry = atlasDB.Entry(smsDetails);
            entry.State = System.Data.Entity.EntityState.Modified;
            atlasDB.SaveChanges();
        }

        private void UpdateOnSuccessfulSend(int SMSId)
        {
            // Put in a try catch
            var smsDetails = atlasDB.ScheduledSMS.Find(SMSId);
            //smsDetails.ScheduledSMSStatusId = 2; // 2 is Sent (As of 09/02/2016)
            smsDetails.ScheduledSMSStateId = atlasDB.ScheduledSMSStates.FirstOrDefault(x => x.Name == "Sent").Id;
            smsDetails.DateScheduledSMSStateUpdated = DateTime.Now;
            var entry = atlasDB.Entry(smsDetails);
            entry.State = System.Data.Entity.EntityState.Modified;
            atlasDB.SaveChanges();
        }

        private void UpdateOnFailedSend(int SMSId, int SMSServiceId, string ErrorMessage)
        {
            // Get ScheduledSMSObject from  SMSId
            var smsDetails = atlasDB.ScheduledSMS.Find(SMSId);
            //smsDetails.ScheduledSMSStatusId = 3; // 3 is Failed - Retrying (As of 16/02/2016)
            smsDetails.ScheduledSMSStateId = atlasDB.ScheduledSMSStates.FirstOrDefault(x => x.Name == "Failed - Retrying").Id;
            smsDetails.DateScheduledSMSStateUpdated = DateTime.Now;
            smsDetails.SendAfterDate = DateTime.Now.AddMinutes(30);
            smsDetails.SendAttempts = (smsDetails.SendAttempts) +1;
            var entry = atlasDB.Entry(smsDetails);
            entry.State = System.Data.Entity.EntityState.Modified;

            // Insert into the email sending failure
            SMSServiceSendingFailure smsSendingFailure = new SMSServiceSendingFailure();
            smsSendingFailure.DateFailed = DateTime.Now;
            smsSendingFailure.SMSServiceId = SMSServiceId;
            smsSendingFailure.FailureInfo = ErrorMessage;
            atlasDB.SMSServiceSendingFailures.Add(smsSendingFailure);
            
            atlasDB.SaveChanges();
        }


        private string ConstructFailureMessage(int SMSId, string ErrorMessage)
        {
            var smsMessage = "SMS Send Failed" + System.Environment.NewLine;
            smsMessage += "Scheduled SMS Id: " + SMSId + System.Environment.NewLine;
            smsMessage += "Error Message: " + ErrorMessage + System.Environment.NewLine;
            return smsMessage;
        }

        [HttpGet]
        [Route("api/SMS/ArchiveAndDelete")]
        public string ArchiveAndDeleteEmail()
        {
            var message = "";
            var schedulerControl = atlasDB.SchedulerControl.FirstOrDefault();
            if (schedulerControl != null)
            {
                var smsArchiveDisabled = schedulerControl.SMSArchiveDisabled;

                if (!smsArchiveDisabled)
                {
                    try
                    {
                        atlasDB.uspArchiveSMSs();
                        atlasDB.uspDeleteOldArchivedSMSs();
                    }
                    catch (Exception ex)
                    {
                        message = "ArchiveSMSs or DeleteOldArchivedSMSs failed to run";
                    }
                }
                else
                {
                    message = "Not run as Archive SMS is flagged on DB as disabled or is null";
                }
            }
            else
            {
                message = "no entry on schedulercontrol";
            }
            return message;
        }
    }
}
