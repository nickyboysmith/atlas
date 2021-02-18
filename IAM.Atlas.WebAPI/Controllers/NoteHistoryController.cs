using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;


namespace IAM.Atlas.WebAPI.Controllers
{

    [AllowCrossDomainAccess]
    public class NoteHistoryController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/notehistory/getClientHistory/{clientId}/{organisationId}")]
        [HttpGet]
        public object GetClientHistory(int clientId, int organisationId)
        {
            var notes = atlasDBViews.vwClientHistories.AsNoTracking()
                    .Where(c => c.ClientId == clientId && c.OrganisationId == organisationId)
                    .ToList();
       
            return notes;
        }

        [AuthorizationRequired]
        [Route("api/notehistory/getClientHistoryEventTypes/{clientId}/{organisationId}/")]
        [HttpGet]
        public object GetClientHistoryEventTypes(int clientId, int organisationId)
        {
            var eventTypes = atlasDBViews.vwClientHistoryEventTypes
                .Where(x => x.ClientId == clientId && x.OrganisationId == organisationId)
                .Select( eventHistory => new
                {
                    EventType = eventHistory.EventType
                })
                .ToList();

            return eventTypes;
        }

        [AuthorizationRequired]
        [Route("api/notehistory/getCourseHistory/{courseId}")]
        [HttpGet]
        public object GetCourseHistory(int courseId)
        {
            var notes = atlasDBViews.vwCourseHistories.AsNoTracking()
                    .Where(c => c.CourseId == courseId)
                    .ToList();

            return notes;
        }

        [AuthorizationRequired]
        [Route("api/notehistory/getCourseHistoryEventTypes/{CourseId}")]
        [HttpGet]
        public object GetCourseHistoryEventTypes(int CourseId)
        {
            var eventTypes = atlasDBViews.vwCourseHistoryEventTypes
                .Where(x => x.CourseId == CourseId)
                .Select(eventHistory => new
                {
                    EventType = eventHistory.EventType
                })
                .ToList();

            return eventTypes;
        }

    }

}
