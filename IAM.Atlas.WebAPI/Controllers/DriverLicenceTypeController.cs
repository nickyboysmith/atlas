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
    public class DriverLicenceTypeController : AtlasBaseController
    {
        // GET api/<controller>
        [Route("api/DriverLicenceType")]
        [HttpGet]
        public object Get()
        {
            return atlasDB.DriverLicenceType
                .Where(driver => driver.Disabled != true)
                .Select(
                    driverLicenceType => new { driverLicenceType.Id, driverLicenceType.Name }
                ).ToList();
        }

    }
}