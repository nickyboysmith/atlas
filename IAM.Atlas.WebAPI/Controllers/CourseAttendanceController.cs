using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web;
using System.Data.Entity.Validation;


namespace IAM.Atlas.WebAPI.Controllers
{
    public class CourseAttendanceController : AtlasBaseController 
    {

        [AuthorizationRequired]
        [Route("api/CourseAttendance/Search")]
        [HttpPost]
        public object GetCourseDates([FromBody] FormDataCollection formBody)
        {
            try
            {
                // get dates
                var startDate = new Nullable<DateTime>();
                var endDate = new Nullable<DateTime>();

                // Set the course type id as an integer
                var courseTypeId = 0;

                // Set the course type category Id as an integer
                var courseTypeCategoryId = 0;

                // Set param to run date query
                var hasStartDateBeenSet = false;
                var hasEndDateBeenSet = false;

                // Set param to run course type query
                var hasCourseTypeIdBeenSet = false;

                // Set param to run course type category query
                var hasCourseTypeCategoryIdBeenSet = false;

                // Get Org Id
                var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Please select an Organisation");

                // Check to see if a course type Id exists in the object
                if (!string.IsNullOrEmpty(formBody["courseTypeId"]))
                {
                    // Get Course Type Id
                    courseTypeId = StringTools.GetIntOrFail("courseTypeId", ref formBody, "Invalid Course Selected");

                    // Set the var as true
                    hasCourseTypeIdBeenSet = true;
                }

                // Check to see if a course type category Id exists in the object
                if (!string.IsNullOrEmpty(formBody["courseTypeCategoryId"]))
                {
                    // Get Course Type Id
                    courseTypeCategoryId = StringTools.GetIntOrFail("courseTypeCategoryId", ref formBody, "Invalid Category selected");

                    // Set the var as true
                    hasCourseTypeCategoryIdBeenSet = true;
                }


                // do the date check 
                // to see if we should add a start date query to the linq 
                if (string.IsNullOrEmpty(formBody["startDate"]) == false)
                {
                    startDate = StringTools.GetDateOrFail("startDate", ref formBody, "Invalid start date.");
                    hasStartDateBeenSet = true;
                }

                // to see if we should add an end date query to the linq 
                if (string.IsNullOrEmpty(formBody["endDate"]) == false)
                {
                    endDate = StringTools.GetDateOrFail("endDate", ref formBody, "Invalid end date.");
                    endDate = endDate.Value.AddDays(1); //need to add one day as time is midnight
                    hasEndDateBeenSet = true;
                }

                // Get the data
                var courseDetails = 
                    atlasDBViews.vwCourseDetails
                    .Where(
                        courseDetail => 
                            courseDetail.OrganisationId == organisationId && 
                            courseDetail.NumberOfBookedClients > 0 &&
                            ((hasStartDateBeenSet == false) || courseDetail.StartDate >= startDate) &&
                            ((hasEndDateBeenSet == false) || courseDetail.EndDate <= endDate) &&
                            ((hasCourseTypeIdBeenSet == false) || courseDetail.CourseTypeId == courseTypeId) &&
                            ((hasCourseTypeCategoryIdBeenSet == false) || courseDetail.CourseTypeCategoryId == courseTypeCategoryId)

                    )
                    .ToList();

                return courseDetails;
            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/GetCourseDates", ex);
                return false;
            }
        }

        [AuthorizationRequired]
        [Route("api/CourseAttendance/GetCourseTypesByOrganisationId/{OrganisationId}")]
        [HttpGet]
        public object GetCourseTypesByOrganisationId(int OrganisationId)
        {
            var courseTypes = atlasDB.CourseType
                .Where(
                    courseType => courseType.OrganisationId == OrganisationId
                )
                .Select(
                    courseType => new
                    {
                        courseType.Id,
                        courseType.Title
                    }
                )
                .ToList();

            return courseTypes;
        }

        [AuthorizationRequired]
        [Route("api/CourseAttendance/CourseClients")]
        [HttpPost]
        public object GetCourseClients([FromBody] FormDataCollection formBody)
        {
            try
            {
                // Get Org Id
                var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Please select an Organisation.");

                // Get Course Id
                var courseId = StringTools.GetIntOrFail("courseId", ref formBody, "Please select a course.");

                /// Get the clients associated to request
                var courseClients = atlasDBViews.vwCourseClients
                    .Where(
                        courseClient =>
                            courseClient.OrganisationId == organisationId &&
                            courseClient.CourseId == courseId
                    )
                    .OrderByDescending(course => course.SortColumn)
                    .ToList();

                // Get Trainers associated with course

                var courseTrainers = atlasDBViews.vwCourseTrainers
                    .Where(
                        courseTrainer =>
                            courseTrainer.OrganisationId == organisationId &&
                            courseTrainer.CourseId == courseId
                    )
                    .ToList();

                return new [] {
                    new {
                        Course = courseClients,
                        CourseTrainer = courseTrainers
                    }
                };
            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/GetCourseClients", ex);
                return false;
            }
        }

        [AuthorizationRequired]
        [Route("api/CourseAttendance/Trainer")]
        [HttpPost]
        public object GetTrainerAttendance([FromBody] FormDataCollection formBody)
        {
            try
            {
                // Get Org Id
                var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Please select an Organisation.");

                // Get Course Id
                var courseId = StringTools.GetIntOrFail("courseId", ref formBody, "Please select a course.");

                // Get Course Id
                var trainerId = StringTools.GetIntOrFail("trainerId", ref formBody, "Please select a trainer.");

                var trainerAttendance = atlasDBViews.vwCourseTrainerClientAttendances
                    .Where(
                        trainer =>
                            trainer.OrganisationId == organisationId &&
                            trainer.CourseId == courseId &&
                            trainer.TrainerId == trainerId
                    )
                    .OrderByDescending(theTrainer => theTrainer.SortColumn)
                    .ToList();

                return trainerAttendance;
            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/Trainer", ex);
                return false;
            }
        }

        [HttpGet]
        [Route("api/CourseAttendance/SetAttendanceCheckVerified/{CourseId}/{OrganisationId}")]
        public bool SetAttendanceCheckVerified(int courseId, int organisationId)
        {
            try
            {
                var updateCourse = new Course();
                updateCourse.Id = courseId;
                updateCourse.OrganisationId = organisationId;
                updateCourse.AttendanceCheckVerified = true;
                updateCourse.DateUpdated = DateTime.Now;

                atlasDB.Course.Attach(updateCourse);
                atlasDB.Entry(updateCourse).Property("AttendanceCheckVerified").IsModified = true;
                atlasDB.Entry(updateCourse).Property("DateUpdated").IsModified = true;

                atlasDB.SaveChanges();

                return true;
            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/SetAttendanceCheckVerified", ex);
                return false;
            }
        }


        [HttpGet]
        [Route("api/CourseAttendance/SetClientAttendance/{CourseId}/{ClientId}/{UserId}")]
        public bool SetClientAttendance(int courseId, int clientId, int userId)

        {
            try
            {
                
                atlasDB.uspCourseToggleClientAttendance(courseId, clientId, userId);
                    
                return true;
                   
            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/SetClientAttendance", ex);
                return false;
            }
        }

        [HttpGet]
        [Route("api/CourseAttendance/SetCourseAttendanceAbsentToAll/{CourseId}/{UserId}")]
        public bool SetCourseAttendanceAbsentToAll(int courseId, int userId)

        {
            try
            {

                atlasDB.uspCourseClientAttendanceMarkAllAbsent(courseId, userId);

                return true;

            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/SetCourseAttendanceAbsentToAll", ex);
                return false;
            }
        }

        [HttpGet]
        [Route("api/CourseAttendance/SetCourseAttendancePresentToAll/{CourseId}/{UserId}")]
        public bool SetCourseAttendancePresentToAll(int courseId, int userId)

        {
            try
            {

                atlasDB.uspCourseClientAttendanceMarkAllPresent(courseId, userId);

                return true;

            }
            catch (Exception ex)
            {
                LogError("CourseAttendance/SetCourseAttendancePresentToAll", ex);
                return false;
            }
        }

        /// <summary>
        /// This function removes duplicate entries that are in the DORSClientCourseAttendanceLog to remove the client from 
        /// the meter
        /// </summary>
        /// <param name="courseId"></param>
        /// <param name="clientId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("api/CourseAttendance/ClearDORSClientCourseAttendanceLog/{dorsCourseIdentifier}/{dorsClientIdentifier}/{userId}/{organisationId}")]
        public bool ClearDORSClientCourseAttendanceLog(int dorsCourseIdentifier, int dorsClientIdentifier, int userId, int organisationId)
        {
            var cleared = false;
            if(UserHasOrganisationAdminStatus(userId, organisationId) || UserHasSystemAdminStatus(userId))
            {
                try
                {
                    var attendanceLogs = atlasDB.DORSClientCourseAttendanceLogs
                                                .Where(
                                                    dccal => dccal.DORSClientIdentifier == dorsClientIdentifier &&
                                                    dccal.DORSCourseIdentifier == dorsCourseIdentifier
                                                )
                                                .ToList();
                    var attendedElementExists = attendanceLogs.Where(al => al.DORSNotified).Count() > 0;
                    var attendedElementLeft = false;

                    if(attendanceLogs.Count > 1)    // leave one record, remove duplicates
                    {
                        for(int i = 0; i < attendanceLogs.Count; i++)
                        {
                            if (attendedElementExists)
                            {
                                if(attendanceLogs[i].DORSNotified && (attendedElementLeft == false))
                                {
                                    // leave this element
                                    attendedElementLeft = true;
                                }
                                else
                                {
                                    // remove the duplicate entries
                                    var entry = atlasDB.Entry(attendanceLogs[i]);
                                    entry.State = System.Data.Entity.EntityState.Deleted;
                                }
                            }
                            else
                            {
                                if (i > 0)  // leave the first entry
                                {
                                    // remove the duplicate entries
                                    var entry = atlasDB.Entry(attendanceLogs[i]);
                                    entry.State = System.Data.Entity.EntityState.Deleted;
                                }
                            }
                        }
                    }
                    cleared = true;
                }
                catch(Exception ex)
                {
                    LogError("ClearDORSClientCourseAttendanceLog " + getSystemName(), ex);
                }
                finally
                {
                    atlasDB.SaveChanges();
                }
            }
            
            return cleared;
        }

        /// <summary>
        /// Used by the NotifyNewCourseClients scheduled task to set the course attendance as being set
        /// </summary>
        /// <param name="dorsCourseIdentifier"></param>
        /// <param name="dorsClientIdentifier"></param>
        /// <param name="userId"></param>
        /// <param name="organisationId"></param>
        /// <returns></returns>
        public bool SetDORSClientCourseAttendanceLog(int dorsCourseIdentifier, int dorsClientIdentifier, int userId, int organisationId)
        {
            var attendanceLogSet = false;
            var clearedDuplicates = ClearDORSClientCourseAttendanceLog(dorsCourseIdentifier, dorsClientIdentifier, userId, organisationId);
            if (clearedDuplicates)
            {
                var attendanceLog = atlasDB.DORSClientCourseAttendanceLogs
                                                .Where(
                                                    dccal => dccal.DORSClientIdentifier == dorsClientIdentifier &&
                                                    dccal.DORSCourseIdentifier == dorsCourseIdentifier
                                                )
                                                .FirstOrDefault();
                if (attendanceLog == null)
                {
                    attendanceLog = new DORSClientCourseAttendanceLog();
                    attendanceLog.DateCreated = DateTime.Now;
                    attendanceLog.DORSClientIdentifier = dorsClientIdentifier;
                    attendanceLog.DORSCourseIdentifier = dorsCourseIdentifier;
                }
                attendanceLog.DORSNotified = true;
                attendanceLog.DateLastAttempted = DateTime.Now;
                
                var entry = atlasDB.Entry(attendanceLog);
                entry.State = System.Data.Entity.EntityState.Modified;
                atlasDB.SaveChanges();
                attendanceLogSet = true;
            }
            return attendanceLogSet;
        }
    }
}