using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using IAM.Atlas.Data;
using System.Data.Entity;
using IAM.DORS.Webservice.Models;
using System.Configuration;
using IAM.DORS.Webservice;
using System.Net.Http.Formatting;
using System.Web.Http.ModelBinding;
using static IAM.DORS.Webservice.Interface;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class DORSWebServiceInterfaceController : AtlasBaseController
    {
        private bool _useMocks = true;
        bool useMocks {
            get {
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
            set {
                _useMocks = value;
            }
        }

        [HttpGet]
        [Route("api/dorswebserviceinterface/courseavailable/{dorsConnectionId}/{licenseNumber}/{clientId}/{requestedByUserId}")]
        public bool CourseAvailable(int dorsConnectionId, string licenseNumber, int clientId, int requestedByUserId)
        {
            var available = false;
            try
            {
                var dorsLicenseCheckRequest = new DORSLicenceCheckRequest();
                dorsLicenseCheckRequest.LicenceNumber = licenseNumber;
                if (requestedByUserId > 0) dorsLicenseCheckRequest.RequestByUserId = requestedByUserId;
                dorsLicenseCheckRequest.Requested = DateTime.Now;
                if (clientId > 0) dorsLicenseCheckRequest.ClientId = clientId;

                atlasDB.DORSLicenceCheckRequests.Add(dorsLicenseCheckRequest);
                atlasDB.SaveChanges();

                var dorsConnection = atlasDB.DORSConnections.Where(dc => dc.Id == dorsConnectionId && dc.Enabled == true).FirstOrDefault();
                if (dorsConnection != null)
                {
                    var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);

                    var clientStatuses = dorsInterface.ClientLookupStatus(licenseNumber);

                    if (clientStatuses.Count > 0) available = true;
                }

                var dorsLicenceCheckCompleted = new DORSLicenceCheckCompleted();
                dorsLicenceCheckCompleted.LicenceNumber = licenseNumber;
                if (requestedByUserId > 0) dorsLicenceCheckCompleted.RequestByUserId = requestedByUserId;
                dorsLicenceCheckCompleted.Completed = DateTime.Now;
                dorsLicenceCheckCompleted.Requested = dorsLicenseCheckRequest.Requested;
                if (clientId > 0) dorsLicenceCheckCompleted.ClientId = clientId;
                if (dorsLicenseCheckRequest.Id > 0) dorsLicenceCheckCompleted.DORSLicenceCheckRequestId = dorsLicenseCheckRequest.Id;
                atlasDB.DORSLicenceCheckCompleteds.Add(dorsLicenceCheckCompleted);
                atlasDB.SaveChanges();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return available;
        }

        [HttpGet]
        [Route("api/dorswebserviceinterface/connectionstatuscheck")]
        [AllowCrossDomainAccess]
        public bool ConnectionStatusCheck()
        {
            var successful = true;
            var dorsConnections = atlasDB.DORSConnections
                        .Where(dc => dc.Enabled == true)
                        .ToList();

            foreach (var dorsConnection in dorsConnections)
            {
                var identity = "";
                var startTime = DateTime.Now;
                try
                {
                    var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                    identity = dorsInterface.GetIdentity();
                }
                catch (Exception ex)
                {
                    // we can log the exception here
                    successful = false;
                }
                finally
                {
                    var endTime = DateTime.Now;
                    var systemStateSummary = atlasDB.SystemStateSummaries
                                                .Where(
                                                    sss => sss.OrganisationId == dorsConnection.OrganisationId &&
                                                    sss.Code == "DORS")
                                                .FirstOrDefault();
                    if (systemStateSummary == null)
                    {
                        systemStateSummary = new SystemStateSummary();
                        systemStateSummary.Code = "DORS";
                        systemStateSummary.OrganisationId = dorsConnection.OrganisationId;
                    }

                    systemStateSummary.DateUpdated = DateTime.Now;

                    if (String.IsNullOrEmpty(identity))
                    {
                        systemStateSummary.SystemStateId = 4;
                        systemStateSummary.Message = "DORS is not currently Contactable";
                        successful = false;
                    }
                    else
                    {
                        systemStateSummary.SystemStateId = 1;
                        systemStateSummary.Message = "DORS Enabled and Contactable";
                    }
                    if (systemStateSummary.Id > 0)
                    {
                        atlasDB.SystemStateSummaries.Attach(systemStateSummary);
                        var entry = atlasDB.Entry(systemStateSummary);
                        entry.State = System.Data.Entity.EntityState.Modified;
                    }
                    else
                    {
                        atlasDB.SystemStateSummaries.Add(systemStateSummary);
                    }
                    atlasDB.SaveChanges();
                }
            }
            return successful;
        }

        [HttpPost]
        [Route("api/dorswebserviceinterface/getClientStatus")]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        public List<ClientStatus> getClientStatus([FromBody] FormDataCollection formBody)
        {
            var clientStatuses = new List<ClientStatus>();
            var formParameters = formBody.ReadAs<getClientStatusParameters>();
            string driversLicence = formParameters.driversLicence;
            int organisationId = formParameters.organisationId;

            var dorsConnection = atlasDB.DORSConnections.Where(dc => dc.OrganisationId == organisationId && dc.Enabled == true).FirstOrDefault();
            if (dorsConnection != null)
            {
                var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                clientStatuses = dorsService.ClientLookupStatus(driversLicence);
            }
            return clientStatuses;
        }

        public class getClientStatusParameters
        {
            public string driversLicence { get; set; }
            public int organisationId { get; set; }
        }

        public List<ClientStatus> GetClientStatus(string driversLicence)
        {
            var clientStatuses = new List<ClientStatus>();
            // find all the dors connections that have been designated for client lookup usage rotation
            var dorsConnections = atlasDB.DORSConnections
                                            .Include(dc => dc.DORSConnectionForRotations)
                                            .Where(dc => dc.DORSConnectionForRotations.Count > 0 && dc.Enabled == true)
                                            .ToList();
            var gotClientStatuses = false;
            foreach (var dorsConnection in dorsConnections)
            {
                try
                {
                    if (!gotClientStatuses)     // if the dorsConnection had a connection failure this flag won't be set to true
                    {
                        var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                        clientStatuses = dorsService.ClientLookupStatus(driversLicence);
                        gotClientStatuses = true;
                    }
                }
                catch(Exception ex)
                {
                    if (DORSConnectionException.isDORSConnectionException(ex))  // report an error connecting to DORS 
                    {
                        dorsConnection.DateLastConnectionFailure = DateTime.Now;
                        var dbEntry = atlasDB.Entry(dorsConnection);
                        dbEntry.State = EntityState.Modified;
                        atlasDB.SaveChanges();
                        //TODO: Paul Look at thes Thrwos. Don't seem right to me .... Rob
                        //throw new Exception("The NDORS service is currently uncontactable.  We are unable to process your query at this time, please try again later.");
                    }
                    else
                    {
                        //throw ex;
                    }
                }
            }
            return clientStatuses;
        }

        /// <summary>
        /// Used by the UI project to access the PerformDORSCheck function
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/PerformDORSCheck")]
        public List<DORSClientCourseAttendance> PerformDORSCheck([FromBody] FormDataCollection formData)
        {
            var formParams = formData.ReadAs<PerformDORSCheckParameters>();
            return PerformDORSCheck(formParams.ClientId, formParams.LicenceNumber);
        }

        /// <summary>
        /// Performs a DORS client lookup and stores the information into the atlas DB
        /// </summary>
        /// <returns></returns>
        public List<DORSClientCourseAttendance> PerformDORSCheck(int ClientId, string LicenceNumber)
        {
            var dorsClientCourseAttendances = new List<DORSClientCourseAttendance>();
            var clientStatuses = GetClientStatus(LicenceNumber);    // the call to DORS

            try {
                if (clientStatuses.Count > 0)
                {
                    var schemes = atlasDB.DORSSchemes.ToList();
                    var referringAuthorities = atlasDB.ReferringAuthorities
                                                        .Include(ra => ra.DORSForce)
                                                        .ToList();
                    var attendanceStates = atlasDB.DORSAttendanceStates.ToList();

                    foreach (var clientStatus in clientStatuses)
                    {
                        // do we already have a entry in ClientDORSData?
                        var clientDORSData = atlasDB.ClientDORSDatas
                                                    .Include(cdd => cdd.DORSScheme)
                                                    .Where(cdd => cdd.ClientId == ClientId && cdd.DORSScheme.DORSSchemeIdentifier == clientStatus.SchemeId)
                                                    .FirstOrDefault();

                        if (clientDORSData == null)
                        {
                            clientDORSData = new ClientDORSData();
                        }
                        clientDORSData.ClientId = ClientId;
                        clientDORSData.DORSAttendanceRef = clientStatus.AttendanceId;
                        clientDORSData.DataValidatedAgainstDORS = true;

                        var scheme = schemes.Where(s => s.DORSSchemeIdentifier == clientStatus.SchemeId).FirstOrDefault();
                        if (scheme != null)
                        {
                            clientDORSData.DORSSchemeId = scheme.Id;
                        }
                        else
                        {
                            // Create and Add the new DORSScheme
                            var DORSSchemes = new DORSScheme();

                            DORSSchemes.DORSSchemeIdentifier = clientStatus.SchemeId;
                            DORSSchemes.Name = "Scheme " + clientStatus.SchemeId.ToString();

                            // Set the Defaults
                            DORSSchemes.MinTheoryTrainers = 1;
                            DORSSchemes.MinPracticalTrainers = 0;
                            DORSSchemes.MaxTheoryTrainers = 2;
                            DORSSchemes.MaxPracticalTrainers = 0;
                            DORSSchemes.MaxPlaces = 2;
       
                            clientDORSData.DORSSchemeId = DORSSchemes.Id;

                            atlasDB.DORSSchemes.Add(DORSSchemes);
                        }

                        var referringAuthority = referringAuthorities.Where(ra => ra.DORSForce != null ? ra.DORSForce.DORSForceIdentifier == clientStatus.ForceId : false).FirstOrDefault();
                        if (referringAuthority != null)
                        {
                            clientDORSData.ReferringAuthorityId = referringAuthority.Id;
                        }
                        clientDORSData.ExpiryDate = clientStatus.ExpiryDate;

                        var attendanceState = attendanceStates.Where(state => state.DORSAttendanceStateIdentifier == clientStatus.AttendanceStatusId).FirstOrDefault();
                        if (attendanceState != null)
                        {
                            clientDORSData.DORSAttendanceStateId = attendanceState.Id;
                        }

                        if (clientDORSData.Id > 0)
                        {
                            clientDORSData.DateUpdated = DateTime.Now;

                            var dbEntry = atlasDB.Entry(clientDORSData);
                            dbEntry.State = EntityState.Modified;
                        }
                        else
                        {
                            clientDORSData.DateCreated = DateTime.Now;
                            atlasDB.ClientDORSDatas.Add(clientDORSData);
                        }



                        // do we have an entry in DORSClientCourseAttendance?
                        var dorsClientCourseAttendance = atlasDB.DORSClientCourseAttendances
                                                                .Where(dcca => dcca.ClientId == ClientId && dcca.DORSSchemeIdentifier == clientStatus.SchemeId)
                                                                .FirstOrDefault();

                        if (dorsClientCourseAttendance == null)
                        {
                            dorsClientCourseAttendance = new DORSClientCourseAttendance();
                        }
                        dorsClientCourseAttendance.ClientId = ClientId;

                        dorsClientCourseAttendance.DORSAttendanceRef = clientStatus.AttendanceId;
                        dorsClientCourseAttendance.DORSAttendanceStateIdentifier = clientStatus.AttendanceStatusId;
                        dorsClientCourseAttendance.DORSExpiryDate = clientStatus.ExpiryDate;
                        dorsClientCourseAttendance.DORSForceIdentifier = clientStatus.ForceId;
                        dorsClientCourseAttendance.DORSSchemeIdentifier = clientStatus.SchemeId;

                        if (dorsClientCourseAttendance.Id > 0)
                        {
                            // update
                            dorsClientCourseAttendance.DateUpdated = DateTime.Now;
                            var dbEntry = atlasDB.Entry(dorsClientCourseAttendance);
                            dbEntry.State = EntityState.Modified;
                        }
                        else
                        {
                            dorsClientCourseAttendance.DateCreated = DateTime.Now;
                            atlasDB.DORSClientCourseAttendances.Add(dorsClientCourseAttendance);
                        }
                        dorsClientCourseAttendances.Add(dorsClientCourseAttendance);

                        atlasDB.SaveChanges();
                    }
                }
            }
            catch (Exception ex)
            {
                var err = ex;
                LogError("PerformDORSCheck", ex);
                throw ex;
            }
            return dorsClientCourseAttendances;
        }

        /// <summary>
        /// Used to deserialize the httppost parameters passed into the PerformDORSCheck function
        /// </summary>
        public class PerformDORSCheckParameters
        {
            public int ClientId { get; set; }
            public string LicenceNumber { get; set; }
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/AddCourseToDORS/{courseId}")]
        public int AddCourseToDORS(int courseId)
        {
            var message = "";
            int dorsCourseId = 0;
            var course = atlasDB.Course
                            .Include(c => c.Organisation)
                            .Include(c => c.DORSCourses)
                            .Include(c => c.Organisation.DORSConnections)
                            .Include(c => c.Organisation.OrganisationDORSForceContracts)
                            .Include(c => c.Organisation.OrganisationDORSForceContracts.Select(odfc => odfc.DORSForceContract))
                            .Include(c => c.CourseVenue)
                            .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                            .Include(c => c.CourseVenue.Select(cv => cv.Venue).Select(v => v.DORSSiteVenues))
                            .Include(c => c.CourseVenue.Select(cv => cv.Venue).Select(v => v.DORSSiteVenues.Select(dsv => dsv.DORSSite)))
                            .Include(c => c.CourseDate)
                            .Include(c => c.CourseType)
                            .Include(c => c.CourseType.DORSSchemeCourseTypes)
                            .Include(c => c.CourseType.DORSSchemeCourseTypes.Select(dsct => dsct.DORSScheme))
                            .Where(c => c.Id == courseId).FirstOrDefault();
            if (course != null)
            {
                if(course.Organisation != null)
                {
                    if(course.Organisation.DORSConnections.Count > 0)
                    {
                        var courseVenue = course.CourseVenue.FirstOrDefault();
                        if (courseVenue != null && courseVenue.Venue != null)
                        {
                            var courseDate = course.CourseDate.OrderBy(cd => cd.DateStart).FirstOrDefault();
                            if (courseDate != null)
                            {
                                var dorsSiteVenue = courseVenue.Venue.DORSSiteVenues.FirstOrDefault();
                                if (dorsSiteVenue != null)
                                {
                                    // find the force contract where the dors scheme = the course's coursetype via dorsschemecoursetype
                                    var dorsSchemeCourseType = course.CourseType.DORSSchemeCourseTypes.FirstOrDefault();
                                    if (dorsSchemeCourseType != null)
                                    {
                                        var dorsSchemeIdentifier = dorsSchemeCourseType.DORSScheme != null ? dorsSchemeCourseType.DORSScheme.DORSSchemeIdentifier : -1;
                                        var forceContract = course.Organisation.OrganisationDORSForceContracts
                                                                                .Where(
                                                                                        odfc => odfc.DORSForceContract.DORSSchemeIdentifier == dorsSchemeIdentifier &&
                                                                                                odfc.DORSForceContract.StartDate <= courseDate.DateStart &&
                                                                                                odfc.DORSForceContract.EndDate >= courseDate.DateStart
                                                                                    )
                                                                                    .FirstOrDefault();
                                        if (forceContract != null)
                                        {
                                            DateTime courseStartDate;
                                            if (courseDate.DateStart != null)
                                            {
                                                // is this course already in DORS?
                                                if (course.DORSCourses.Count > 0)
                                                {
                                                    // just return the dorsCourseId
                                                    var dorsCourse = course.DORSCourses.First();
                                                    if (dorsCourse.DORSCourseIdentifier != null)
                                                    {
                                                        dorsCourseId = (int)dorsCourse.DORSCourseIdentifier;
                                                    }
                                                    else
                                                    {
                                                        try
                                                        {
                                                            courseStartDate = CourseController.GetCourseDate((DateTime)courseDate.DateStart, course.DefaultStartTime);
                                                            var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                                                            var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                                            if (dorsSiteVenue.DORSSite.DORSSiteIdentifier != null)
                                                            {
                                                                dorsCourseId = dorsService.AddCourse(course.Reference, courseStartDate, courseVenue.MaximumPlaces, (int)dorsSiteVenue.DORSSite.DORSSiteIdentifier, forceContract.DORSForceContractId);

                                                                // store the DORS CourseId to the database
                                                                if (dorsCourseId > 0)
                                                                {
                                                                    dorsCourse.DORSCourseIdentifier = dorsCourseId;

                                                                    var entry = atlasDB.Entry(course);
                                                                    entry.State = EntityState.Modified;

                                                                    // record entry into our local database for reference as we can't get course info from DORS
                                                                    var dorsCourseData = new DORSCourseData();
                                                                    dorsCourseData.Title = course.Reference;
                                                                    dorsCourseData.CourseDate = courseStartDate;
                                                                    dorsCourseData.Capacity = courseVenue.MaximumPlaces;
                                                                    dorsCourseData.DORSSiteIdentifier = (int)dorsSiteVenue.DORSSite.DORSSiteIdentifier;
                                                                    dorsCourseData.DORSForceContractIdentifier = forceContract.DORSForceContractId;
                                                                    dorsCourseData.DORSCourseIdentifier = dorsCourseId;
                                                                    dorsCourseData.DateSubmittedToDORS = DateTime.Now;

                                                                    atlasDB.DORSCourseDatas.Add(dorsCourseData);
                                                                    atlasDB.SaveChanges();
                                                                }
                                                                else
                                                                {
                                                                    message = "Couldn't add course to DORS, please try again later.";
                                                                }
                                                            }
                                                            else
                                                            {
                                                                message = "Couldn't add course to DORS (DORSSiteIdentifier is NULL??), please try again later.";
                                                            }
                                                        }
                                                        catch (Exception ex)
                                                        {
                                                            message = ex.Message;
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    try
                                                    {
                                                        courseStartDate = GetCourseDate((DateTime)courseDate.DateStart, course.DefaultStartTime);
                                                        var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                                                        var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                                        if (dorsSiteVenue.DORSSite.DORSSiteIdentifier != null)
                                                        {
                                                            dorsCourseId = dorsService.AddCourse(course.Reference, courseStartDate, courseVenue.MaximumPlaces, (int)dorsSiteVenue.DORSSite.DORSSiteIdentifier, (int) forceContract.DORSForceContract.DORSForceContractIdentifier);

                                                            // store the DORS CourseId to the database
                                                            if (dorsCourseId > 0)
                                                            {
                                                                var dorsCourse = new DORSCourse();
                                                                dorsCourse.DORSCourseIdentifier = dorsCourseId;
                                                                course.DORSCourses.Add(dorsCourse);

                                                                var entry = atlasDB.Entry(course);
                                                                entry.State = EntityState.Modified;

                                                                // record entry into our local database for reference as we can't get course info from DORS
                                                                var dorsCourseData = new DORSCourseData();
                                                                dorsCourseData.Title = course.Reference;
                                                                dorsCourseData.CourseDate = courseStartDate;
                                                                dorsCourseData.Capacity = courseVenue.MaximumPlaces;
                                                                dorsCourseData.DORSSiteIdentifier = (int)dorsSiteVenue.DORSSite.DORSSiteIdentifier;
                                                                dorsCourseData.DORSForceContractIdentifier = forceContract.DORSForceContractId;
                                                                dorsCourseData.DORSCourseIdentifier = dorsCourseId;
                                                                dorsCourseData.DateSubmittedToDORS = DateTime.Now;

                                                                atlasDB.DORSCourseDatas.Add(dorsCourseData);
                                                                atlasDB.SaveChanges();
                                                            }
                                                        }
                                                        else
                                                        {
                                                            message = "DORSSiteIdentifier is NULL??, please report to Administrators.";
                                                        }
                                                    }
                                                    catch (Exception ex)
                                                    {
                                                        message = ex.Message;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                message = "Course doesn't have a start date.";
                                            }
                                        }
                                        else
                                        {
                                            message = "No Valid Force Contract associated with this Organisation for this Scheme.";
                                        }
                                    }
                                    else
                                    {
                                        message = "No associated DORS scheme could be found.";
                                    }
                                }
                                else
                                {
                                    message = "Course Venue not in DORS.";
                                }
                            }
                            else
                            {
                                message = "Course doesn't have a date set.";
                            }
                        }
                        else
                        {
                            message = "Course Venue not found.";
                        }
                    }
                    else
                    {
                        message = "Organisation isn't a DORS enabled Organisation.";
                    }
                }
                else
                {
                    message = "Course Organisation not found.";
                }
            }
            else
            {
                message = "Course not found.";
            }
            if (!String.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return dorsCourseId;
        }

        /// <summary>
        /// adds the string containing time in HH:mm format to a datetime 
        /// </summary>
        /// <returns></returns>
        public static DateTime GetCourseDate(DateTime date, string hhmm)
        {
            var dateTime = date;
            var timeParts = hhmm.Split(":".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
            if (timeParts.Length == 2)
            {
                int hh, mm;
                if (int.TryParse(timeParts[0], out hh))
                {
                    if (int.TryParse(timeParts[1], out mm))
                    {
                        dateTime = dateTime.AddHours(hh);
                        dateTime = dateTime.AddMinutes(mm);
                    }
                }
            }
            return dateTime;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/UpdateCourseInDORS/{courseId}")]
        public bool UpdateCourseInDORS(int courseId)
        {
            var updated = false;
            var message = "";
            int dorsCourseId = 0;
            var course = atlasDB.Course
                            .Include(c => c.Organisation)
                            .Include(c => c.DORSCourses)
                            .Include(c => c.Organisation.DORSConnections)
                            .Include(c => c.Organisation.OrganisationDORSForceContracts)
                            .Include(c => c.CourseVenue)
                            .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                            .Include(c => c.CourseVenue.Select(cv => cv.Venue).Select(v => v.DORSSiteVenues))
                            .Include(c => c.CourseVenue.Select(cv => cv.Venue).Select(v => v.DORSSiteVenues.Select(dsv => dsv.DORSSite)))
                            .Include(c => c.CourseDate)
                            .Include(c => c.CourseType)
                            .Include(c => c.CourseType.DORSSchemeCourseTypes)
                            .Include(c => c.CourseDORSForceContracts)
                            .Include(c => c.CourseDORSForceContracts.Select(cdfc => cdfc.DORSForceContract))
                            .Where(c => c.Id == courseId).FirstOrDefault();
            if (course != null)
            {
                if (course.Organisation != null)
                {
                    if (course.Organisation.DORSConnections.Count > 0)
                    {
                        var courseVenue = course.CourseVenue.FirstOrDefault();
                        if (courseVenue != null && courseVenue.Venue != null)
                        {
                            var courseDate = course.CourseDate.OrderBy(cd => cd.DateStart).FirstOrDefault();
                            if (courseDate != null)
                            {
                                var dorsSiteVenue = courseVenue.Venue.DORSSiteVenues.FirstOrDefault();
                                if (dorsSiteVenue != null)
                                {
                                    // find the force contract where the dors scheme = the course's coursetype via dorsschemecoursetype
                                    var dorsScheme = course.CourseType.DORSSchemeCourseTypes.FirstOrDefault();
                                    if (dorsScheme != null)
                                    {
                                        DORSForceContract forceContract = null;
                                        var courseDORSForceContract = course.CourseDORSForceContracts.FirstOrDefault();
                                        if(courseDORSForceContract != null)
                                        {
                                            forceContract = courseDORSForceContract.DORSForceContract;
                                        }                                                                             
                                        if (forceContract != null)
                                        {
                                            DateTime courseStartDate;
                                            if (courseDate.DateStart != null)
                                            {
                                                // is this course in DORS?
                                                if (course.DORSCourses.Count > 0)
                                                {
                                                    // does it have a dorsCourseId?
                                                    var dorsCourse = course.DORSCourses.First();
                                                    if (dorsCourse.DORSCourseIdentifier != null)
                                                    {
                                                        dorsCourseId = (int)dorsCourse.DORSCourseIdentifier;

                                                        if (dorsCourseId > 0)
                                                        {
                                                            try
                                                            {
                                                                courseStartDate = (DateTime)courseDate.DateStart;
                                                                var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                                                                var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                                                                var updatedCourse = dorsService.UpdateCourse(dorsCourseId, course.Reference, courseStartDate, courseVenue.MaximumPlaces, (int)dorsSiteVenue.DORSSite.DORSSiteIdentifier, (int)forceContract.DORSForceContractIdentifier);
                                                                updated = true;

                                                                // record entry into our local database for reference as we can't get course info from DORS
                                                                var dorsCourseData = new DORSCourseData();
                                                                dorsCourseData.Title = course.Reference;
                                                                dorsCourseData.CourseDate = courseStartDate;
                                                                dorsCourseData.Capacity = courseVenue.MaximumPlaces;
                                                                dorsCourseData.DORSSiteIdentifier = (int)dorsSiteVenue.DORSSite.DORSSiteIdentifier;
                                                                dorsCourseData.DORSForceContractIdentifier = forceContract.DORSForceContractIdentifier;
                                                                dorsCourseData.DORSCourseIdentifier = dorsCourseId;
                                                                dorsCourseData.DateSubmittedToDORS = DateTime.Now;

                                                                atlasDB.DORSCourseDatas.Add(dorsCourseData);
                                                                atlasDB.SaveChanges();

                                                                // update this course's trainers into DORS
                                                                var systemInfo = atlasDB.SystemControls.First();
                                                                var atlasSystemUserId = systemInfo.AtlasSystemUserId == null ? -1: (int)systemInfo.AtlasSystemUserId;
                                                                updateCourseTrainers(courseId, atlasSystemUserId);
                                                            }
                                                            catch (Exception ex)
                                                            {
                                                                message = ex.Message;
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        message = "Course doesn't have a DORS Course Id.";
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                message = "Course doesn't have a start date.";
                                            }
                                        }
                                        else
                                        {
                                            message = "No Valid Force Contract associated with this Organisation.";
                                        }
                                    }
                                    else
                                    {
                                        message = "No associated DORS scheme could be found.";
                                    }
                                }
                                else
                                {
                                    message = "Course Venue not in DORS.";
                                }
                            }
                            else
                            {
                                message = "Course doesn't have a date set.";
                            }
                        }
                        else
                        {
                            message = "Course Venue not found.";
                        }
                    }
                    else
                    {
                        message = "Organisation isn't a DORS enabled Organisation.";
                    }
                }
                else
                {
                    message = "Course Organisation not found.";
                }
            }
            else
            {
                message = "Course not found.";
            }
            if (!String.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return updated;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [Route("api/dorswebserviceinterface/UpdateLocalDORSInfo")]
        public object UpdateLocalDORSInfo()
        {
            var updateStatus = new UpdateLocalDORSStatus();
            var dorsConnections = atlasDB.DORSConnections
                        .Where(dc => dc.Enabled == true)
                        .ToList();
            foreach (var dorsConnection in dorsConnections)
            {
                try
                {
                    var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);

                    var forces = dorsInterface.GetForceList();
                    var attendenceStatuses = dorsInterface.GetAttendanceStatusList();
                    var siteList = dorsInterface.GetSiteList();
                    var schemes = dorsInterface.GetSchemeList();
                    var forceContracts = dorsInterface.GetForceContractList();

                    var localForces = atlasDB.DORSForces.ToList();
                    var localAttendenceStatuses = atlasDB.DORSAttendanceStates.ToList();
                    var localDorsSites = atlasDB.DORSSites.ToList();
                    var localForceContracts = atlasDB.DORSForceContracts.ToList();
                    var localSchemes = atlasDB.DORSSchemes.ToList();

                    var changed = false;

                    foreach (var force in forces)
                    {
                        if (!localForces.Any(lf => lf.DORSForceIdentifier == force.Id))
                        {
                            // add the force to the database
                            var dorsForce = new DORSForce();
                            dorsForce.DORSForceIdentifier = force.Id;
                            dorsForce.Name = force.Name;
                            dorsForce.PNCCode = force.PNCCode;

                            atlasDB.DORSForces.Add(dorsForce);

                            changed = true;
                        }
                    }
                    if (changed)
                    {
                        updateStatus.updated.Add("Forces");
                        changed = false;
                    }
                    else
                    {
                        updateStatus.unchanged.Add("Forces");
                    }

                    // TODO: have questions about DORSAttendanceState DB table.... will hold fire on attendencestatuses for now

                    foreach (var site in siteList)
                    {
                        if (!localDorsSites.Any(lds => lds.DORSSiteIdentifier == site.Id))
                        {
                            // add the DORS site to the database
                            var dorsSite = new DORSSite();
                            dorsSite.DORSSiteIdentifier = site.Id;
                            dorsSite.Name = site.Name;

                            atlasDB.DORSSites.Add(dorsSite);
                            changed = true;
                        }
                    }
                    if (changed)
                    {
                        updateStatus.updated.Add("DORS Sites");
                        changed = false;
                    }
                    else
                    {
                        updateStatus.unchanged.Add("DORS Sites");
                    }

                    foreach (var forceContract in forceContracts)
                    {
                        if (!localForceContracts.Any(lfc => lfc.DORSForceContractIdentifier == forceContract.ForceContractID))
                        {
                            var dorsForceContract = new DORSForceContract();
                            dorsForceContract.DORSForceContractIdentifier = forceContract.ForceContractID;
                            dorsForceContract.DORSForceIdentifier = forceContract.ForceID;
                            dorsForceContract.DORSAccreditationIdentifier = forceContract.AccreditationID;
                            dorsForceContract.CourseAdminFee = forceContract.CourseAdminFee;
                            dorsForceContract.StartDate = forceContract.StartDate;
                            dorsForceContract.EndDate = forceContract.EndDate;
                            dorsForceContract.DORSSchemeIdentifier = forceContract.SchemeID;

                            var organisationDORSForceContract = new OrganisationDORSForceContract();
                            organisationDORSForceContract.OrganisationId = dorsConnection.OrganisationId;

                            dorsForceContract.OrganisationDORSForceContracts.Add(organisationDORSForceContract);
                            atlasDB.DORSForceContracts.Add(dorsForceContract);

                            changed = true;
                        }
                    }
                    if (changed)
                    {
                        updateStatus.updated.Add("Force Contracts");
                        changed = false;
                    }
                    else
                    {
                        updateStatus.unchanged.Add("Force Contracts");
                    }

                    foreach (var scheme in schemes)
                    {
                        if (!localSchemes.Any(ls => ls.DORSSchemeIdentifier == scheme.Id))
                        {
                            var dorsScheme = new DORSScheme();
                            dorsScheme.DORSSchemeIdentifier = scheme.Id;
                            dorsScheme.Name = scheme.Name;

                            atlasDB.DORSSchemes.Add(dorsScheme);
                            changed = true;
                        }
                    }
                    if (changed)
                    {
                        updateStatus.updated.Add("DORS Schemes");
                        changed = false;
                    }
                    else
                    {
                        updateStatus.unchanged.Add("DORS Schemes");
                    }
                    atlasDB.SaveChanges();
                }
                catch (Exception ex)
                {
                    updateStatus.exceptionOrganisations.Add("Organisation Id " + dorsConnection.OrganisationId + ": " + ex.Message);
                    LogError("UpdateLocalDORSInfo", ex);
                    //updateStatus.exceptions.Add(ex);
                }
            }
            return updateStatus;
        }

        public class UpdateLocalDORSStatus
        {
            public List<string> updated;
            public List<string> unchanged;
            public List<Exception> exceptions;
            public List<string> exceptionOrganisations;

            public UpdateLocalDORSStatus()
            {
                updated = new List<string>();
                unchanged = new List<string>();
                exceptions = new List<Exception>();
                exceptionOrganisations = new List<string>();
            }
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [Route("api/dorswebserviceinterface/getAvailableCourses/{schemeId}/{organisationId}")]
        public List<Data.Course> GetAvailableCourses(int schemeId, int organisationId)
        {
            var courses = new List<Data.Course>();
            courses = atlasDB.Course
                            .Include(c => c.CourseType)
                            .Include(c => c.CourseDate)
                            .Where(c => c.CourseType.DORSSchemeCourseTypes.Any(ds => ds.DORSSchemeId == schemeId) &&
                                c.Organisation.OrganisationDORSForceContracts.Any(odfc => odfc.DORSForceContract.DORSSchemeIdentifier == schemeId) && 
                                c.OrganisationId == organisationId &&
                                c.CourseDate.Any(cd => cd.DateStart > DateTime.Now))
                            .ToList();
            return courses;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/BookClientOnCourse/{attendanceId}/{courseId}")]
        public object BookClientOnCourse(int attendanceId, int courseId)
        {
            bool booked = false;
            string message = "";
            var course = atlasDB.Course
                            .Include(c => c.DORSCourses)
                            .Include(c => c.Organisation)
                            .Include(c => c.Organisation.DORSConnections)
                            .Where(c => c.Id == courseId).FirstOrDefault();
            
            if(course != null)
            {
                var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                var dorsCourse = course.DORSCourses.FirstOrDefault();
                if(dorsCourse != null && dorsCourse.DORSCourseIdentifier != null)
                {
                    booked = dorsService.AddBooking(attendanceId, (int) dorsCourse.DORSCourseIdentifier, DateTime.Now, null, "");
                }
                else
                {
                    message = "Couldn't find DORS course.";
                }
            }
            else
            {
                message = "Couldn't find course.";
            }
            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return booked;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/ChangeClientsCourse/{attendanceId}/{courseId}/{attendanceStatusId}")]
        public object ChangeClientsCourse(int attendanceId, int courseId, int attendanceStatusId)
        {
            bool booked = false;
            string message = "";
            var course = atlasDB.Course
                            .Include(c => c.DORSCourses)
                            .Include(c => c.Organisation)
                            .Include(c => c.Organisation.DORSConnections)
                            .Where(c => c.Id == courseId).FirstOrDefault();

            if (course != null)
            {
                var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                var dorsCourse = course.DORSCourses.FirstOrDefault();
                if (dorsCourse != null && dorsCourse.DORSCourseIdentifier != null)
                {
                    booked = dorsService.UpdateBooking(attendanceId, (int)dorsCourse.DORSCourseIdentifier, DateTime.Now, null, "", attendanceStatusId);
                }
                else
                {
                    message = "Couldn't find DORS course.";
                }
            }
            else
            {
                message = "Couldn't find course.";
            }
            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return booked;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/cancelCourse/{courseId}")]
        public bool CancelCourse(int courseId)
        {
            bool courseCancelled = false;
            string message = "";
            var course = atlasDB.Course
                            .Include(c => c.DORSCourses)
                            .Include(c => c.Organisation)
                            .Include(c => c.Organisation.DORSConnections)
                            .Where(c => c.Id == courseId).FirstOrDefault();

            if (course != null)
            {
                var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                var dorsCourse = course.DORSCourses.FirstOrDefault();
                if (dorsCourse != null && dorsCourse.DORSCourseIdentifier != null)
                {
                    if(dorsCourse.DORSCourseIdentifier != null)
                    {
                        courseCancelled = dorsService.CancelCourse((int) dorsCourse.DORSCourseIdentifier);
                    }
                    else
                    {
                        message = "No DORSCourse Id found.";
                    }
                }
                else
                {
                    message = "Couldn't find DORS course.";
                }
            }
            else
            {
                message = "Couldn't find course.";
            }
            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return courseCancelled;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/dorswebserviceinterface/cancelBooking/{attendanceId}")]
        public bool CancelBooking(int attendanceId, int organisationId)
        {
            bool bookingCancelled = false;
            // find out which dorsConnection to use

            var dorsConnection = atlasDB.DORSConnections.Where(dc => dc.OrganisationId == organisationId  && dc.Enabled == true).FirstOrDefault();

            var dorsService = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
            bookingCancelled = dorsService.CancelBooking(attendanceId);
            return bookingCancelled;
          
        }


        public bool updateCourseTrainers(int courseId, int userId)
        {
            var updated = false;
            var errorMessage = "";
            try
            {
                var course = atlasDB.Course
                .Include(c => c.DORSCourses)
                .Include(c => c.Organisation)
                .Include(c => c.Organisation.DORSConnections)
                .Include(c => c.CourseTrainer)
                .Include(c => c.CourseTrainer.Select(ct => ct.Trainer))
                .Include(c => c.CourseTrainer.Select(ct => ct.Trainer.DORSTrainers))
                .Where(c => c.Id == courseId).FirstOrDefault();

                if(course.DORSCourses.Count > 0)
                {
                    var dorsCourseId = course.DORSCourses.First().DORSCourseIdentifier != null ? (int) course.DORSCourses.First().DORSCourseIdentifier : -1;
                    if (dorsCourseId > 0)
                    {
                        var dorsTrainers = getDORSTrainers(course);
                        var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                        if (dorsConnection != null)
                        {
                            var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                            dorsInterface.UpdateTrainers(dorsCourseId, dorsTrainers);
                            updated = true;
                        }
                        else
                        {
                            errorMessage = "No DORS login could be found.";
                        }
                    }
                    else
                    {
                        errorMessage = "No corresponding DORS Course Id could be found.";
                    }
                }
                else
                {
                    errorMessage = "Not a DORS course.";
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
            if (!string.IsNullOrEmpty(errorMessage))
            {
                throw new Exception(errorMessage);
            }
            return updated;
        }

        List<UpdateTrainer> getDORSTrainers(Data.Course course)
        {
            var dorsTrainers = new List<UpdateTrainer>();
            var trainersAndLicenceTypes = atlasDB.uspGetCourseDORSTrainerIdentifiersAndLicenceTypes(course.Id).ToList();
            foreach (var trainersAndLicenceType in trainersAndLicenceTypes)
            {
                int dorsTrainerId = -1;
                if (Int32.TryParse(trainersAndLicenceType.DORSTrainerIdentifier, out dorsTrainerId))
                {
                    var existingTrainer = dorsTrainers.Where(dt => dt.DORSTrainerId == dorsTrainerId && dt.DORSTrainerLicenceTypeId == trainersAndLicenceType.DORSTrainerLicenceTypeIdentifier).FirstOrDefault();
                    if (existingTrainer == null)
                    {
                        dorsTrainers.Add(new UpdateTrainer { DORSTrainerId = dorsTrainerId, DORSTrainerLicenceTypeId = trainersAndLicenceType.DORSTrainerLicenceTypeIdentifier });
                    }
                }
            }
            return dorsTrainers;
        }

        [Route("api/dorswebserviceinterface/clearDORSData/{clientId}/{organisationId}/{userId}")]
        [AuthorizationRequired]
        [HttpGet]
        /// <summary>
        /// 
        /// 
        /// </summary>
        /// <param name="clientId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public bool clearDORSData(int clientId, int organisationId, int userId)
        {
            var cleared = false;
            var isSystemAdmin = atlasDB.SystemAdminUsers.Any(sau => sau.UserId == userId);
            var errorMessage = "";
            if (isSystemAdmin)
            {
                var client = atlasDB.Clients
                                    .Include(c => c.ClientOrganisations)
                                    .Include(c => c.ClientOrganisations.Select(co => co.Organisation))
                                    .Include(c => c.ClientOrganisations.Select(co => co.Organisation.DORSConnections))
                                    .Include(c => c.ClientDORSDatas)
                                    .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSScheme))
                                    .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSAttendanceState))
                                    .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSScheme.DORSSchemeCourseTypes))
                                    .Include(c => c.ClientLicences)
                                    .Where(c => c.Id == clientId)
                                    .FirstOrDefault();

                if (client.ClientOrganisations.Count > 0)
                {
                    var clientOrganisation = client.ClientOrganisations
                                                    .Where(co => co.Organisation.DORSConnections.Count() > 0 && co.Organisation.Id == organisationId)
                                                    .FirstOrDefault();
                    if (clientOrganisation != null)
                    {
                        var dorsConnection = clientOrganisation.Organisation.DORSConnections.First();
                        if (dorsConnection != null)
                        {
                            var dorsInterface = new IAM.DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                            if (client.ClientDORSDatas.Count() > 0)
                            {
                                var dorsAttendanceRef = client.ClientDORSDatas.First().DORSAttendanceRef;
                                if(dorsAttendanceRef != null)
                                {
                                    cleared = dorsInterface.CancelBooking((int) dorsAttendanceRef);
                                    if (cleared)
                                    {
                                        // remove all the existing courseDORSClient entries from the que
                                        var removedExistingCourseDORSClients = removeFromDORSQue(client.Id);

                                        var courseClients = atlasDB.CourseClients
                                                                    .Include(cc => cc.CourseClientRemoveds)
                                                                    .Include(cc => cc.Course)
                                                                    .Where(cc => cc.ClientId == clientId && cc.CourseClientRemoveds.Count() == 0)
                                                                    .ToList();

                                        foreach(var courseClient in courseClients)
                                        {
                                            var fullyPaid = (courseClient.TotalPaymentMade - courseClient.TotalPaymentDue) >= 0;

                                            // create a CourseDORSClient to try to sync the client with DORS again.
                                            var courseDorsClient = new CourseDORSClient();
                                            courseDorsClient.ClientId = client.Id;
                                            courseDorsClient.DORSNotified = false;
                                            courseDorsClient.DateAdded = DateTime.Now;
                                            courseDorsClient.CourseId = courseClient.CourseId;
                                            courseDorsClient.DORSAttendanceRef = (int)dorsAttendanceRef;
                                            courseDorsClient.NumberOfDORSNotificationAttempts = 0;
                                            if (fullyPaid)
                                            {
                                                courseDorsClient.PaidInFull = true;
                                                courseDorsClient.DatePaidInFull = courseClient.LastPaymentMadeDate;
                                            }
                                            else
                                            {
                                                courseDorsClient.PaidInFull = false;
                                                courseDorsClient.DatePaidInFull = null;
                                                if(courseClient.TotalPaymentMade > 0)
                                                {
                                                    courseDorsClient.OnlyPartPaymentMade = true;
                                                }
                                            }
                                            // get the dors attendance state and mystery shopper details
                                            foreach (var dorsData in client.ClientDORSDatas)
                                            {
                                                if (dorsData.DORSScheme.DORSSchemeCourseTypes.Where(dsct => dsct.CourseTypeId == courseClient.Course.CourseTypeId).Count() > 0)
                                                {
                                                    courseDorsClient.IsMysteryShopper = dorsData.IsMysteryShopper;
                                                    // reset the DORSAttendanceStateIdentifier to be Booking Pending 
                                                    // the NotifyNewCourseClients scheduled task will notify DORS of the accurate status based on whether the client has paid/attendance has been logged
                                                    var bookingPendingState = atlasDB.DORSAttendanceStates.Where(das => das.Name == "Booking Pending").FirstOrDefault();
                                                    var bookingPendingStateIdentifier = bookingPendingState != null ? bookingPendingState.DORSAttendanceStateIdentifier : (int)DORSAttendanceStates.BookingPending;
                                                    courseDorsClient.DORSAttendanceStateIdentifier = bookingPendingStateIdentifier;
                                                }
                                            }
                                            atlasDB.CourseDORSClients.Add(courseDorsClient);
                                            atlasDB.SaveChanges();
                                        }
                                    }
                                }
                            }
                            else
                            {
                                // client doesn't have any DORS Data, perform a DORS check.
                                var clientLicence = client.ClientLicences.OrderByDescending(cl => cl.Id).FirstOrDefault();
                                if (clientLicence != null)
                                {
                                    PerformDORSCheck(client.Id, clientLicence.LicenceNumber);
                                }
                                else
                                {
                                    errorMessage = "Client Id: " + client.Id + " has no licence.";
                                }
                            }
                        }
                        else
                        {
                            errorMessage = "No DORS login could be found.";
                        }
                    }
                }
            }
            else
            {
                errorMessage = "Only System Admins have access to this feature.";
            }
            if (!string.IsNullOrEmpty(errorMessage))
            {
                throw new Exception(errorMessage);
            }
            return cleared;
        }

        //private bool ResetCourseDORSClient(int clientId, int organisationId)
        //{
        //    var reset = false;
        //    var courseDORSClients = atlasDB.CourseDORSClients.Where(cdc => cdc.ClientId == clientId && cdc.DORSNotified == false).ToList();
        //    foreach(var courseDORSClient in courseDORSClients)
        //    {
        //        // set dorsnotified to 1 and the dorsattendancestateidentifier to negative so we have a record of one's that didn't work
        //        // though this may not be necessary...
        //        if(courseDORSClient.DORSAttendanceStateIdentifier > 0)
        //        {
        //            courseDORSClient.DORSAttendanceStateIdentifier = courseDORSClient.DORSAttendanceStateIdentifier * -1;
        //        }
        //        courseDORSClient.DORSNotified = true;
        //        var entry = atlasDB.Entry(courseDORSClient);
        //        entry.State = EntityState.Modified;
        //    }
        //    // create a new courseDORSClient entry for each course for the provided organisation this client is on in atlas
        //    var clientController = new ClientController();
        //    var client = clientController.Get(clientId);
        //    foreach(var courseInfo in client)

        //    return reset;
        //}

        [HttpGet]
        [Route("api/dorswebserviceinterface/retryContactingDORS/{clientId}")]
        public bool retryContactingDORS(int clientId)
        {
            var backInQue = false;
            // if DORSNotified = null or false return it
            var courseDORSClients = atlasDB.CourseDORSClients
                                            .Where(
                                                cdc => (cdc.DORSNotified == null ? true : (cdc.DORSNotified == false)) &&
                                                cdc.ClientId == clientId
                                            )
                                            .OrderByDescending(cdc => cdc.Id)
                                            .ToList();
            var first = true;
            var failed = false;
            foreach (var courseDorsClient in courseDORSClients)
            {
                if (first)  // the most recent record
                {
                    var readdedResult = retrySendingCourseDORSClientToDORS(courseDorsClient);
                    if (readdedResult == false) failed = true;
                    first = false;
                }
                else
                {
                    var removedResult = removeCourseDORSClientFromDORSQueue(courseDorsClient);
                    if (removedResult == false) failed = true;
                }
            }
            if (!failed) backInQue = true;
            return backInQue;
        }

        [HttpGet]
        [Route("api/dorswebserviceinterface/removeFromDORSQue/{clientId}")]
        public bool removeFromDORSQue(int clientId)
        {
            var removed = false;
            var courseDORSClients = atlasDB.CourseDORSClients
                                            .Where(
                                                cdc => (cdc.DORSNotified == null ? true : (cdc.DORSNotified == false)) &&
                                                cdc.ClientId == clientId
                                            )
                                            .OrderByDescending(cdc => cdc.Id)
                                            .ToList();
            var failedRemovals = false;
            foreach (var courseDORSClient in courseDORSClients)
            {
                var removalResult = removeCourseDORSClientFromDORSQueue(courseDORSClient);
                if(removalResult == false)
                {
                    failedRemovals = true;
                }
            }
            if (!failedRemovals)
            {
                removed = true;
            }
            return removed;
        }

        /// <summary>
        /// Set DORSNotified to true and the attendance state to a negative number 
        /// (for logging purposes so we can see past records that didn't successfully notify DORS) 
        /// </summary>
        /// <param name="cdc">The CourseDORSClient you want to stop contacting DORS</param>
        /// <returns></returns>
        bool removeCourseDORSClientFromDORSQueue(CourseDORSClient cdc)
        {
            var removed = false;
            if(cdc != null)
            {
                cdc.DORSNotified = true;
                if(cdc.DORSAttendanceStateIdentifier != null)
                {
                    if ((int) cdc.DORSAttendanceStateIdentifier > 0)
                    {
                        cdc.DORSAttendanceStateIdentifier = cdc.DORSAttendanceStateIdentifier * -1;
                    }
                }
                var entry = atlasDB.Entry(cdc);
                entry.State = EntityState.Modified;
                atlasDB.SaveChanges();
                removed = true;
            }
            return removed;
        }

        /// <summary>
        /// reset NumberOfDORSNotificationAttempts to zero, and the DORSAttendanceStateIdentifier (which turns negative when it has failed more than ten times so it won't get picked up by the scheduled task).
        /// </summary>
        /// <param name="cdc"></param>
        /// <returns></returns>
        bool retrySendingCourseDORSClientToDORS(CourseDORSClient cdc)
        {
            var requed = false;
            cdc.NumberOfDORSNotificationAttempts = 0;
            cdc.DORSNotified = false; // this should be false already but while we are here...
            if(cdc.DORSAttendanceStateIdentifier < 0)
            {
                cdc.DORSAttendanceStateIdentifier = cdc.DORSAttendanceStateIdentifier * -1;
            }
            var entry = atlasDB.Entry(cdc);
            entry.State = EntityState.Modified;
            atlasDB.SaveChanges();
            requed = true;
            return requed;
        }
    }
}
