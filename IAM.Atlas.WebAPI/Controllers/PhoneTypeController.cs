using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class PhoneTypeController : AtlasBaseController
    {
        // GET api/<controller>
        [AuthorizationRequired]
        [Route("api/PhoneType")]
        [HttpGet]
        public object Get()
        {
            return atlasDB.PhoneTypes.Select(thephoneType => new { thephoneType.Id, thephoneType.Type }).ToList();
        }

    }
}