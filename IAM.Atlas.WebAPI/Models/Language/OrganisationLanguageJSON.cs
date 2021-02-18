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
   
    public class OrganisationLanguageJSON
    {
        public int Id { get; set; }
        public string Description { get; set; }
    }
    
}