using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Dynamic;
using System.Text;
using RestSharp;
using IAM.Atlas.Data;
using System.Data.Entity.Validation;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XAnnualJobsController : XBaseController
    {
        [HttpGet]
        [Route("api/AnnualJobs/AnnualStoredProcedures")]

        public bool AnnualStoredProcedures()
        {
            var errorMessage = new StringBuilder();
            var itemName = "AnnualStoredProcedures";

            try
            {
                atlasDB.uspRunSystemStoredProceduresPeriodically();
            }
            catch (Exception ex)
            {
                var errror = ex;
                var message = ex.Message;
                if (errror.InnerException != null)
                {
                    if(errror.InnerException.Message != null)
                    {
                        message = message + " ... Inner Exception: " + errror.InnerException.Message;
                    }
                }
                errorMessage.AppendLine(string.Format("Unable to run uspRunSystemStoredProceduresPeriodically. Error {0}", message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
                    atlasDB.SaveChanges();
                }
            }

            return true;
        }
    }
}