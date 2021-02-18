using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class PublicHolidayJSON
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string CountryCode { get; set; }
        public Nullable<DateTime> Date { get; set; }
    }
}