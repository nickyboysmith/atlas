using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class CourseReferenceGeneratorController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/coursereferencegenerator")]
        [HttpGet]
        public object Get()
        {
            return atlasDB.CourseReferenceGenerators
                .Select(courseRef => new {
                    courseRef.Id,
                    courseRef.Title
                })
                .ToList();
        }


        
   
        
    }
}