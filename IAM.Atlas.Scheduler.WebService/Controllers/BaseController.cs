using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;
using System.Data.Entity;
using System.Text;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XBaseController : ApiController
    {

        private Atlas_DevEntities _atlasDB = new Atlas_DevEntities();
        private Atlas_DevEntitiesViews _atlasDBViews = new Atlas_DevEntitiesViews();

        public Atlas_DevEntities atlasDB
        {
            get
            {
                _atlasDB.Configuration.LazyLoadingEnabled = false;
                return _atlasDB;
            }
        }

        public Atlas_DevEntitiesViews atlasDBViews
        {
            get
            {
                _atlasDBViews.Configuration.LazyLoadingEnabled = false;
                return _atlasDBViews;
            }
        }

        internal void CreateSystemTrappedErrorDBEntry(string itemName, string errorMessage)
        {
            var systemTrappedError = new SystemTrappedError();
            systemTrappedError.FeatureName = itemName;
            systemTrappedError.DateRecorded = DateTime.Now;
            if (errorMessage.Length > 8000)
            {
                errorMessage = errorMessage.Substring(0, 8000);
            }
            systemTrappedError.Message = errorMessage;

            var trappedError = atlasDB.Entry(systemTrappedError);
            trappedError.State = EntityState.Added;

            // store the error into the database so functions calling this function don't have to.
            atlasDB.SaveChanges();
        }

        internal bool UpdateLastRunLogDBEntry(StringBuilder errorMessage, string itemName)
        {
            var ret = true;
            try
            {
                var lastRunLog = atlasDB.LastRunLogs.Where(c => c.ItemName == itemName).FirstOrDefault();
                if (lastRunLog != null)
                {
                    lastRunLog.DateLastRun = DateTime.Now;

                    if (!string.IsNullOrEmpty(errorMessage.ToString()))
                    {
                        lastRunLog.DateLastRunError = DateTime.Now;
                        lastRunLog.LastRunError = errorMessage.ToString();
                    }

                    var entry = atlasDB.Entry(lastRunLog);
                    entry.State = EntityState.Modified;
                }
            }
            catch
            {
                errorMessage.AppendLine(String.Format("Error updating the last run log for {0}'", itemName));
                ret = false;
            }

            return ret;
        }

        /// <summary>
        /// Returns a name for the system's environment, e.g. Test, Dev, UAT...
        /// </summary>
        /// <returns>the name for this environment</returns>
        internal string getSystemName()
        {
            var environmentName = "Dev";
            var systemControl = atlasDB.SystemControls.FirstOrDefault();
            if (systemControl != null)
            {
                environmentName = systemControl.AtlasSystemCode;
            }
            return environmentName;
        }
    }
}