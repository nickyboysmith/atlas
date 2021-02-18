using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{

    public class VenueCourseTypeJSON
    {
        public VenueCourseTypeJSON(VenueCourseType venueCourseType)
        {
            id = venueCourseType.Id;
            courseTypeName = venueCourseType.CourseType.Title;
        }
        public int id { get; set; }
        public string courseTypeName { get; set; }       
    }
}