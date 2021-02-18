using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class CourseTypeFeeController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/GetCurrentCourseTypeFee/{courseTypeId}")]
        public decimal GetCurrentCourseTypeFee(int courseTypeId)
        {
            var fee = (decimal) 0.0;
            var courseTypeFee = atlasDB.CourseTypeFees
                                        .Where(
                                            ctf => ctf.CourseTypeId == courseTypeId &&
                                            ctf.EffectiveDate < DateTime.Now
                                        )
                                        .OrderByDescending(ctf => ctf.EffectiveDate)
                                        .ThenByDescending(ctf => ctf.DateAdded)
                                        .FirstOrDefault();
            if (courseTypeFee != null && courseTypeFee.CourseFee != null)
            {
                fee = (decimal) courseTypeFee.CourseFee;
            }
            return fee;
        }

    }
}
