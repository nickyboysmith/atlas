using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Data.Entity;
using System.Text;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XCourseRemindersController : XBaseController
    {
        

        [HttpGet]
        [Route("api/CourseReminders/SendSMSCourseReminders")]

        public bool SendSMSCourseReminders()
        {
            try
            {

                atlasDB.uspCreateSMSCourseReminders();
                return true;

            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [HttpGet]
        [Route("api/CourseReminders/SendEmailCourseReminders")]

        public bool SendEmailCourseReminders()
        {
            try
            {

                atlasDB.uspCreateEmailCourseReminders();
                return true;

            }
            catch (Exception ex)
            {
                return false;
            }
        }


    }
}
