//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Net;
//using System.Net.Http;
//using System.Web.Http;
//using IAM.Atlas.WebAPI.Models;

using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class AdministrationController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/administration/{userId}/{organisationId}")]
        [HttpGet]
        public AdminMenuGroup[] Get(int userId, int organisationId)
        {
            return this.GetUserMenuData(userId, organisationId);
        }
    }
}
