using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Web.Http;
using static IAM.DORS.Webservice.Interface;
using IAM.DORS.Webservice;
using IAM.Atlas.WebAPI.Controllers;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XDORSController : XBaseController
    {
        private bool _useMocks = true;
        bool useMocks
        {
            get
            {
                var useMockDORSData = ConfigurationManager.AppSettings["useMockDORSData"];
                if (!string.IsNullOrEmpty(useMockDORSData))
                {
                    return useMockDORSData.ToLower() == "true" ? true : false;
                }
                else
                {
                    return true;
                }
            }
            set
            {
                _useMocks = value;
            }
        }

        // a local cache of dorsattendancestates
        private List<DORSAttendanceState> dorsAttendanceStatesCache = null;

        [HttpGet]
        [Route("api/DORS/CancelCourse")]
        public bool CancelCourse()
        {
            var errorMessage = new StringBuilder();
            var itemName = "DORSCancelledCourse " + getSystemName();

            try
            {
                //Every time the DORSCancelledCourse is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                var dorsControl = atlasDB.DORSControls.Where(dc => dc.Id == 1).Single();

                if (lastRunLogUpdated == true && dorsControl != null && dorsControl.DORSEnabled == true)
                {
                    // Gets courses marked for deletion where DORS has not been notified
                    var cancelledCourses = atlasDB.Course
                                  .Include(c => c.CancelledCourses)
                                  .Include(c => c.Organisation)
                                  .Include(c => c.Organisation.DORSConnections)
                                  .Include(c => c.DORSCancelledCourses)
                                  .Where(c => c.CancelledCourses.Any(cc => cc.DORSCourse == true) && (c.DORSCancelledCourses.Any(dcc => dcc.DORSNotified == false) || c.DORSCancelledCourses.ToList().Count == 0)).ToList();

                    // This Dictionary is going to be a cache of the DORS Web service connections, the Key is going to be the organisation's Id.
                    var DORSWebServiceConnectionList = new Dictionary<int, DORS.Webservice.Interface>();

                    foreach (var course in cancelledCourses)
                    {
                        DORSConnection dorsConnection = null;
                        try
                        {
                            errorMessage = new StringBuilder();

                            // looks in DORSConnections for the cached connection for the relevant organisation
                            DORS.Webservice.Interface dorsWebServiceConnection = null;
                            if (DORSWebServiceConnectionList.ContainsKey(course.OrganisationId))
                            {
                                dorsWebServiceConnection = DORSWebServiceConnectionList[course.OrganisationId];
                            }
                            // if it's not there then create it and add it to the cache
                            if (dorsWebServiceConnection == null)
                            {
                                dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                                if (dorsConnection != null)
                                {
                                    dorsWebServiceConnection = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                    DORSWebServiceConnectionList.Add(course.OrganisationId, dorsWebServiceConnection);
                                }
                                else
                                {
                                    errorMessage.AppendLine(String.Format("Organisation Id {0} doesn't have a DORSConnection entry.", course.OrganisationId));
                                }
                            }
                            if (dorsWebServiceConnection != null)
                            {

                                if (dorsWebServiceConnection.CancelCourse(course.Id))
                                {
                                    //update record if it exists
                                    if (course.DORSCancelledCourses.Count > 0)
                                    {
                                        course.DORSCancelledCourses.First().DORSNotified = true;
                                        course.DORSCancelledCourses.First().DateDORSNotified = DateTime.Now;
                                        atlasDB.Entry(course).State = EntityState.Modified;
                                        errorMessage.AppendLine(String.Format("{0} Cancelled.", course.Id));
                                    }
                                    else
                                    //add record to DORSCancelledCourses if it doesn't exist
                                    {
                                        var dorsCancelledCourse = new DORSCancelledCourse();
                                        dorsCancelledCourse.CourseId = course.Id;
                                        dorsCancelledCourse.DateDORSNotified = DateTime.Now;
                                        dorsCancelledCourse.DORSNotified = true;
                                        atlasDB.DORSCancelledCourses.Add(dorsCancelledCourse);
                                        errorMessage.AppendLine(String.Format("{0} Cancelled.", course.Id));
                                    }

                                }
                                else
                                {
                                    errorMessage.AppendLine(String.Format("{0} Couldn't be cancelled.", course.Id));
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                            // so we can email administrators (via a trigger)
                            if (DORSConnectionException.isDORSConnectionException(ex))
                            {
                                dorsConnection.DateLastConnectionFailure = DateTime.Now;
                                var dbEntry = atlasDB.Entry(dorsConnection);
                                dbEntry.State = EntityState.Modified;
                            }
                            errorMessage.AppendLine(String.Format("An error occurred in DORSCancellledCourse: {0}", ex.Message));
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
                errorMessage.AppendLine(String.Format("An error occurred in DORSCancellledCourse: {0}", ex.Message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());

                }
                atlasDB.SaveChanges();
            }
            return true;
        }

        [HttpGet]
        [Route("api/DORS/RemoveClientFromCourse")]
        public bool RemoveFromCourse()
        {
            var errorMessage = new StringBuilder();
            var itemName = "DORSRemoveFromCourse " + getSystemName();

            try
            {
                //Every time the DORSRemoveFromCourse is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                var dorsControl = atlasDB.DORSControls.Where(dc => dc.Id == 1).Single();

                if (lastRunLogUpdated == true && dorsControl.DORSEnabled == true)
                {
                    if (dorsControl.MaximumPostsPerSession != null)
                    {
                        var maxPostsPerSession = (int)dorsControl.MaximumPostsPerSession;

                        // Retrieves Clients due to be removed, where DORS hasn't already been notified and where Client Organisation has DORS features enabled
                        var dorsClientCourseRemovals = atlasDB.DORSClientCourseRemovals
                                                             .Include(ccr => ccr.Client)
                                                             .Include(ccr => ccr.Client.DORSClientCourseAttendances)
                                                             .Include(ccr => ccr.Client.ClientOrganisations)
                                                             .Include(ccr => ccr.Client.ClientOrganisations.Select(co => co.Organisation))
                                                             .Include(ccr => ccr.Client.ClientOrganisations.Select(co => co.Organisation).Select(o => o.OrganisationSystemConfigurations))
                                                             .Include(ccr => ccr.Course)
                                                             .Where(ccr => ccr.DORSNotified == false &&
                                                                    ccr.Client.ClientOrganisations.Any(co => co.Organisation.OrganisationSystemConfigurations.Any(osc => osc.DORSFeatureEnabled) == true))
                                                             .OrderBy(ccr => ccr.DateRequested)
                                                             .Take(maxPostsPerSession).ToList();


                        foreach (var dorsClientCourseRemoval in dorsClientCourseRemovals)
                        {
                            DORSConnection dorsConnection = null;
                            if (!dorsClientCourseRemoval.IsMysteryShopper)
                            {
                                try
                                {
                                    errorMessage = new StringBuilder();

                                    var dorsClientCourseAttendance = dorsClientCourseRemoval.Client.DORSClientCourseAttendances.FirstOrDefault();
                                    if (dorsClientCourseAttendance != null && dorsClientCourseAttendance.DORSAttendanceRef != null)
                                    {
                                        var dorsAttendanceRef = dorsClientCourseAttendance.DORSAttendanceRef.Value;
                                        if (dorsClientCourseRemoval.Course != null)
                                        {
                                            dorsConnection = atlasDB.DORSConnections.Where(dc => dc.OrganisationId == dorsClientCourseRemoval.Course.OrganisationId && dc.Enabled == true).FirstOrDefault();
                                            if (dorsConnection != null)
                                            {
                                                var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                                // update the DORS notification attempts
                                                dorsClientCourseRemoval.DateDORSNotificationAttempted = DateTime.Now;
                                                int? numberOfAttempts = dorsClientCourseRemoval.NumberOfDORSNotificationAttempts;
                                                if (numberOfAttempts == null) numberOfAttempts = 0;
                                                dorsClientCourseRemoval.NumberOfDORSNotificationAttempts = numberOfAttempts++;

                                                if (dorsInterface.CancelBooking(dorsAttendanceRef))
                                                {
                                                    dorsClientCourseRemoval.DORSNotified = true;
                                                    dorsClientCourseRemoval.DateTimeDORSNotified = DateTime.Now;
                                                    atlasDB.Entry(dorsClientCourseRemoval).State = EntityState.Modified;
                                                    errorMessage.AppendLine(String.Format("Client Id: {0}  Course Id: {1} Removed", dorsClientCourseRemoval.ClientId, dorsClientCourseRemoval.CourseId + " Removed"));
                                                }
                                                else
                                                {
                                                    errorMessage.AppendLine(String.Format("Negative result returned from DORS for Atlas Course ID: {0}", dorsClientCourseRemoval.CourseId));
                                                }
                                            }
                                            else
                                            {
                                                errorMessage.AppendLine("DORS Connection not found");
                                            }
                                        }
                                        else
                                        {
                                            errorMessage.AppendLine("No Course could be found for DorsClientCourseRemoval id: " + dorsClientCourseRemoval.Id);
                                        }
                                    }
                                    else
                                    {
                                        errorMessage.AppendLine(String.Format("Can not proceed without DORS attendance reference. Atlas Client ID: {0}", dorsClientCourseRemoval.ClientId));
                                    }

                                }
                                catch (Exception ex)
                                {
                                    // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                                    // so we can email administrators (via a trigger)
                                    if (DORSConnectionException.isDORSConnectionException(ex))
                                    {
                                        dorsConnection.DateLastConnectionFailure = DateTime.Now;
                                        var dbEntry = atlasDB.Entry(dorsConnection);
                                        dbEntry.State = EntityState.Modified;
                                    }
                                    errorMessage.AppendLine(String.Format("An error occurred in DORSRemoveFromCourse: {0}", ex.Message));
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
                    else
                    {
                        errorMessage.AppendLine("Maximum posts to DORS not listed in database, can not proceed");
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(String.Format("An error occurred in DORSRemoveFromCourse: {0}", ex.Message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());

                }
                atlasDB.SaveChanges();
            }
            return true;
        }

        [HttpGet]
        [Route("api/DORS/ClientTransferredCourse")]
        public bool ClientTransferredCourse()
        {
            var errorMessage = new StringBuilder();
            var itemName = "DORSClientTransferredFromCourse " + getSystemName();

            try
            {
                //Every time the DORSClientTransferredFromCourse is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                var dorsControl = atlasDB.DORSControls.Where(dc => dc.Id == 1).Single();

                if (lastRunLogUpdated == true && dorsControl != null && dorsControl.DORSEnabled == true)
                {
                    // Retrieves the max amount of posts to DORS
                    if (dorsControl.MaximumPostsPerSession != null)
                    {
                        //returns maximum amount of posts to DORS allowed
                        var maxPostsPerSession = (int)dorsControl.MaximumPostsPerSession;

                        // Retrieves Clients due to be transferred, where DORS hasn't already been notified and where Client Organisation as DORS features enabled.
                        var dorsClientCourseTransferred = atlasDB.DORSClientCourseTransferreds
                                                         .Include(cct => cct.Course) //TransferFrom
                                                         .Include(cct => cct.Course.CourseClients)
                                                         .Include(cct => cct.Course.CourseClientPayments)
                                                         .Include(cct => cct.Course.CourseClientPayments.Select(ccp => ccp.Payment))
                                                         .Include(cct => cct.Course1) //TransferTo
                                                         .Include(cct => cct.Course1.CourseClients)
                                                         .Include(cct => cct.Course1.CourseClientPayments)
                                                         .Include(cct => cct.Course1.CourseClientPayments.Select(ccp => ccp.Payment))
                                                         .Include(cct => cct.Course.DORSCourses) //TransferFrom DORS Course
                                                         .Include(cct => cct.Course1.DORSCourses) //TransferTo DORS Course
                                                         .Include(cct => cct.Course.DORSClientCourseAttendances)
                                                         .Include(cct => cct.Course1.DORSClientCourseAttendances)
                                                         .Include(cct => cct.Client)
                                                         .Include(cct => cct.Client.ClientOrganisations)
                                                         .Include(cct => cct.Client.ClientOrganisations.Select(co => co.Organisation))
                                                         .Include(cct => cct.Client.ClientOrganisations.Select(co => co.Organisation).Select(o => o.OrganisationSystemConfigurations))
                                                         .Where(cct => cct.DORSNotified == false &&
                                                                cct.Client.ClientOrganisations.Any(co => co.Organisation.OrganisationSystemConfigurations.Any(osc => osc.DORSFeatureEnabled) == true))
                                                         .OrderBy(cct => cct.DateRequested)
                                                         .Take(maxPostsPerSession).ToList();

                        //Loops through and notifies DORS of transfer
                        foreach (var dorsClientCourseTransfer in dorsClientCourseTransferred)
                        {
                            DORSConnection dorsConnection = null;
                            try
                            {
                                errorMessage = new StringBuilder();

                                //Retrieves DORS attendance info, along with 'from' and 'to' course info.
                                var dorsClientCourseAttendance = dorsClientCourseTransfer.Client.DORSClientCourseAttendances.Where(dcca => dcca.CourseId == dorsClientCourseTransfer.TransferToCourseId).FirstOrDefault();
                                var fromCourse = dorsClientCourseTransfer.Course;
                                var toCourse = dorsClientCourseTransfer.Course1;
                                //DORS allows null notes
                                var comments = "";

                                if (dorsClientCourseTransfer.Notes != null)
                                {
                                    comments = dorsClientCourseTransfer.Notes;
                                }

                                if (dorsClientCourseAttendance != null && dorsClientCourseAttendance.DORSAttendanceRef != null)
                                {
                                    // Get the DORS attendance ref and info for DORS connection
                                    var dorsAttendanceRef = dorsClientCourseAttendance.DORSAttendanceRef.Value;
                                    if (dorsClientCourseTransfer.Course != null)
                                    {
                                        dorsConnection = atlasDB.DORSConnections.Where(dc => dc.OrganisationId == dorsClientCourseTransfer.Course.OrganisationId && dc.Enabled == true).FirstOrDefault(); //TODO: Amend org id, variable

                                        //Ensures DB has connection info for DORS before proceeding
                                        if (dorsConnection != null)
                                        {
                                            var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);

                                            //Checks to see if all required information to DORS is available - before passing it over
                                            if (fromCourse.DORSCourses.Count > 0 && toCourse.DORSCourses.Count > 0 && toCourse.DORSCourses.First().DORSCourseIdentifier != null && toCourse.DORSClientCourseAttendances.Count > 0)
                                            {
                                                if (dorsClientCourseAttendance.DORSAttendanceStateIdentifier != null)
                                                {
                                                    var dorsCourseId = (int)toCourse.DORSCourses.First().DORSCourseIdentifier;
                                                    var bookedDate = toCourse.CourseClients.Where(cc => cc.ClientId == dorsClientCourseTransfer.ClientId).First().DateAdded;  // can be null for DORS, but not a nullable value in DB. --TODO: Where clientid matches
                                                    var paidDate = toCourse.CourseClientPayments.Where(ccp => ccp.ClientId == dorsClientCourseTransfer.ClientId).Last().Payment.TransactionDate; //can be null for DORS, but not a nullable value in DB --TODO: Where clientid matches

                                                    var attendanceStatusId = (int)dorsClientCourseAttendance.DORSAttendanceStateIdentifier;
                                                    if (dorsInterface.UpdateBooking(dorsAttendanceRef, dorsCourseId, bookedDate, paidDate, comments, attendanceStatusId))
                                                    {
                                                        dorsClientCourseTransfer.DORSNotified = true;
                                                        dorsClientCourseTransfer.DateTimeDORSNotified = DateTime.Now;
                                                        atlasDB.Entry(dorsClientCourseTransfer).State = EntityState.Modified;
                                                        errorMessage.AppendLine(String.Format("Client Id: {0} has transferred from course Id: {1} to course Id: {2}", dorsClientCourseTransfer.ClientId, dorsClientCourseTransfer.Course.Id, dorsClientCourseTransfer.Course1.Id));
                                                    }
                                                    else
                                                    {
                                                        errorMessage.AppendLine(String.Format("Negative result returned from DORS for transferring from Atlas Course ID: {0} to {1}", dorsClientCourseTransfer.Course.Id, dorsClientCourseTransfer.Course1.Id));
                                                    }
                                                }
                                                else
                                                {
                                                    errorMessage.AppendLine(String.Format("Course id: {0} DORS Attendance State can not be null.", dorsClientCourseTransfer.Course.Id));
                                                }
                                            }
                                            else
                                            {
                                                errorMessage.AppendLine(String.Format("To Course id: {0} DORS Course Id not found", toCourse.Id));
                                            }
                                        }
                                        else
                                        {
                                            errorMessage.AppendLine("DORS Connection not found");
                                        }
                                    }
                                    else
                                    {
                                        errorMessage.AppendLine("Course could not be foung for dorsClientCourseTransfer id: " + dorsClientCourseTransfer.Id);
                                    }
                                }
                                else
                                {
                                    errorMessage.AppendLine(String.Format("Can not proceed without DORS attendance reference. Atlas Client ID: {0}", dorsClientCourseTransfer.ClientId));
                                }
                            }
                            catch (Exception ex)
                            {
                                // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                                // so we can email administrators (via a trigger)
                                if (DORSConnectionException.isDORSConnectionException(ex))
                                {
                                    dorsConnection.DateLastConnectionFailure = DateTime.Now;
                                    var dbEntry = atlasDB.Entry(dorsConnection);
                                    dbEntry.State = EntityState.Modified;
                                }
                                errorMessage.AppendLine(String.Format("An error occurred in DORSClientTransferredFromCourse: {0}", ex.Message));
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
                    else
                    {
                        errorMessage.AppendFormat("Maximum posts to DORS not listed in database, can not proceed");
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(String.Format("An error occurred in DORSClientTransferredFromCourse: {0}", ex.Message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());

                }
                atlasDB.SaveChanges();
            }
            return true;
        }

        [HttpGet]
        [Route("api/DORS/LogOffersWithdrawn")]
        public bool LogOffersWithdrawn()
        {
            var errorMessage = new StringBuilder();
            var itemName = "DORSOfferWithdrawnCheck " + getSystemName();

            try
            {
                //Every time the Log Offers Withdrawn is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                var dorsControl = atlasDB.DORSControls.Single();

                if (lastRunLogUpdated == true && dorsControl != null && dorsControl.DORSEnabled == true)
                {
                    // Get DefaultDORSConnectionId

                    var dorsConnections = atlasDB.DORSConnections.Where(dc => dc.Enabled == true).ToList();

                    foreach (var dorsConnection in dorsConnections)
                    {
                        try
                        {
                            errorMessage = new StringBuilder();

                            var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);

                            var dorsOffersWithdrawn = dorsInterface.GetOfferWithdrawn(DateTime.Now);

                            foreach (var dorsOfferWithdrawn in dorsOffersWithdrawn)
                            {
                                if (!atlasDB.DORSOffersWithdrawnLogs.Any(owl => owl.DORSAttendanceRef == dorsOfferWithdrawn.AttendanceID
                                        && owl.LicenceNumber == dorsOfferWithdrawn.DrivingLicenseNumber
                                        && owl.DORSSchemeIdentifier == dorsOfferWithdrawn.SchemeID))
                                {

                                    var offerWithdrawnLog = new DORSOffersWithdrawnLog();

                                    offerWithdrawnLog.DORSAttendanceRef = dorsOfferWithdrawn.AttendanceID;
                                    offerWithdrawnLog.LicenceNumber = dorsOfferWithdrawn.DrivingLicenseNumber;
                                    offerWithdrawnLog.DORSSchemeIdentifier = dorsOfferWithdrawn.SchemeID;
                                    offerWithdrawnLog.OldAttendanceStatusId = dorsOfferWithdrawn.AttendanceStatusID_Old;

                                    offerWithdrawnLog.AdministrationNotified = false;

                                    offerWithdrawnLog.DORSConnectionId = dorsConnection.Id;
                                    offerWithdrawnLog.DateCreated = DateTime.Now;

                                    atlasDB.DORSOffersWithdrawnLogs.Add(offerWithdrawnLog);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                            // so we can email administrators (via a trigger)
                            if (DORSConnectionException.isDORSConnectionException(ex))
                            {
                                dorsConnection.DateLastConnectionFailure = DateTime.Now;
                                var dbEntry = atlasDB.Entry(dorsConnection);
                                dbEntry.State = EntityState.Modified;
                            }
                            errorMessage.AppendLine(String.Format("An error occurred in LogOffersWithdrawn: {0}", ex.Message));
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
                errorMessage.AppendLine(String.Format("An error occurred in LogOffersWithdrawn: {0}", ex.Message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());

                }
                atlasDB.SaveChanges();
            }
            return true;
        }

        [HttpGet]
        [Route("api/DORS/NewCourses")]
        /// <summary>
        /// Find all the newly created DORS courses and notify dors.
        /// </summary>
        /// <returns></returns>
        public bool NewCourses()
        {
            var errorMessage = new StringBuilder();
            var itemName = "DORSNewCourses " + getSystemName();

            try
            {
                //Every time the DORSNewCourses is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                var dorsControl = atlasDB.DORSControls.Where(dc => dc.Id == 1).Single();

                if (lastRunLogUpdated == true && dorsControl != null && dorsControl.DORSEnabled == true)
                {
                    var dorsConnections = atlasDB.DORSConnections
                        .Where(dc => dc.Enabled == true)
                        .ToList();
                    var newCourses = atlasDBViews.vwNewCoursesAwaitingDORSNotifications.ToList();

                    // store the different organisation's DORS interfaces in this dictionary indexed by organisation.Id
                    var dorsInterfaces = new Dictionary<int, IAM.DORS.Webservice.Interface>();
                    foreach (var newCourse in newCourses)
                    {
                        DORSConnection dorsConnection = null;
                        try
                        {
                            errorMessage = new StringBuilder();

                            DORS.Webservice.Interface dorsInterface = null;
                            if (dorsInterfaces.ContainsKey(newCourse.OrganisationId))
                            {
                                dorsInterface = dorsInterfaces[newCourse.OrganisationId];
                            }

                            // if it's not there then create it and add it to the cache
                            if (dorsInterface == null)
                            {
                                dorsConnection = dorsConnections.Where(dc => dc.OrganisationId == newCourse.OrganisationId).FirstOrDefault();

                                if (dorsConnection != null)
                                {
                                    dorsInterface = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                    dorsInterfaces.Add(newCourse.OrganisationId, dorsInterface);
                                }
                                else
                                {
                                    errorMessage.AppendLine(String.Format("Organisation Id {0} doesn't have a DORSConnection.", newCourse.OrganisationId));
                                }
                            }

                            if (dorsInterface != null)
                            {
                                if (newCourse.CourseStartDate != null)
                                {
                                    if (newCourse.SiteId != null)
                                    {
                                        var courseStartDate = (DateTime)newCourse.CourseStartDate;
                                        var siteId = (int)newCourse.SiteId;
                                        var courseDORSIdentifier = dorsInterface.AddCourse(newCourse.CourseReference, courseStartDate, newCourse.MaximumPlaces, siteId, (int)newCourse.ForceContractId);
                                        var course = atlasDB.Course.Where(c => c.Id == newCourse.CourseId).FirstOrDefault();
                                        if (course != null)
                                        {
                                            course.DORSNotified = true;
                                            course.DateDORSNotified = DateTime.Now;

                                            var dorsCourse = new DORSCourse();
                                            dorsCourse.CourseId = course.Id;
                                            dorsCourse.DORSCourseIdentifier = courseDORSIdentifier;

                                            atlasDB.DORSCourses.Add(dorsCourse);
                                            var courseEntry = atlasDB.Entry(course);
                                            courseEntry.State = EntityState.Modified;

                                            atlasDB.SaveChanges();
                                        }
                                        else
                                        {
                                            errorMessage.AppendLine(String.Format("Course Id: {0}, couldn't find course in database.", newCourse.CourseId));
                                        }
                                    }
                                    else
                                    {
                                        errorMessage.AppendLine(String.Format("Course Id: {0}, doesn't have a venue with a DORS Site Id", newCourse.CourseId));
                                    }
                                }
                                else
                                {
                                    errorMessage.AppendLine(String.Format("Course Id: {0}, has a startdate of null.", newCourse.CourseId));
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                            // so we can email administrators (via a trigger)
                            if (DORSConnectionException.isDORSConnectionException(ex))
                            {
                                dorsConnection.DateLastConnectionFailure = DateTime.Now;
                                var dbEntry = atlasDB.Entry(dorsConnection);
                                dbEntry.State = EntityState.Modified;
                            }
                            var courseErrorMessage = String.Format("Course Id: {0}, an error occurred: {1}", newCourse.CourseId, ex.Message);
                            errorMessage.AppendLine(courseErrorMessage);
                            UpdateLastRunLogDBEntry(new StringBuilder(courseErrorMessage), itemName);
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
                errorMessage.AppendLine(String.Format("An error occurred in DORSNewCourses: {0}", ex.Message));
                UpdateLastRunLogDBEntry(new StringBuilder(String.Format("An error occurred in DORSNewCourses: {0}", ex.Message)), itemName);
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
                }
                atlasDB.SaveChanges();
            }

            return true;
        }

        [HttpGet]
        [Route("api/DORS/NotifyNewCourseClients")]
        /// <summary>
        /// Find all clients on courses with changes that we need to notify DORS about then set DORSNotified to true after.
        /// 
        /// Used to move clients from "booking pending" to "booked" to "booked and paid" and course transfers.
        /// 
        /// </summary>
        /// <returns></returns>
        public bool NotifyNewCourseClients()
        {
            var errorMessage = new StringBuilder();
            var itemName = "DORSNotifyNewCourseClients " + getSystemName();
            CourseAttendanceController attendanceController = null;

            try
            {
                //Every time the DORSNotifyNewCourseClients is run, or a run is attempted Update the Table "LastRunLog"
                var lastRunLogUpdated = UpdateLastRunLogDBEntry(errorMessage, itemName);

                //retrieve course clients to send to DORS
                var dorsControl = atlasDB.DORSControls.Where(dc => dc.Id == 1).Single();

                if (lastRunLogUpdated == true && dorsControl != null && dorsControl.DORSEnabled == true)
                {
                    var dorsConnections = atlasDB.DORSConnections
                        .Where(dc => dc.Enabled == true)
                        .ToList();

                    var listOfDORSAttendanceStateIdentifiers = new List<int>();
                    listOfDORSAttendanceStateIdentifiers.Add((int)DORSAttendanceStates.BookingPending);
                    listOfDORSAttendanceStateIdentifiers.Add((int)DORSAttendanceStates.Booked);
                    listOfDORSAttendanceStateIdentifiers.Add((int)DORSAttendanceStates.BookedAndPaid);

                    var courseClients = atlasDB.CourseDORSClients
                        .Include(c => c.Course)
                        .Include(c => c.Course.DORSCourses)
                        .Include(c => c.Client)
                        .Include(c => c.Client.ClientDORSDatas)
                        .Include(c => c.Client.ClientDORSDatas.Select(cdd => cdd.DORSAttendanceState))
                        .Where(c => (c.DORSNotified == false || c.DORSNotified == null) && listOfDORSAttendanceStateIdentifiers.Contains((int)c.DORSAttendanceStateIdentifier))
                        .OrderBy(c => c.DateAdded)
                        .ToList();

                    // store the different organisation's DORS interfaces in this dictionary indexed by organisation.Id
                    var dorsInterfaces = new Dictionary<int, IAM.DORS.Webservice.Interface>();

                    foreach (var courseClient in courseClients)
                    {
                        DORSConnection dorsConnection = null;
                        if (!courseClient.IsMysteryShopper)
                        {
                            try
                            {
                                errorMessage = new StringBuilder();

                                //grab the item and first set the attempts in case the 'add booking' fails
                                //var updatedCourseDORSClient = atlasDB.CourseDORSClients.Where(x => x.Id == courseClient.Id).FirstOrDefault();
                                courseClient.NumberOfDORSNotificationAttempts = courseClient.NumberOfDORSNotificationAttempts == null ? 1 : courseClient.NumberOfDORSNotificationAttempts + 1;
                                courseClient.DateDORSNotificationAttempted = DateTime.Now;

                                DORS.Webservice.Interface dorsInterface = null;
                                if (dorsInterfaces.ContainsKey(courseClient.Course.OrganisationId))
                                {
                                    dorsInterface = dorsInterfaces[courseClient.Course.OrganisationId];
                                }

                                // if it's not there then create it and add it to the cache
                                if (dorsInterface == null)
                                {
                                    dorsConnection = dorsConnections.Where(dc => dc.OrganisationId == courseClient.Course.OrganisationId).FirstOrDefault();

                                    if (dorsConnection != null)
                                    {
                                        dorsInterface = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                        dorsInterfaces.Add(courseClient.Course.OrganisationId, dorsInterface);
                                    }
                                    else
                                    {
                                        errorMessage.AppendLine(String.Format("Organisation Id {0} doesn't have a DORSConnection.", courseClient.Course.OrganisationId));
                                    }
                                }

                                if (dorsInterface != null)
                                {
                                    var attendanceId = courseClient.DORSAttendanceRef;
                                    var DORSCourseIdentifier = courseClient.Course.DORSCourses.FirstOrDefault() != null ? courseClient.Course.DORSCourses.FirstOrDefault().DORSCourseIdentifier : null;
                                    var bookingDate = courseClient.DateAdded;
                                    var paidInFull = courseClient.PaidInFull == true ? true : false;
                                    var datePaidInFull = courseClient.DatePaidInFull == null ? new Nullable<DateTime>() : courseClient.DatePaidInFull;
                                    var DORSAttendanceStateIdentifier = courseClient.DORSAttendanceStateIdentifier;

                                    //validate data is ok to send
                                    if (attendanceId == null)
                                    {
                                        if (courseClient.Client.ClientDORSDatas.Count == 1)
                                        {
                                            var clientDorsData = courseClient.Client.ClientDORSDatas.First();
                                            courseClient.DORSAttendanceRef = clientDorsData.DORSAttendanceRef;
                                            courseClient.DORSAttendanceStateIdentifier = clientDorsData.DORSAttendanceState.DORSAttendanceStateIdentifier;
                                            attendanceId = courseClient.DORSAttendanceRef;
                                            DORSAttendanceStateIdentifier = courseClient.DORSAttendanceStateIdentifier;
                                        }
                                        else
                                        {
                                            errorMessage.AppendLine(String.Format("Client Id {0} doesn't have a DORS Attendance Identifier.", courseClient.ClientId));
                                        }
                                    }
                                    if (DORSCourseIdentifier == null)
                                    {
                                        errorMessage.AppendLine(String.Format("Course Id {0} doesn't have a DORS Course Identifier.", courseClient.CourseId));
                                    }
                                    if (bookingDate == null)
                                    {
                                        errorMessage.AppendLine(string.Format("Client Id {0} for Course Id {1} doesn't have a Booking Date.", courseClient.ClientId, courseClient.CourseId));
                                    }
                                    if (paidInFull == true && datePaidInFull == null)
                                    {
                                        var courseClientPayment = atlasDB.CourseClientPayments
                                                                .Include(ccp => ccp.Payment)
                                                                .OrderByDescending(ccp => ccp.Payment.TransactionDate)
                                                                .Where(ccp => ccp.ClientId == courseClient.ClientId && ccp.CourseId == courseClient.CourseId)
                                                                .FirstOrDefault();
                                        if (courseClientPayment != null)
                                        {
                                            if (courseClientPayment.Payment != null)
                                            {
                                                datePaidInFull = courseClientPayment.Payment.TransactionDate;
                                            }
                                            else
                                            {
                                                errorMessage.AppendLine(string.Format("Client Id {0} for Course Id {1} has an error in its CourseClientPayment table.", courseClient.ClientId, courseClient.CourseId));
                                            }
                                        }
                                        else
                                        {
                                            errorMessage.AppendLine(string.Format("Client Id {0} for Course Id {1} has 'PaidInFull' set but no 'DatePaidInFull'", courseClient.ClientId, courseClient.CourseId));
                                        }
                                    }

                                    //only call Add Booking if we have all the data
                                    if (errorMessage == null || errorMessage.Length == 0)
                                    {
                                        //add booking
                                        if (DORSAttendanceStateIdentifier == (int)DORSAttendanceStates.BookingPending)
                                        {
                                            var bookingAdded = dorsInterface.AddBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, datePaidInFull, null);
                                            if (bookingAdded == true)
                                            {
                                                // if we have "cleared DORS data" and we have a attendance logged for this client update the booking
                                                var courseClientAttended = atlasDBViews.vwCourseClientAttendeds.Where(vcca => vcca.ClientId == courseClient.ClientId && vcca.CourseId == courseClient.CourseId).FirstOrDefault();
                                                if (courseClientAttended != null ? (bool)courseClientAttended.Attended : false)
                                                {
                                                    var bookingUpdated = dorsInterface.UpdateBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, datePaidInFull, null, (int)DORSAttendanceStates.AttendedandCompleted);
                                                    if (bookingUpdated)
                                                    {
                                                        courseClient.DORSNotified = bookingAdded;
                                                        courseClient.DateDORSNotified = DateTime.Now;
                                                        courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.AttendedandCompleted;

                                                        // create a DORSClientCourseAttendanceLog so the client doesn't show in the meter anymore
                                                        if (attendanceController == null)
                                                        {
                                                            attendanceController = new CourseAttendanceController();
                                                        }
                                                        if(attendanceController != null)
                                                        {
                                                            var systemUser = atlasDB.SystemControls.First();
                                                            var attendanceSet = attendanceController.SetDORSClientCourseAttendanceLog((int)DORSCourseIdentifier, (int)attendanceId, (int)systemUser.AtlasSystemUserId, dorsConnection.OrganisationId);
                                                            if (!attendanceSet)
                                                            {
                                                                CreateSystemTrappedErrorDBEntry(itemName, "SetDORSClientCourseAttendanceLog failed for params: " + (int)DORSCourseIdentifier + ", " + (int)attendanceId + ", " + (int)systemUser.AtlasSystemUserId + ", " + dorsConnection.OrganisationId);
                                                            }
                                                        }
                                                    }
                                                }
                                                else if (paidInFull)
                                                {
                                                    var bookingUpdated = dorsInterface.UpdateBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, datePaidInFull, null, (int)DORSAttendanceStates.BookedAndPaid);
                                                    courseClient.DORSNotified = bookingAdded;
                                                    courseClient.DateDORSNotified = DateTime.Now;
                                                    courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.BookedAndPaid;
                                                }
                                                else
                                                {
                                                    courseClient.DORSNotified = bookingAdded;
                                                    courseClient.DateDORSNotified = DateTime.Now;
                                                    courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.Booked;
                                                }
                                                UpdateClientDORSData(courseClient.Client, (int)courseClient.DORSAttendanceStateIdentifier);
                                            }
                                            else
                                            {
                                                errorMessage.AppendLine(string.Format("Call to Add Booking for Client Id {0} for Course Id {1} failed.", courseClient.ClientId, courseClient.CourseId));
                                            }
                                        }
                                        else if (DORSAttendanceStateIdentifier == (int)DORSAttendanceStates.Booked) //update booking
                                        {
                                            if (paidInFull)     // change status to "booked and paid"
                                            {
                                                var bookingUpdated = dorsInterface.UpdateBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, datePaidInFull, null, (int)DORSAttendanceStates.BookedAndPaid);
                                                if (bookingUpdated == true)
                                                {
                                                    courseClient.DORSNotified = bookingUpdated;
                                                    courseClient.DateDORSNotified = DateTime.Now;
                                                    courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.BookedAndPaid;
                                                    UpdateClientDORSData(courseClient.Client, (int)DORSAttendanceStates.BookedAndPaid);
                                                }
                                                else
                                                {
                                                    errorMessage.AppendLine(string.Format("Call to Update Booking for Client Id {0} for Course Id {1} failed.", courseClient.ClientId, courseClient.CourseId));
                                                }
                                            }
                                            else
                                            {
                                                // Update Client in DORS with the latest information we have (Not sure we will we ever get here?)
                                                var bookingUpdated = dorsInterface.UpdateBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, null, null, (int)DORSAttendanceStates.Booked);
                                                if (bookingUpdated == true)
                                                {
                                                    courseClient.DORSNotified = bookingUpdated;
                                                    courseClient.DateDORSNotified = DateTime.Now;
                                                    courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.Booked;
                                                    UpdateClientDORSData(courseClient.Client, (int)DORSAttendanceStates.Booked);
                                                }
                                                else
                                                {
                                                    errorMessage.AppendLine(string.Format("Call to Update Booking for Client Id {0} for Course Id {1} failed.", courseClient.ClientId, courseClient.CourseId));
                                                }
                                            }
                                        }
                                        else if (DORSAttendanceStateIdentifier == (int)DORSAttendanceStates.BookedAndPaid)
                                        {
                                            if (paidInFull)
                                            {
                                                // Update Client in DORS with the latest information we have (Not sure we will we ever get here?)
                                                var bookingUpdated = dorsInterface.UpdateBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, datePaidInFull, null, (int)DORSAttendanceStates.BookedAndPaid);
                                                if (bookingUpdated == true)
                                                {
                                                    courseClient.DORSNotified = bookingUpdated;
                                                    courseClient.DateDORSNotified = DateTime.Now;
                                                    courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.BookedAndPaid;
                                                    UpdateClientDORSData(courseClient.Client, (int)DORSAttendanceStates.BookedAndPaid);
                                                }
                                                else
                                                {
                                                    errorMessage.AppendLine(string.Format("Call to Update Booking for Client Id {0} for Course Id {1} failed.", courseClient.ClientId, courseClient.CourseId));
                                                }
                                            }
                                            else
                                            {
                                                // revert back to "Booked"
                                                // Update Client in DORS with the latest information we have
                                                var bookingUpdated = dorsInterface.UpdateBooking((int)attendanceId, (int)DORSCourseIdentifier, (DateTime)bookingDate, null, null, (int)DORSAttendanceStates.Booked);
                                                if (bookingUpdated == true)
                                                {
                                                    courseClient.DORSNotified = bookingUpdated;
                                                    courseClient.DateDORSNotified = DateTime.Now;
                                                    courseClient.DORSAttendanceStateIdentifier = (int)DORSAttendanceStates.Booked;
                                                    UpdateClientDORSData(courseClient.Client, (int)DORSAttendanceStates.Booked);
                                                }
                                                else
                                                {
                                                    errorMessage.AppendLine(string.Format("Call to Update Booking for Client Id {0} for Course Id {1} failed.", courseClient.ClientId, courseClient.CourseId));
                                                }
                                            }
                                        }



                                        var courseClientUpdate = atlasDB.Entry(courseClient);
                                        courseClientUpdate.State = EntityState.Modified;
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                                // so we can email administrators (via a trigger)
                                if (DORSConnectionException.isDORSConnectionException(ex))
                                {
                                    dorsConnection.DateLastConnectionFailure = DateTime.Now;
                                    var dbEntry = atlasDB.Entry(dorsConnection);
                                    dbEntry.State = EntityState.Modified;
                                }
                                errorMessage.AppendLine(String.Format("An error occurred in DORSNotifyNewCourseClients, ClientId: {1}, CourseId: {2} , Message: {0}", ex.Message, courseClient.ClientId, courseClient.CourseId));
                                UpdateLastRunLogDBEntry(new StringBuilder(String.Format("An error occurred in DORSNotifyNewCourseClients: {0}", ex.Message)), itemName);
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
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(String.Format("An error occurred in DORSNotifyNewCourseClients: {0}", ex.Message));
            }
            finally
            {
                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());

                }
                atlasDB.SaveChanges();
            }
            return true;
        }

        // Update the client's DORS data so we can keep track of the attendance state
        private void UpdateClientDORSData(Client client, int dorsAttendanceStateIdentifier)
        {
            if (client != null)
            {
                if (client.ClientDORSDatas.Count() > 0)
                {
                    var clientDORSData = client.ClientDORSDatas.First();
                    clientDORSData.DataValidatedAgainstDORS = false;
                    clientDORSData.DORSAttendanceStateId = GetAttendanceStateId(dorsAttendanceStateIdentifier);

                    var dbEntry = atlasDB.Entry(clientDORSData);
                    dbEntry.State = EntityState.Modified;
                }
            }
        }

        /// <summary>
        /// Get the Id of the attendance state entity
        /// </summary>
        /// <param name="attendanceStateIdentifier">The DORS identifier for the attendance state</param>
        /// <returns>The Id of the entity</returns>
        private int GetAttendanceStateId(int attendanceStateIdentifier)
        {
            var attendanceStateId = -1;
            if (dorsAttendanceStatesCache == null)
            {
                dorsAttendanceStatesCache = atlasDB.DORSAttendanceStates.ToList();
            }
            var attendanceState = dorsAttendanceStatesCache.Where(asc => asc.DORSAttendanceStateIdentifier == attendanceStateIdentifier).FirstOrDefault();
            if (attendanceState != null)
            {
                attendanceStateId = attendanceState.Id;
            }
            return attendanceStateId;
        }

        [HttpGet]
        [Route("api/DORS/RotateDefaultDORSConnection")]
        public int RotateDefaultDORSConnection()
        {
            var storedProcOutput = atlasDB.uspRotateToNextDORSConnectionAsDefault();
            return storedProcOutput;
        }

        [HttpGet]
        [Route("api/DORS/CheckForceList")]

        public bool CheckForceList()
        {
            var dorsConnections = atlasDB.DORSConnections
                        .Where(dc => dc.Enabled == true)
                        .ToList();

            var atlasDORSForces = atlasDB.DORSForces.ToList();
            var combinedForceList = new List<DORS.Webservice.Models.Force>();

            // makes sure there are some dors connections to process before proceeding
            if (dorsConnections != null && dorsConnections.Count > 0)
            {
                //goes through all the connections
                foreach (var connection in dorsConnections)
                {
                    //gets credentials and logs in
                    var dorsInterface = new DORS.Webservice.Interface(connection.LoginName, connection.Password, useMocks);
                    var organisationForceList = dorsInterface.GetForceList();

                    //if Organisation force list contains items, processes them and adds to 
                    //a combined force list
                    foreach (var force in organisationForceList)
                    {
                        combinedForceList.Add(force);
                    }
                }
                // if the retrieved(combined) force list contains items, proceed
                if (combinedForceList != null && combinedForceList.Count > 0)
                {
                    //removes duplicate entries.
                    var distinctForceList = combinedForceList.GroupBy(dfl => dfl.Id).Select(cfl => cfl.First()).ToList();

                    foreach (var force in distinctForceList)
                    {
                        var existingForce = atlasDORSForces.Where(adf => adf.DORSForceIdentifier == force.Id).FirstOrDefault();

                        if (existingForce == null)
                        {
                            //add in force
                            var newForce = new DORSForce();
                            newForce.DORSForceIdentifier = force.Id;
                            newForce.Name = force.Name;
                            newForce.PNCCode = force.PNCCode;
                            atlasDB.DORSForces.Add(newForce);
                        }
                        else if (existingForce.DORSForceIdentifier == force.Id && existingForce.Name != force.Name
                                    || existingForce.DORSForceIdentifier == force.Id && existingForce.PNCCode != force.PNCCode)
                        {
                            //update record with pnccode and name if it's different to what's held on db
                            existingForce.Name = force.Name;
                            existingForce.PNCCode = force.PNCCode;
                            atlasDB.Entry(existingForce).State = EntityState.Modified;
                        }
                    }
                }
            }

            atlasDB.SaveChanges();
            return true;
        }

        [HttpGet]
        [Route("api/DORS/GetAndUpdateTrainerSchemeLicenceStatus")]
        public bool GetAndUpdateTrainerSchemeLicenceStatus()

        {
            var dorsTrainers = atlasDB.DORSTrainers
                                        .Include(dt => dt.Trainer)
                                        .Include(dt => dt.Trainer.TrainerOrganisation)
                                        .Include(dt => dt.Trainer.TrainerOrganisation.Select(to => to.Organisation))
                                        .Include(dt => dt.Trainer.TrainerOrganisation.Select(to => to.Organisation).Select(dc => dc.DORSConnections)).ToList();

            var dorsTrainerLicences = atlasDB.DORSTrainerLicences.ToList();

            if (dorsTrainers != null)
            {
                foreach (var dorsTrainer in dorsTrainers)
                {
                    var connection = dorsTrainer.Trainer.TrainerOrganisation.FirstOrDefault().Organisation.DORSConnections.FirstOrDefault();
                    if (connection != null)
                    {
                        var dorsInterface = new DORS.Webservice.Interface(connection.LoginName, connection.Password, useMocks);

                        //DORS Web Trainer Licences are retrieved from the DORS web service.
                        // We are not passing a DORS Scheme Id in to get a list of all of 
                        // the trainers licences for every scheme
                        int? dorsSchemeId = null;
                        var dorsWebTrainerLicences = dorsInterface.GetTrainerLicences(dorsSchemeId, dorsTrainer.Id, dorsTrainer.Trainer.Surname);

                        foreach (var dorsWebTrainerLicence in dorsWebTrainerLicences)
                        {

                            //checks to see if there's a match of trainer Id and dors scheme Id before continuing.
                            //if there's a match, it updates. If there isn't, a new record is added.
                            var existingLicence = dorsTrainerLicences.Where(dtl => dtl.DORSTrainerIdentifier == dorsWebTrainerLicence.Id.ToString()
                                                                                       && dtl.DORSSchemeIdentifier == dorsWebTrainerLicence.SchemeId).FirstOrDefault(); //??*/


                            if (existingLicence != null)
                            {
                                existingLicence.DateUpdated = DateTime.Now;
                                existingLicence.ExpiryDate = dorsWebTrainerLicence.ExpiryDate;
                                existingLicence.LicenceCode = dorsWebTrainerLicence.LicenseCode;
                                existingLicence.DORSTrainerLicenceStateName = dorsWebTrainerLicence.Status;
                                existingLicence.DORSTrainerLicenceTypeName = dorsWebTrainerLicence.LicenceType;
                                atlasDB.Entry(existingLicence).State = EntityState.Modified;
                            }
                            else
                            {
                                var newLicence = new DORSTrainerLicence();
                                newLicence.DateAdded = DateTime.Now;
                                newLicence.DateUpdated = DateTime.Now;
                                newLicence.DORSSchemeIdentifier = dorsWebTrainerLicence.SchemeId;
                                newLicence.DORSTrainerIdentifier = dorsWebTrainerLicence.Id.ToString();
                                newLicence.DORSTrainerLicenceStateName = dorsWebTrainerLicence.Status;
                                newLicence.DORSTrainerLicenceTypeName = dorsWebTrainerLicence.LicenceType;
                                newLicence.ExpiryDate = dorsWebTrainerLicence.ExpiryDate;
                                newLicence.LicenceCode = dorsWebTrainerLicence.LicenseCode;
                                atlasDB.DORSTrainerLicences.Add(newLicence);

                            }
                        }
                    }
                    try
                    {
                        atlasDB.SaveChanges();
                    }
                    catch (Exception ex)
                    {
                        // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                        // so we can email administrators (via a trigger)
                        if (DORSConnectionException.isDORSConnectionException(ex))
                        {
                            connection.DateLastConnectionFailure = DateTime.Now;
                            var dbEntry = atlasDB.Entry(connection);
                            dbEntry.State = EntityState.Modified;
                            atlasDB.SaveChanges();
                        }
                        throw ex;
                    }
                }
            }
            return true;
        }

        [HttpGet]
        [Route("api/DORS/getDORSSites")]
        public bool getDORSSites()
        {
            var gotDORSSites = false;
            var dorsControl = atlasDB.DORSControls.FirstOrDefault();
            if (dorsControl != null)
            {
                var refreshNow = false;
                if (dorsControl.LastDORSSiteRefresh == null)
                {
                    refreshNow = true;
                }
                else
                {
                    if ((DateTime)dorsControl.LastDORSSiteRefresh < DateTime.Now.AddHours(-12))
                    {
                        refreshNow = true;
                    }
                }
                if (dorsControl.DORSSiteRefreshASAP || refreshNow)
                {
                    dorsControl.LastDORSSiteRefresh = DateTime.Now;
                    dorsControl.DORSSiteRefreshASAP = false;

                    // Supplier = Organisation that has a DORS Connection
                    var suppliers = atlasDB.Organisations
                                            .Include(o => o.DORSConnections)
                                            .Include(o => o.OrganisationDORSSites)
                                            .Include(o => o.OrganisationDORSSites.Select(ods => ods.DORSSite))
                                            .Where(o => o.DORSConnections.Count() > 0)
                                            .ToList();

                    foreach (var supplier in suppliers)
                    {
                        var connection = supplier.DORSConnections.First();
                        try
                        {
                            var dorsInterface = new DORS.Webservice.Interface(connection.LoginName, connection.Password, useMocks);
                            var dorsSites = dorsInterface.GetSiteList();
                            foreach (var dorsSite in dorsSites)
                            {
                                if (!supplier.OrganisationDORSSites.Any(ods => ods.DORSSite.Name == dorsSite.Name &&
                                                                                 ods.DORSSite.DORSSiteIdentifier == dorsSite.Id))
                                {
                                    // doesn't exist in the DB so need to add it
                                    var site = new DORSSite();
                                    site.Name = dorsSite.Name;
                                    site.DORSSiteIdentifier = dorsSite.Id;

                                    var organisationDorsSite = new OrganisationDORSSite();
                                    organisationDorsSite.DORSSite = site;
                                    organisationDorsSite.DateAdded = DateTime.Now;
                                    organisationDorsSite.OrganisationId = supplier.Id;

                                    atlasDB.OrganisationDORSSites.Add(organisationDorsSite);
                                    atlasDB.DORSSites.Add(site);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // if there was a problem connecting to DORS log the time in the DORSConnection Entity 
                            // so we can email administrators (via a trigger)
                            if (DORSConnectionException.isDORSConnectionException(ex))
                            {
                                connection.DateLastConnectionFailure = DateTime.Now;
                                var dbEntry = atlasDB.Entry(connection);
                                dbEntry.State = EntityState.Modified;
                            }
                            CreateSystemTrappedErrorDBEntry("Get DORS Sites, SupplierId: " + supplier.Id, ex.Message);
                        }
                    }
                    atlasDB.SaveChanges();
                    gotDORSSites = true;
                }
            }
            return gotDORSSites;
        }

        [HttpGet]
        [Route("api/DORS/notifyDORSAboutCourseAttendance")]

        public bool NotifyDORSAboutCourseAttendance()
        {
            var errorMessage = new StringBuilder();
            var codePosition = "";
            var itemName = "notifyDORSAboutCourseAttendance " + getSystemName();
            var vwCourseClientDORSAttendanceReadyForSendings = atlasDBViews.vwCourseClientDORSAttendanceReadyForSendings.ToList();

            try
            {
                codePosition = "X0";
                if (vwCourseClientDORSAttendanceReadyForSendings != null && vwCourseClientDORSAttendanceReadyForSendings.Count > 0)
                {
                    // Traverse the DORS connections
                    var dorsConnections = atlasDB.DORSConnections
                        .Where(dc => dc.Enabled == true)
                        .ToList();

                    if (dorsConnections != null && dorsConnections.Count > 0)
                    {
                        codePosition = "X1";
                        foreach (var dorsConnection in dorsConnections)
                        {
                            var dorsInterface = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                            var vwCourseClientDORSAttendanceReadySummaries = atlasDBViews.vwCourseClientDORSAttendanceReadySummaries
                                                                                    .Where(x => x.OrganisationId == dorsConnection.OrganisationId)
                                                                                    .OrderByDescending(o => o.CourseStartDate)
                                                                                    .ToList();
                            codePosition = "X2";
                            if (vwCourseClientDORSAttendanceReadySummaries != null && vwCourseClientDORSAttendanceReadySummaries.Count > 0)
                            {
                                codePosition = "X2a";
                                foreach (var vwCourseClientDORSAttendanceReadySummary in vwCourseClientDORSAttendanceReadySummaries)
                                {
                                    var courseId = vwCourseClientDORSAttendanceReadySummary.CourseId;
                                    var dorsCourse = atlasDB.DORSCourses
                                                                        .Where(dc => dc.CourseId == courseId).FirstOrDefault();
                                    if (dorsCourse != null)
                                    {
                                        int courseDORSIdentifer = dorsCourse.DORSCourseIdentifier == null ? -1 : (int)dorsCourse.DORSCourseIdentifier;

                                        var courseClientReadyForSendings = vwCourseClientDORSAttendanceReadyForSendings.Where(x => x.CourseId == courseId).ToList();

                                        codePosition = "X3";
                                        var clientFailedToUpdate = false;
                                        foreach (var courseClientReadyForSending in courseClientReadyForSendings)
                                        {
                                            var dorsClientAttendanceIdentifier = courseClientReadyForSending.DORSClientAttendanceIdentifier ?? -1;
                                            var dorsAttendanceStateIdentifier = courseClientReadyForSending.NewDORSAttendanceStateIdentifier ?? -1;
                                            codePosition = "X4";
                                            if (dorsClientAttendanceIdentifier > 0 && dorsAttendanceStateIdentifier > 0)
                                            {
                                                var clientCourseAttendanceLog = atlasDB.DORSClientCourseAttendanceLogs
                                                                                        .Where(
                                                                                            dccal => dccal.DORSClientIdentifier == dorsClientAttendanceIdentifier &&
                                                                                                        dccal.DORSCourseIdentifier == courseDORSIdentifer
                                                                                        )
                                                                                        .FirstOrDefault();

                                                if (clientCourseAttendanceLog == null)  // initialise the db log
                                                {
                                                    clientCourseAttendanceLog = new DORSClientCourseAttendanceLog();
                                                    clientCourseAttendanceLog.DORSClientIdentifier = dorsClientAttendanceIdentifier;
                                                    clientCourseAttendanceLog.DORSCourseIdentifier = courseDORSIdentifer;
                                                    clientCourseAttendanceLog.DateCreated = DateTime.Now;
                                                }
                                                if (clientCourseAttendanceLog.DORSNotified == false)
                                                {
                                                    try
                                                    {
                                                        codePosition = "X5 ... courseDORSIdentifer: " + courseDORSIdentifer;
                                                        clientCourseAttendanceLog.NumberOfAttempts++;
                                                        clientCourseAttendanceLog.DateLastAttempted = DateTime.Now;

                                                        // notify DORS of the course attendance
                                                        var updateBooking = dorsInterface.UpdateBooking(dorsClientAttendanceIdentifier, courseDORSIdentifer, null, null, "", dorsAttendanceStateIdentifier);

                                                        codePosition = "X5a";
                                                        if (updateBooking == false)
                                                        {
                                                            clientFailedToUpdate = true;
                                                            errorMessage.AppendLine(string.Format("Could not update DORS with information for clientId: {0}, courseId: {1}", courseClientReadyForSending.CourseClientId, courseId));
                                                            // log the error message
                                                            clientCourseAttendanceLog.ErrorMessage = string.Format("Could not update DORS with information for clientId: {0}, courseId: {1}", courseClientReadyForSending.CourseClientId, courseId);
                                                        }
                                                        else
                                                        {
                                                            clientCourseAttendanceLog.DORSNotified = true;
                                                        }
                                                    }
                                                    catch (Exception ex)
                                                    {
                                                        clientFailedToUpdate = true;
                                                        var error = String.Format("DORSUpdateBooking:ClientIdent={0},CourseIdent={1},State={2}. " + ex.Message + " " + ex.StackTrace, dorsClientAttendanceIdentifier, courseDORSIdentifer, dorsAttendanceStateIdentifier);
                                                        CreateSystemTrappedErrorDBEntry(itemName, error);
                                                        // log the error message
                                                        var logErrorMessage = String.Format("DORSUpdateBooking:ClientIdent={0},CourseIdent={1},State={2}. " + ex.Message + " " + ex.StackTrace, dorsClientAttendanceIdentifier, courseDORSIdentifer, dorsAttendanceStateIdentifier);
                                                        if (logErrorMessage.Length > 1000) logErrorMessage = logErrorMessage.Substring(0, 1000);
                                                        clientCourseAttendanceLog.ErrorMessage = logErrorMessage;
                                                    }
                                                }
                                                if (clientCourseAttendanceLog.Id > 0)
                                                {
                                                    // update log in db
                                                    var dbentry = atlasDB.Entry(clientCourseAttendanceLog);
                                                    dbentry.State = EntityState.Modified;
                                                }
                                                else
                                                {
                                                    // add log to db
                                                    atlasDB.DORSClientCourseAttendanceLogs.Add(clientCourseAttendanceLog);
                                                }
                                            }
                                            else
                                            {
                                                clientFailedToUpdate = true;
                                                errorMessage.AppendLine(string.Format("DORS Attendance Identifier or DORS Attendance State Identifier can not be null to proceed. Relating to Client Id: {0}, courseId: {1}", courseClientReadyForSending.CourseClientId, courseId));
                                            }
                                        }
                                        if (clientFailedToUpdate == false)
                                        {
                                            var course = atlasDB.Course.Where(c => c.Id == courseId).First();
                                            course.AttendanceSentToDORS = true;
                                            atlasDB.Entry(course).Property("AttendanceSentToDORS").IsModified = true;
                                        }
                                    }
                                    else
                                    {
                                        errorMessage.AppendLine(string.Format("DORS Course Data Missing; Course Id: {0}", courseId));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage.AppendLine(ex.Message);
                errorMessage.AppendLine("codePosition : " + codePosition);
            }

            if (errorMessage != null && errorMessage.Length > 0)
            {
                CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
            }

            atlasDB.SaveChanges();
            return true;
        }

        [HttpGet]
        [Route("api/DORS/processDORSCheck")]
        public bool ProcessDORSCheck()
        {
            var controller = new DORSWebServiceInterfaceController();
            var vwClientsWithMissingDORSDatas = atlasDBViews.vwClientsWithMissingDORSDatas
                                                            .OrderByDescending(x => x.DateCreated)
                                                            .Take(200)
                                                            .ToList();

            foreach (var vwClientsWithMissingDORSData in vwClientsWithMissingDORSDatas)
            {
                var clientId = (int)vwClientsWithMissingDORSData.ClientId;
                var licenceNumber = vwClientsWithMissingDORSData.ClientLicenceNumber;
                controller.PerformDORSCheck(clientId, licenceNumber);
            }

            return true;
        }

        [HttpGet]
        [Route("api/DORS/ProcessStuckClients")]
        public bool ProcessStuckClients()
        {
            var controller = new DORSWebServiceInterfaceController();

            // find the atlas system userid
            var atlasSystemUserId = atlasDB.SystemControls.First().AtlasSystemUserId;

            var aDayAgo = DateTime.Now.AddDays(-1);

            // return all the clients that haven't been sync'd with DORS
            //var stuckClients = atlasDB.CourseDORSClients
            //                            .Include(cdc => cdc.Course)
            //                            .Where(cdc => cdc.DORSNotified == null ? true : ((bool)cdc.DORSNotified == false) &&
            //                                    (cdc.DORSAttendanceStateIdentifier == null ? true : cdc.DORSAttendanceStateIdentifier < 0) &&
            //                                    (cdc.DateDORSNotificationAttempted == null ? true : (DateTime)cdc.DateDORSNotificationAttempted < aDayAgo)
            //                            )
            //                            .Take(50)   // so we don't spam DORS
            //                            .OrderByDescending(cdc => cdc.Id)
            //                            .ToList();

            var stuckClients = atlasDBViews.vwClientsUnableToUpdateInDORS
                                            .ToList();

            foreach (var stuckClient in stuckClients)
            {
                try
                {
                    var clearedDORSData = controller.clearDORSData((int)stuckClient.ClientId, stuckClient.OrganisationId, (int)atlasSystemUserId);
                }
                catch (Exception ex)
                {
                    CreateSystemTrappedErrorDBEntry("Process Stuck Clients " + getSystemName(), "Error when processing ClientId: " + ((int)stuckClient.ClientId) + ", " + ex.Message + ", " + ex.StackTrace);
                }
            }

            return true;
        }

        [HttpGet]
        [Route("api/DORS/ProcessStuckClientsCoursePlaces")]
        public bool ProcessStuckClientsCoursePlaces()
        {
            var itemName = "ProcessStuckClientsCoursePlaces " + getSystemName();
            var processed = false;
            var courseDORSClients = atlasDB.CourseDORSClients
                                            .Include(cdc => cdc.Course)
                                            .Include(cdc => cdc.Course.CourseVenue)
                                            .Include(cdc => cdc.Course.DORSCourses)
                                            .Where(cdc => cdc.DORSAttendanceStateIdentifier < 0 && (cdc.DORSNotified == null || cdc.DORSNotified == false))
                                            .ToList();

            var processedCourseIds = new List<int>();
            
            foreach (var courseDORSClient in courseDORSClients)
            {
                try
                {
                    // check to see if we have already processed this course
                    if (courseDORSClient.CourseId != null ? (processedCourseIds.Contains((int)courseDORSClient.CourseId) == false) : false)
                    {
                        var DORSCourseIdentifier = courseDORSClient.Course.DORSCourses.Count > 0 ? courseDORSClient.Course.DORSCourses.First().DORSCourseIdentifier : -1;
                        if (DORSCourseIdentifier != null ? ((int) DORSCourseIdentifier > 0) : false)
                        {
                            var dorsConnection = atlasDB.DORSConnections.Where(dc => dc.OrganisationId == courseDORSClient.Course.OrganisationId).FirstOrDefault();
                            if(dorsConnection != null)
                            {
                                // get how many places the course has in Atlas
                                var atlasCoursePlaces = -1;
                                if(courseDORSClient.Course.CourseVenue.Count > 0)
                                {
                                    var courseVenue = courseDORSClient.Course.CourseVenue.First();
                                    atlasCoursePlaces = courseVenue.MaximumPlaces;
                                }

                                // get the course from DORS
                                var dorsInterface = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                var courseInDORS = dorsInterface.GetCourseById((int)DORSCourseIdentifier);
                            
                                // if they don't match update DORS
                                if(courseInDORS.Capacity != atlasCoursePlaces && atlasCoursePlaces > 0)
                                {
                                    var updatedCourseInDORS = dorsInterface.UpdateCourse(courseInDORS.Id, courseInDORS.Title, courseInDORS.DateTime, atlasCoursePlaces, courseInDORS.SiteId, courseInDORS.ForceContractId);
                                    if (updatedCourseInDORS.Capacity != atlasCoursePlaces)
                                    {
                                        throw new Exception("Course places failed to update.");
                                    }
                                }
                            }
                        }
                    }                
                }
                catch(Exception ex)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, "CourseDORSClientId:" + courseDORSClient.Id + ", " + ex.Message + " " + ex.StackTrace);
                    atlasDB.SaveChanges();
                }
                finally
                {
                    if(processedCourseIds.Contains((int)courseDORSClient.CourseId) == false)
                    {
                        processedCourseIds.Add((int)courseDORSClient.CourseId);
                    }
                }
            }
            processed = true;
            return processed;
        }
    }
}
