using System.Linq;
using System.Web.Http;
using IAM.Atlas.WebAPI.Classes;


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ClientOnlineBookingStateController : AtlasBaseController
    {
        [HttpPost]
        [Route("api/ClientOnlineBookingState/UpdateCourseBookedStatus/{clientId}/{courseId}")]
        public bool UpdateClientOnlineBookingState(int clientId, int courseId)
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("UpdateClientOnlineBookingState", 1, "Started Process. ClientId: " + clientId + " ... CourseId: " + courseId);
            //}
            var clientOnlineBookingState = atlasDB.ClientOnlineBookingStates
                                                .Where(cobs => cobs.ClientId == clientId)
                                                .OrderByDescending(cobs => cobs.Id)
                                                .FirstOrDefault();

            var updatedEntry = false;

            if (clientOnlineBookingState != null && (clientOnlineBookingState.CourseId == null || clientOnlineBookingState.CourseId == courseId))
            {
                clientOnlineBookingState.CourseBooked = true;
                clientOnlineBookingState.CourseId = courseId;
                atlasDB.Entry(clientOnlineBookingState).Property("CourseBooked").IsModified = true;
                atlasDB.Entry(clientOnlineBookingState).Property("CourseId").IsModified = true;
                atlasDB.SaveChanges();
                updatedEntry = true;
            }
            else if (clientOnlineBookingState == null)
            {
                LogError("UpdateClientOnlineBookingState - ClientController in WebAPI", string.Format("Unable to update the ClientOnlineBookingState record for clientId: {0} relating to courseId {1}", clientId, courseId));
            }
            else if (clientOnlineBookingState.CourseId != courseId)
            {
                LogError("UpdateClientOnlineBookingState - ClientController in WebAPI",
                        "Unable to proceed. Provided Course Id does not match Course Id already held on database." +
                        string.Format("Provided Course Id {0} - Course Id on database {1}", courseId, clientOnlineBookingState.CourseId) +
                        string.Format("ClientOnlineBookingStateId {0}", clientOnlineBookingState.Id));
            }

            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("UpdateClientOnlineBookingState", 1, "Completed Process");
            //}
            return updatedEntry;
        }
    }
}

