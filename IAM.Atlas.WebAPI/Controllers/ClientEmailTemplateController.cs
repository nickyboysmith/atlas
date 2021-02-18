using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Web.Http;
using System.Xml.Linq;
using System.Data.Entity;
using System.Web.Script.Serialization;

using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class ClientEmailTemplateController : AtlasBaseController
    {
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/ClientEmailTemplate/GetClientEmailTemplates/{organisationId}")]
        public object GetClientEmailTemplates(int OrganisationId)
        {
            var clientEmailTemplates = atlasDB.ClientEmailTemplates.Where(cet => cet.OrganisationId == OrganisationId).ToList();

            if (clientEmailTemplates != null && clientEmailTemplates.Count > 0)
            {
                if (clientEmailTemplates.Where(cet => cet.DefaultSelectedEmailTemplate).Count() > 0)
                {
                    clientEmailTemplates = clientEmailTemplates.OrderByDescending(cet => cet.DefaultSelectedEmailTemplate).ToList();
                }
                else
                {
                    clientEmailTemplates = clientEmailTemplates.OrderBy(cet => cet.Title).ToList();
                }
            }
            return clientEmailTemplates;
        }
    }
}