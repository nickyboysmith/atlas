using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class CourseInformationJSON
    {
        public int Id;
        public string Reference;
        public string CourseType;
        public DateTime? CourseDate;
        public bool? IsDORSCourse;
        public bool ClientRemoved;
        public decimal AmountPaid;
        public decimal AmountOutstanding;
        public DateTime? PaymentDueDate;
        public object DORSDetails;
    }
}