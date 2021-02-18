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
    public class SystemAdminController : AtlasBaseController
    {

        
        // GET api/<controller>/5
        public bool Get(int Id)
        {
            return atlasDB.SystemAdminUsers.Any(adminUser => adminUser.UserId == Id);
        }
                
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/organisationadminuser/{userId}/{organisationId}")]
        public bool OrganisationAdminUser(int UserId, int OrganisationId)
        {
            return atlasDB.OrganisationAdminUsers.Any(adminUser => adminUser.UserId == UserId && adminUser.OrganisationId == OrganisationId);
        }
    }
}