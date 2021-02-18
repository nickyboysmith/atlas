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
using System.Data.Entity.Validation;
using System.Globalization;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class TrainerAttendanceController : AtlasBaseController
    {


        [AuthorizationRequired]
        [Route("api/TrainerAttendance/GetCourses")]
        [HttpPost]
        public object GetCourseDatesTimes([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            //var courseDate = StringTools.GetDate("date", ref formData);
            var courseDate = StringTools.GetString("date", ref formData);

            var trainerId = 0;
            var organisationId = 0;
            var userId = 0;


            // Check the Trainer Id
            if (Int32.TryParse(formBody["trainerId"], out trainerId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a trainer"),
                        ReasonPhrase = "No associated trainer was specified"
                    }
                );
            }

            // Check the Org Id
            if (Int32.TryParse(formBody["organisationId"], out organisationId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter an organisation"),
                        ReasonPhrase = "An organisation has not been associated with this request"
                    }
                );
            }

            // Check the User Id
            if (Int32.TryParse(formBody["userId"], out userId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please associate a user"),
                        ReasonPhrase = "An user has not been associated with this request"
                    }
                );
            }




            var attend = GetAttendance(trainerId, organisationId, userId, courseDate);

            return attend;
        }

        [AuthorizationRequired]
        // POST api/TrainerAttendance
        public object Post([FromBody] FormDataCollection formBody)
        {

            var trainerId = 0;
            var organisationId = 0;
            var userId = 0;
            var courseDateId = 0;
            var courseId = 0;
            var attendanceUpdated = StringTools.GetBool("AttendanceUpdated", ref formBody);

            // Check the Trainer Id
            if (Int32.TryParse(formBody["trainerId"], out trainerId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a trainer"),
                        ReasonPhrase = "No associated trainer was specified"
                    }
                );
            }

            // Check the Org Id
            if (Int32.TryParse(formBody["organisationId"], out organisationId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter an organisation"),
                        ReasonPhrase = "An organisation has not been associated with this request"
                    }
                );
            }

            // Check the User Id
            if (Int32.TryParse(formBody["userId"], out userId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please associate a user"),
                        ReasonPhrase = "An user has not been associated with this request"
                    }
                );
            }

            // Check the Course Date Id
            if (Int32.TryParse(formBody["CourseDateId"], out courseDateId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please specify a Course Date"),
                        ReasonPhrase = "A Course Date has not been associated with this request"
                    }
                );
            }

            // Check the Course Id
            if (Int32.TryParse(formBody["CourseId"], out courseId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please specify a Course"),
                        ReasonPhrase = "An Course has not been associated with this request"
                    }
                );
            }

            // Get the trainer count
            var trainerListCount = ArrayTools.ArrayLength("TrainerList", ref formBody);
            var clientListCount = ArrayTools.ArrayLength("ClientList", ref formBody);
            var courseDateClientAttendances = atlasDB.CourseDateClientAttendances.Where(cdca => cdca.CourseId == courseId).ToList();

            try
            {
                // Loop through client List
                for (int i = 0; i < clientListCount; i++)
                {
                    atlasDB.SaveChanges();
                    var clientId = StringTools.GetInt("ClientList[" + i + "][ClientId]", ref formBody);
                    var clientAttendanceId = StringTools.GetInt("ClientList[" + i + "][ClientAttendanceId]", ref formBody);
                    var didClientAttend = StringTools.GetBool("ClientList[" + i + "][DidClientAttend]", ref formBody);

                    var clientAttendanceRecord = courseDateClientAttendances.Where(c => c.TrainerId == trainerId && c.ClientId == clientId).FirstOrDefault();

                    // If the Client Attendance hasn't been filled out
                    // Then just add it to the row
                    if (clientAttendanceRecord == null && didClientAttend == true)
                    {
                        var clientAttendance = new CourseDateClientAttendance();
                        clientAttendance.CourseDateId = courseDateId;
                        clientAttendance.CourseId = courseId;
                        clientAttendance.ClientId = clientId;
                        clientAttendance.TrainerId = trainerId;
                        clientAttendance.CreatedByUserId = userId;
                        clientAttendance.DateTimeAdded = DateTime.Now;

                        // Add to the DB
                        atlasDB.CourseDateClientAttendances.Add(clientAttendance);
                    }
                    // If the client has an attendance Id then remove them 
                    // From the 'CourseDateClientAttendance' table
                    // Only if 'didClientAttend' is set to false
                    else if (clientAttendanceRecord != null && didClientAttend == false && clientAttendanceRecord.TrainerId == trainerId)
                    {
                        atlasDB.CourseDateClientAttendances.Remove(clientAttendanceRecord);
                        atlasDB.SaveChanges();
                    }
                }

                // Loop through trainer List
                for (int i = 0; i < trainerListCount; i++)
                {
                    var theTrainerId = StringTools.GetInt("TrainerList[" + i + "][TrainerId]", ref formBody);
                    var trainerAttendanceId = StringTools.GetInt("TrainerList[" + i + "][TrainerAttendanceId]", ref formBody);
                    var isTrainerAttending = StringTools.GetBool("TrainerList[" + i + "][IsTrainerAttending]", ref formBody);

                    // If the Trainer Attenendance is 0
                    // Then Add the row
                    if (trainerAttendanceId == 0 && isTrainerAttending == true)
                    {
                        var trainerAttendance = new CourseDateTrainerAttendance();
                        trainerAttendance.CourseDateId = courseDateId;
                        trainerAttendance.CourseId = courseId;
                        trainerAttendance.TrainerId = theTrainerId;
                        trainerAttendance.CreatedByUserId = userId;
                        trainerAttendance.DateTimeAdded = DateTime.Now;

                        // Add to the DB
                        atlasDB.CourseDateTrainerAttendances.Add(trainerAttendance);
                    }

                    // If the Trainer Attendance isnt 0
                    // And the Trainer ['isAttending'] is set to false
                    // remove the record from the table
                    else if (trainerAttendanceId != 0 && isTrainerAttending == false)
                    {
                        var trainerAttendanceRecord = atlasDB.CourseDateTrainerAttendances.Find(trainerAttendanceId);
                        atlasDB.CourseDateTrainerAttendances.Remove(trainerAttendanceRecord);
                    }
                }

                var theCourseDate = atlasDB.CourseDate.Find(courseDateId);
                if (theCourseDate.AttendanceUpdated == null || theCourseDate.AttendanceUpdated == false)
                {
                    theCourseDate.AttendanceUpdated = true;
                    theCourseDate.DateUpdated = DateTime.Now;
                    atlasDB.CourseDate.Attach(theCourseDate);
                    var courseDateEntry = atlasDB.Entry(theCourseDate);
                    courseDateEntry.State = System.Data.Entity.EntityState.Modified;
                }


                atlasDB.SaveChanges();

                var startDate = "";
                if (theCourseDate.DateStart != null) startDate = ((DateTime)theCourseDate.DateStart).ToString("dd-MMM-yyyy");

                return GetAttendance(trainerId, organisationId, userId, startDate);
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("Something has gone wrong on our end"),
                        ReasonPhrase = "We're currently experiencing difficulties"
                    }
                );
            }

        }

        private object GetAttendance(int trainerId, int organisationId, int userId, string date)
        {
            object attendance;
            var theCourseSearchDateStart = DateTime.Now;
            var theCourseSearchDateEnd = DateTime.Now;

            // Check the date is the correct format
            if (DateTime.TryParseExact(date, "dd-MMM-yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out theCourseSearchDateStart))
            {
                theCourseSearchDateStart = theCourseSearchDateStart.Date;
                theCourseSearchDateEnd = theCourseSearchDateStart.AddDays(1).AddMilliseconds(-1);
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Incorrect Date Format"),
                        ReasonPhrase = "The date format is incorrect."
                    }
                );
            }

            try
            {

                attendance = atlasDB.CourseDate
                    .Include("Course")
                    .Include("Course.CourseType")
                    .Include("Course.CourseTypeCategory")
                    .Where(
                        courseDate =>
                            courseDate.DateStart >= theCourseSearchDateStart
                            && courseDate.DateStart <= theCourseSearchDateEnd
                    )
                    .Where(
                        courseDate => courseDate.Course.CourseTrainer.Any(
                            courseTrainer => courseTrainer.TrainerId == trainerId
                        )
                    )
                    .Where(
                        courseOrganisation => courseOrganisation.Course.OrganisationId == organisationId
                    )
                    .Select(course => new
                    {
                        CourseDateId = course.Id,
                        CourseTypeId = course.Course.CourseType.Id,
                        CourseTypeName = course.Course.CourseType.Title,
                        CourseTypeCategoryName = course.Course.CourseTypeCategory.Name,
                        Course = course.Course.CourseDate.Select(
                            theCourseStartDate => new
                            {
                                CourseDateId = course.Id,
                                theCourseStartDate.Course.Reference,
                                Venue = theCourseStartDate.Course.CourseVenue.Select(
                                    theVenue => new
                                    {
                                        Name = theVenue.Venue.Title,
                                        MaxPlaces = theVenue.MaximumPlaces,
                                        Booked = theVenue.ReservedPlaces
                                    }),

                                StartTime = theCourseStartDate.Course.DefaultStartTime,
                                StartDate = theCourseStartDate.DateStart,
                                theCourseStartDate.CourseId,
                                AttendanceUpdated = theCourseStartDate.AttendanceUpdated,

                                TrainerList = theCourseStartDate.Course.CourseTrainer
                                    .Where(
                                        courseTrainer => courseTrainer.TrainerId == trainerId
                                    )
                                    .Select(courseTrainer => new
                                    {
                                        courseTrainer.TrainerId,
                                        courseTrainer.Trainer.DisplayName,
                                        IsTrainerAttending = courseTrainer.Trainer.CourseDateTrainerAttendances.Any(),
                                        TrainerAttendanceId =
                                            (courseTrainer.Trainer.CourseDateTrainerAttendances.FirstOrDefault().Id == null)
                                            ? 0
                                            : courseTrainer.Trainer.CourseDateTrainerAttendances.FirstOrDefault().Id
                                    }),
                                ClientList = theCourseStartDate.Course.CourseClients
                                                                    .Where(cc => cc.CourseClientRemoveds.Count() == 0)
                                                                    .Select(
                                    theCourseClient => new
                                    {
                                        ClientId = theCourseClient.ClientId,
                                        ClientDisplayName = theCourseClient.Client.DisplayName,
                                        Licence = theCourseClient.Client.ClientLicences.Select(
                                            theLicence => new
                                            {
                                                Number = theLicence.LicenceNumber
                                            }
                                        ),
                                        //DidClientAttend = theCourseClient.Client.CourseDateClientAttendances.Where(cdca => cdca.TrainerId == trainerId),
                                        DidClientAttend = theCourseClient.Client.CourseDateClientAttendances.Where(cdca => cdca.TrainerId == trainerId).Any(),
                                        ClientAttendanceId =
                                            (theCourseClient.Client.CourseDateClientAttendances.FirstOrDefault().Id == null)
                                            ? 0
                                            : theCourseClient.Client.CourseDateClientAttendances.FirstOrDefault().Id
                                    })
                            }
                        )
                    })
                    .ToList();


            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("Something has gone wrong on our end"),
                        ReasonPhrase = "We're currently experiencing difficulties"
                    }
                );
            }
            return attendance;
        }

    }
}