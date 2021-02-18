using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Data.Entity;
using System.Text;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XClientOnlineBookingStateController : XBaseController
    {
        [HttpGet]
        [Route("api/ClientOnlineBookingState/SendPaymentConfirmationEmails")]
        public string SendPaymentConfirmationEmails()
        {
            var message = new List<string>();

            try
            {
                // Retrieve all eligible email addresses from DB
                var clientOnlineBookingStates = atlasDB.ClientOnlineBookingStates
                                               .Include(c => c.Client)
                                               .Include(c => c.Client.ClientEmails)
                                               .Include(c => c.Client.ClientEmails.Select(ce => ce.Email))
                                               .Include(c => c.Course)
                                               .Include(c => c.Course.CourseType)
                                               .Include(c => c.Course.CourseDate)
                                               .Include(c => c.Course.Organisation)
                                               .Where(c => c.CourseBooked == true && c.FullPaymentRecieved == true && (c.EmailConfirmationSent == false || c.EmailConfirmationSent == null)).ToList();

                

                //Retrieve system email and name from DB
                var emailSenderDetails = atlasDB.SystemControls.FirstOrDefault();

                //Checks to see if system email/name is not null before proceeding
                if (emailSenderDetails != null)
                {
                    foreach (var clientOnlineBookingState in clientOnlineBookingStates)
                    {
                        //Checks to see if client has an email address before proceeding
                        if (clientOnlineBookingState.Client.ClientEmails.Count > 0)
                        {
                            var courseDate = clientOnlineBookingState.Course.CourseDate.Select(cd => cd.DateStart).FirstOrDefault();
                            var emailSubject = clientOnlineBookingState.Course.CourseType.Title + " has been booked and paid successfully";
                            var stringBuilder = new StringBuilder();

                            stringBuilder.AppendFormat("<p>Hello {0}</p>", clientOnlineBookingState.Client.DisplayName)
                                         .AppendFormat("<p></p>")
                                         .AppendFormat("<p>Your booking for course {0} on ", clientOnlineBookingState.Course.CourseType.Title)
                                         .AppendFormat("{0} at {1} is booked and we can confirm that we have received the payment</p>", String.Format("{0:dd-MMM-yyyy}", courseDate), String.Format("{0:hh:mm tt}", courseDate))
                                         .AppendFormat("<p></p>")
                                         .AppendFormat("<p>Regards</p>")
                                         .AppendFormat("<p>{0} Administrators</p>", clientOnlineBookingState.Course.Organisation.Name);

                            var emailContent = stringBuilder.ToString();


                            // calls the stored procedure to send email
                            atlasDB.uspSendEmail(emailSenderDetails.AtlasSystemUserId,
                                                    emailSenderDetails.AtlasSystemFromName,
                                                    emailSenderDetails.AtlasSystemFromEmail,
                                                    clientOnlineBookingState.Client.ClientEmails.First().Email.Address, //toemailaddress
                                                    null, //ccemailaddress
                                                    null, //bccemailaddress
                                                    emailSubject,
                                                    emailContent,
                                                    null, //asapflag
                                                    DateTime.Now,
                                                    null, //emailserviceid
                                                    clientOnlineBookingState.Course.Organisation.Id,
                                                    false, 
                                                    null,
                                                    null,
                                                    clientOnlineBookingState.ClientId
                                                    );

                            message.Add(clientOnlineBookingState.ClientId + " successful");

                            // Sets EmailConfirmationSent and DateTimeEmailSent
                            clientOnlineBookingState.EmailConfirmationSent = true;
                            clientOnlineBookingState.DateTimeEmailSent = DateTime.Now;
                            var entry = atlasDB.Entry(clientOnlineBookingState);
                            entry.State = EntityState.Modified;
                        }
                        else
                        {
                            message.Add(clientOnlineBookingState.ClientId + " has no email address");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw (ex);
            }
            finally
            {
                atlasDB.SaveChanges();
            }
            return message.ToString();
        }


        [HttpGet]
        [Route("api/ClientOnlineBookingState/RemoveUnpaidBookings")]
        public string RemoveUnpaidBookings()
        {
            var outputMessages = new List<string>();
            var emailSubject = "Unpaid reserved course has been removed (unbooked)";
            var anHourAgo = DateTime.Now.AddHours(-1);

            try
            {
                var clientOnlineBookingStates = atlasDB.ClientOnlineBookingStates
                               .Include(c => c.Client)
                               .Include(c => c.Course)
                               .Include(c => c.Course.CourseClients)
                               .Include(c => c.Course.Organisation)
                               .Include(c => c.Course.Organisation.OrganisationAdminUsers)
                               .Include(c => c.Course.Organisation.OrganisationAdminUsers.Select(u => u.User))
                               .Include(c => c.Course.CourseType)
                               .Include(c => c.Course.CourseDate)
                               .Where(c => c.CourseBooked == true && c.DateTimeCourseBooked < anHourAgo && c.FullPaymentRecieved != true).ToList();

                var emailSenderDetails = atlasDB.SystemControls.FirstOrDefault();

                if (emailSenderDetails != null)
                {
                    foreach (var clientOnlineBookingState in clientOnlineBookingStates)
                    {
                        var organisationAdminUsers = clientOnlineBookingState.Course.Organisation.OrganisationAdminUsers;
                        foreach (var organisationAdminUser in organisationAdminUsers)
                        {
                            var stringBuilder = new StringBuilder();
                            stringBuilder.AppendFormat("Hello {0}, ", organisationAdminUser.User.Name) 
                                        .AppendLine()
                                        .AppendFormat("An online booking was made on {0} by {1} Client Id: {2}", clientOnlineBookingState.DateTimeCourseBooked, clientOnlineBookingState.Client.DisplayName, clientOnlineBookingState.ClientId)
                                        .AppendLine()
                                        .AppendFormat("The payment was not made and this booking has been automatically removed by the system.")
                                        .AppendLine()
                                        .AppendFormat("Regards,")
                                        .AppendLine()
                                        .AppendLine()
                                        .AppendFormat("Atlas");

                            var emailContent = stringBuilder.ToString();

                            atlasDB.uspSendEmail(emailSenderDetails.AtlasSystemUserId,
                                                emailSenderDetails.AtlasSystemFromName,
                                                emailSenderDetails.AtlasSystemFromEmail,
                                                organisationAdminUser.User.Email,
                                                null, //ccemailaddress
                                                null, //bccemailaddress
                                                emailSubject,
                                                emailContent,
                                                null, //asapflag
                                                DateTime.Now,
                                                null, //emailserviceid
                                                clientOnlineBookingState.Course.Organisation.Id,
                                                false, 
                                                null,
                                                null,
                                                null);

                            outputMessages.Add("Admin User Id " + organisationAdminUser.User.Id + " email successful");
                        }
                    }
                }
                else
                {
                    outputMessages.Add("System email details can not be null");
                }

                foreach (var clientOnlineBookingState in clientOnlineBookingStates)
                {
                    var adminMessageRecipients = clientOnlineBookingState.Course.Organisation.OrganisationAdminUsers;
                    if (adminMessageRecipients != null)
                    {
                        foreach (var adminMessageRecipient in adminMessageRecipients)
                        {
                            var message = new Data.Message();
                            message.Title = emailSubject;
                            message.CreatedByUserId = emailSenderDetails.AtlasSystemUserId;
                            message.DateCreated = DateTime.Now;
                            message.MessageCategoryId = 3; //warning category

                            var stringbuilder = new StringBuilder();
                            stringbuilder.AppendFormat("Hello {0}, ", adminMessageRecipient.User.Name)
                                        .AppendLine()
                                        .AppendFormat("An online booking was made on {0} by {1} Client Id: {2}", clientOnlineBookingState.DateTimeCourseBooked, clientOnlineBookingState.Client.DisplayName, clientOnlineBookingState.ClientId)
                                        .AppendLine()
                                        .AppendFormat("The payment was not made and this booking has been automatically removed by the system.")
                                        .AppendLine()
                                        .AppendFormat("Regards,")
                                        .AppendLine()
                                        .AppendLine()
                                        .AppendFormat("Atlas");

                            var messageContent = stringbuilder.ToString();
                            message.Content = messageContent;

                            var mr = new Data.MessageRecipient();
                            mr.UserId = adminMessageRecipient.UserId;
                            message.MessageRecipient.Add(mr);
                            atlasDB.Message.Add(message);
                            outputMessages.Add("Admin User Id: " + adminMessageRecipient.User.Id + " message successful");
                        }

                        var courseClient = clientOnlineBookingState.Course.CourseClients.Where(cc => cc.ClientId == clientOnlineBookingState.ClientId).FirstOrDefault();
                        clientOnlineBookingState.CourseBooked = false;
                        clientOnlineBookingState.DateTimeCourseBooked = null;

                        if (courseClient != null)
                        {
                            atlasDB.Entry(courseClient).State = EntityState.Modified;
                            atlasDB.Entry(courseClient).State = EntityState.Deleted;
                        }
                        else
                        {
                            outputMessages.Add("Course ID " + clientOnlineBookingState.Course.Id + " has no Course Client entry for client id " + clientOnlineBookingState.ClientId);
                        }
                    }
                    else
                    {
                        outputMessages.Add("Organisation " + clientOnlineBookingState.Course.Organisation.Id + " has no message recipients");
                    }
                }
                //remove entry from CourseClient table
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                atlasDB.SaveChanges();
            }

            StringBuilder builder = new StringBuilder();
            foreach (string outputMessage in outputMessages)
            {
                builder.Append(outputMessage).Append(" | ");
            }
            
            return builder.ToString();
        }
    }
}
