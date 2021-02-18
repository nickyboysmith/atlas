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
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class EmailAllController : AtlasBaseController
    {


        [AuthorizationRequired]
        [Route("api/EmailAll/RecordEmails")]
        [HttpPost]
        public void RecordEmails([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;
            
            var courseGroupEmailRequest = formBody.ReadAs<CourseGroupEmailRequest>();

            courseGroupEmailRequest.DateRequested = DateTime.Now;
            courseGroupEmailRequest.ReadyToSend = false;

            //atlasDB.CourseGroupEmailRequests.Add(courseGroupEmailRequest);
            //atlasDB.Entry(courseGroupEmailRequest).State = EntityState.Added;

            var AttachmentIds = (from fb in formBody
                                              where fb.Key.Contains("AttachmentIds")
                                              select new { fb.Key, fb.Value });

            if (AttachmentIds != null)
            {
                foreach (var attachmentId in AttachmentIds)
                {
                    CourseGroupEmailRequestAttachment addCourseGroupEmailRequestAttachment = new CourseGroupEmailRequestAttachment();

                    //addCourseGroupEmailRequestAttachment.CourseGroupEmailRequestId = courseGroupEmailRequest.Id;
                    addCourseGroupEmailRequestAttachment.DocumentId = Int32.Parse(attachmentId.Value);
                    courseGroupEmailRequest.CourseGroupEmailRequestAttachments.Add(addCourseGroupEmailRequestAttachment);
                    //atlasDB.CourseGroupEmailRequestAttachments.Add(addCourseGroupEmailRequestAttachment);
                    //atlasDB.Entry(addCourseGroupEmailRequestAttachment).State = EntityState.Added;
                }
            }
            try
            {
                atlasDB.CourseGroupEmailRequests.Add(courseGroupEmailRequest);
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists contact support."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            CourseGroupEmailRequest updateCourseGroupEmailRequest = atlasDB.CourseGroupEmailRequests.Find(courseGroupEmailRequest.Id);

            updateCourseGroupEmailRequest.ReadyToSend = true;
            //courseGroupEmailRequest.ReadyToSend = true;
            atlasDB.Entry(updateCourseGroupEmailRequest).State = EntityState.Modified;
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
        [HttpGet]
        [Route("api/emailAll/ClientsWithoutEmails/{courseId}")]
        public List<vwCourseClientsWithoutEmail> ClientsWithoutEmails(int courseId)
        {
            var clientsWithoutEmails = atlasDBViews.vwCourseClientsWithoutEmails.Where(cwe => cwe.CourseId == courseId).ToList();
            return clientsWithoutEmails;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/emailAll/TrainersWithoutEmails/{courseId}")]
        public List<vwCourseTrainersWithoutEmail> TrainersWithoutEmails(int courseId)
        {
            var trainersWithoutEmails = atlasDBViews.vwCourseTrainersWithoutEmails.Where(twe => twe.CourseId == courseId).ToList();
            return trainersWithoutEmails;
        }
    }
}