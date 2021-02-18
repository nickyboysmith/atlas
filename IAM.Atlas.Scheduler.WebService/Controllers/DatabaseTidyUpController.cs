using IAM.Atlas.Data;
using System;
using System.Linq;
using System.Text;
using System.Web.Http;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XDatabaseTidyUpController : XBaseController
    {
        [HttpGet]
        [Route("api/DatabaseTidyUp/DatabaseTidyUpProcess")]

        public bool DatabaseTidyUp()
        {
            var errorMessage = new StringBuilder();
            var itemName = "uspDatabaseTidyUpProcess";

            try
            {
                atlasDB.uspDatabaseTidyUpProcess();
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(string.Format("Unable to run uspDatabaseTidyUpProcess. Error {0}", ex.Message));
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