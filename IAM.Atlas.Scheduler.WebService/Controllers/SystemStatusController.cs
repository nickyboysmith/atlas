using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Dynamic;
using RestSharp;
using IAM.Atlas.Data;
using System.Data.Entity.Validation;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XSystemStatusController : XBaseController
    {
        [HttpGet]
        [Route("api/SystemStatus/SystemAccessMonitor")]
        public object Get()
        {
            try
            {
                atlasDB.uspSystemAccessMonitor();

                return "Completed: " + DateTime.Now.ToString();
            }
            catch (Exception ex)
            {
                return "Failed: " + DateTime.Now.ToString();
            }
        }
    }
}
