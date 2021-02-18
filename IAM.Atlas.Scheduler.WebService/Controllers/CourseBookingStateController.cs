using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Data.Entity;
using System.Text;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XCourseBookingStateController : XBaseController
    {
        [HttpGet]
        [Route("api/CourseBookingState/SendCourseOverbookedEmails")]

        public void SendCourseOverbookedEmails()
        {
            atlasDB.uspMonitorCourseBookings();
        }        
    }
}
