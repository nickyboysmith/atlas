using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class SystemStateController : AtlasBaseController
    {
        [HttpGet]
        [AllowCrossDomainAccess]
        [Route("api/systemState/getStatuses/{organisationId}")]
        public object GetStatuses(int organisationId)
        {
            return atlasDB.SystemStateSummaries.Where(sss => sss.OrganisationId == organisationId);
        }
    }
}
