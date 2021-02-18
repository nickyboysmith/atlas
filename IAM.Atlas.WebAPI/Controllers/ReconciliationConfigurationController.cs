using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using System.Web.Http.ModelBinding;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class ReconciliationConfigurationController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/ReconciliationConfiguration/GetReconciliationConfigurations/{organisationId}")]
        public object GetReconciliationConfiguration (int organisationId)
        {
            var reconciliationConfigurations = atlasDB.ReconciliationConfigurations
                                                        .Include("User")
                                                        .Where(rc => rc.OrganisationId == organisationId)
                                                        .OrderByDescending(rc => rc.DateCreated)
                                                        .Select(rc => 
                                                                        new
                                                                        {
                                                                            rc.Id,
                                                                            rc.Name,
                                                                            rc.DateCreated,
                                                                            rc.OrganisationId,
                                                                            rc.Reference1ColumnNumber,
                                                                            rc.Reference2ColumnNumber,
                                                                            rc.Reference3ColumnNumber,
                                                                            rc.TransactionAmountColumnNumber,
                                                                            rc.TransactionDateColumnNumber,
                                                                            UserId = rc.User.Id,
                                                                            UserName = rc.User.Name
                                                                        }
                                                            )
                                                        .ToList();

            return reconciliationConfigurations;
        }

        [HttpPost]
        [Route("api/ReconciliationConfiguration/SaveNewReconciliationConfiguration/")]
        public bool SaveNewReconciliationConfiguration([FromBody] FormDataCollection formBody)
        {
            var success = false;

            try
            {
                var reconciliationConfiguration = formBody.ReadAs<ReconciliationConfiguration>();
                reconciliationConfiguration.DateCreated = DateTime.Now;
                atlasDB.ReconciliationConfigurations.Add(reconciliationConfiguration);
                atlasDB.SaveChanges();
                success = true;
            }
            catch (Exception)
            {
                success = false;
                return success;
            }
            return success;
        }
    }
}