using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Formatting;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.ModelBinding;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class SMSController : AtlasBaseController
    {
        [HttpPost]
        [AuthorizationRequired]
        [Route("api/sms/client")]
        public int client([FromBody] FormDataCollection formBody)
        {
            var clientSMS = formBody.ReadAs<ClientSMS>();
            var result = atlasDB.uspSendSMS(requestedByUserId: clientSMS.RequestedByUserId, 
                                toPhoneNumber: clientSMS.PhoneNumber, 
                                smsContent: clientSMS.Content, 
                                identifyingName: clientSMS.ClientName, 
                                identifyingId: clientSMS.ClientId, 
                                idType: clientSMS.RecipientType != null ? clientSMS.RecipientType : "Client",
                                asapFlag: null,
                                organisationId: clientSMS.OrganisationId,
                                sendAfterDateTime: null,
                                smsServiceId: null);
            return result;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/sms/GetAllClientsOnCourse/{OrganisationId}/{CourseId}")]
        public object GetAllClientsOnCourse(int OrganisationId, int CourseId)
        {
            var AllClientsOnCourse = atlasDBViews.vwSMSClientsOnCourses
                                                .Where(x => x.OrganisationId == OrganisationId && x.CourseId == CourseId).ToList();


            return AllClientsOnCourse;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/sms/GetAllTrainersOnCourse/{OrganisationId}/{CourseId}")]
        public object GetAllTrainersOnCourse(int OrganisationId, int CourseId)
        {
            var AllTrainersOnCourse = atlasDBViews.vwSMSTrainersOnCourses
                                                .Where(x => x.OrganisationId == OrganisationId && x.CourseId == CourseId).ToList();


            return AllTrainersOnCourse;
        }


        [HttpPost]
        [AuthorizationRequired]
        [Route("api/sms/SendAllClientsOnCourse")]
        public object SendAllClientsOnCourse([FromBody] FormDataCollection formBody)
        {

        var OrganisationId = StringTools.GetInt("OrganisationId", ref formBody);
        var CourseId = StringTools.GetInt("CourseId", ref formBody);
        var Content = StringTools.GetString("Content", ref formBody);
        var RequestedByUserId = StringTools.GetInt("RequestedByUserId", ref formBody);
        var RecipientType = StringTools.GetString("RecipientType", ref formBody);
        var result = 0;

        var clientSMSPhoneNumber = atlasDBViews.vwSMSClientsOnCourses
                                               .Where(x => x.OrganisationId == OrganisationId && x.CourseId == CourseId).ToList();


            if (clientSMSPhoneNumber != null)
            {

                foreach (var clientSMS in clientSMSPhoneNumber)
                {

                    if (!String.IsNullOrEmpty(clientSMS.PhoneNumber))
                    {

                        result = atlasDB.uspSendSMS(requestedByUserId: RequestedByUserId,
                                        toPhoneNumber: clientSMS.PhoneNumber,
                                        smsContent: Content,
                                        identifyingName: clientSMS.ClientName,
                                        identifyingId: clientSMS.ClientId,
                                        idType: RecipientType,
                                        asapFlag: null,
                                        organisationId: OrganisationId,
                                        sendAfterDateTime: null,
                                        smsServiceId: null);

                    }
                }
            }
            return result;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/sms/SendAllTrainersOnCourse")]
        public object SendAllTrainersOnCourse([FromBody] FormDataCollection formBody)
        {

            var OrganisationId = StringTools.GetInt("OrganisationId", ref formBody);
            var CourseId = StringTools.GetInt("CourseId", ref formBody);
            var Content = StringTools.GetString("Content", ref formBody);
            var RequestedByUserId = StringTools.GetInt("RequestedByUserId", ref formBody);
            var RecipientType = StringTools.GetString("RecipientType", ref formBody);
            var result = 0;

            var trainerSMSPhoneNumber = atlasDBViews.vwSMSTrainersOnCourses
                                                   .Where(x => x.OrganisationId == OrganisationId && x.CourseId == CourseId).ToList();


            if (trainerSMSPhoneNumber != null)
            {

                foreach (var trainerSMS in trainerSMSPhoneNumber)
                {

                    if (!String.IsNullOrEmpty(trainerSMS.PhoneNumber))
                    {

                        result = atlasDB.uspSendSMS(requestedByUserId: RequestedByUserId,
                                        toPhoneNumber: trainerSMS.PhoneNumber,
                                        smsContent: Content,
                                        identifyingName: trainerSMS.TrainerName,
                                        identifyingId: trainerSMS.TrainerId,
                                        idType: RecipientType,
                                        asapFlag: null,
                                        organisationId: OrganisationId,
                                        sendAfterDateTime: null,
                                        smsServiceId: null);

                    }
                }
            }
            return result;
        }

        class ClientSMS
        {
            public string RecipientType { get; set;  }
            public int ClientId { get; set; }
            public string ClientName { get; set; }
            public string PhoneNumber { get; set; }
            public string Content { get; set; }
            public int OrganisationId { get; set; }
            public int RequestedByUserId { get; set; }

        }
    }
}
