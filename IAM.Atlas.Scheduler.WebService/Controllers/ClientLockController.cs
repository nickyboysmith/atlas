using IAM.Atlas.Data;
using System;
using System.Linq;
using System.Text;
using System.Web.Http;


namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XClientLockController : XBaseController
    {
        [HttpGet]
        [Route("api/ClientLock/CheckForLockedClientRecords")]
        public bool CheckforLockedClientRecords()
        {
            var errorMessage = new StringBuilder();
            var itemName = "CheckForLockedClientRecords";

            try
            {
                atlasDB.uspUnlockClientsWhereLockExceedsSetting();
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(string.Format("Unable to run uspUnlockClientsWhereLockExceedsSetting. Error {0}", ex.Message));
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

            /* 
             *  Requested to change this process to just call a stored procedure. 
             *  Keeping old code below.
             * 
            var errorMessage = new StringBuilder();
            var itemName = "CheckForLockedClientRecords";

            try
            {
                //Every time the Check for Locked Client Records is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                //Get as List of clients whose lock need to be removed
                var clientsToUnlock = atlasDBViews.vwClientsToBeUnlockeds.ToList();


                if (lastRunLogUpdated == true && clientsToUnlock != null)
                {
                    foreach (var clientToUnlock in clientsToUnlock)
                    {
                        try
                        {
                            errorMessage = new StringBuilder();

                            var updateClient = new Client();
                            updateClient.Id = clientToUnlock.Id;
                            updateClient.Locked = false;
                            updateClient.LockedByUserId = null;
                            updateClient.DateTimeLocked = null;

                            atlasDB.Clients.Attach(updateClient);
                            atlasDB.Entry(updateClient).Property("Locked").IsModified = true;
                            atlasDB.Entry(updateClient).Property("LockedByUserId").IsModified = true;
                            atlasDB.Entry(updateClient).Property("DateTimeLocked").IsModified = true;
                        }
                        catch (Exception ex)
                        {
                            errorMessage.AppendLine(String.Format("An error occurred in Check for Locked Client Records: {0}", ex.Message));
                        }
                        finally
                        {
                            if (errorMessage != null && errorMessage.Length > 0)
                            {
                                CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
                            }
                            atlasDB.SaveChanges();
                            errorMessage = new StringBuilder();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(String.Format("An error occurred in Check for Locked Client Records: {0}", ex.Message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());

                }
                atlasDB.SaveChanges();
            }
            */

    }

}