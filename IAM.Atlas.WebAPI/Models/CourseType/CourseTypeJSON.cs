using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is used to return a light weight serialized JSON object 
    /// 
    /// </summary>
   
    public class CourseTypeJSON
    {
        public int Id { get; set; }
        public string Code { get; set; }
        public string CourseTypeName { get; set; }  // this is the same as title but is used in the UI @TODO: remove CourseTypeName from UI project
        public string Title { get; set; }
        public string Description { get; set; }
        public bool Disabled { get; set; }
        public bool? DORSOnly { get; set; }
        public int MaxPracticalTrainers { get; set; }
        public int MaxTheoryTrainers { get; set; }
        public int MinPracticalTrainers { get; set; }
        public int MinTheoryTrainers { get; set; }
        public string OrganisationName { get; set; }
        public int OrganisationId { get; set; }
        public int MaxPlaces { get; set; }
    }
}