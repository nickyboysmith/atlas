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
//using System.Globalization;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class TrainerBookingsController : AtlasBaseController
    {
        
        [Route("api/TrainerBookings/GetSelected")]
        [HttpPost]
        public object GetTrainerBookings([FromBody] FormDataCollection formBody)
        {
            var dateType = formBody["type"];
            var dateName = formBody["name"];
            var formDateValue = formBody["date"];

            DateTime dateValue;

            var startDate = DateTime.Now;
            var endDate = DateTime.Now;

            var trainerId = 0;
            var organisationId = 0;

            if (Int32.TryParse(formBody["trainerId"], out trainerId))
            {
            }
            else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a trainer"),
                        ReasonPhrase = "No associated trainer was specified"
                    }
                );
            }



            if (Int32.TryParse(formBody["organisationId"], out organisationId)) {
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter an organisation"),
                        ReasonPhrase = "No organisation was associated with this trainer"
                    }
                );
            }

            // Check to see if there is a date type
            if (string.IsNullOrEmpty(dateType))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a date type"),
                        ReasonPhrase = "No date type specified"
                    }
                );
            }

            // Check the date value
            if (string.IsNullOrEmpty(formDateValue))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a date value"),
                        ReasonPhrase = "No date value specified"
                    }
                );
            }
            else
            {
                dateValue = (DateTime)StringTools.GetDate("date", ref formBody);
            }

            // check to see if there is a date name
            if (string.IsNullOrEmpty(dateName))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a date name"),
                        ReasonPhrase = "No date name specified"
                    }
                );
            }

            // Check that the type is either: day/month/year
            string[] dateTypeList = {"day", "month", "year"};
            if (!dateTypeList.Contains(dateType))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Please enter a valid date type"),
                        ReasonPhrase = "Invalid date type specified"
                    }
                );
            }

            // Get days the start and end time
            // For a day
            if (dateType == "day")
            {
                //startDate = DateTime.Parse(dateValue);
                startDate = dateValue;
                endDate = startDate.AddDays(1).AddMilliseconds(-1);
               
               
            }

            // Get days the start and end time
            // For a month
            if (dateType == "month")
            {
                startDate = dateValue;
                //startDate = DateTime.Parse(dateValue);
                endDate = startDate.AddMonths(1).AddMilliseconds(-1);
            }

            // Get days the start and end time
            // For a year
            if (dateType == "year")
            {
                startDate = dateValue;
                //startDate = DateTime.Parse(dateValue);
                endDate = startDate.AddYears(1).AddMilliseconds(-1);
            }


            var courseBookings = atlasDB.CourseTrainer
                .Include("Course")
                .Include("Course.CourseDate")
                .Where(
                    trainer =>
                        trainer.TrainerId == trainerId && 
                        trainer.Course.OrganisationId == organisationId
                )
                .Where(
                    trainer =>
                        (
                            (
                                trainer.Course.CourseDate.FirstOrDefault().DateStart >= startDate &&
                                trainer.Course.CourseDate.FirstOrDefault().DateStart <= endDate
                            )
                            ||
                            (
                                trainer.Course.CourseDate.FirstOrDefault().DateEnd >= startDate &&
                                trainer.Course.CourseDate.FirstOrDefault().DateEnd <= endDate
                            )
                        )
                )
                //.Where(
                //    organisation => organisation.Trainer.TrainerOrganisation.Any(
                //        trainerOrg => trainerOrg.OrganisationId == organisationId
                //    )
                //)
                .Select(
                    courseTrainer => new
                    {
                        Id = courseTrainer.CourseId,
                        StartDate = courseTrainer.Course.CourseDate.FirstOrDefault().DateStart,
                        StartTime = courseTrainer.Course.DefaultStartTime,
                        EndDate = courseTrainer.Course.CourseDate.FirstOrDefault().DateEnd,
                        EndTime = courseTrainer.Course.DefaultEndTime,
                        Reference = courseTrainer.Course.Reference,
                        CourseRegisterDocumentId = courseTrainer.Course.CourseRegisterDocumentId,
                        CourseAttendanceSignInDocumentId = courseTrainer.Course.CourseAttendanceSignInDocumentId,
                        OrganisationName = courseTrainer.Course.Organisation.Name,
                        MaxPlaces = 
                            courseTrainer.Course.CourseVenue.FirstOrDefault().MaximumPlaces != null 
                            ? courseTrainer.Course.CourseVenue.FirstOrDefault().MaximumPlaces
                            : 0,
                        BookedPlaces = 
                            courseTrainer.Course.CourseVenue.FirstOrDefault().ReservedPlaces != null 
                            ? courseTrainer.Course.CourseVenue.FirstOrDefault().ReservedPlaces
                            : 0,
                        Venue = courseTrainer.Course.CourseVenue.FirstOrDefault().Venue.Title,
                        CourseType = courseTrainer.Course.CourseType.Title,
                        CourseNotes = courseTrainer.Course.CourseNote.Where(cn => cn.OrganisationOnly == false)
                        .Select(
                            courseNote => new
                            {
                                Type = courseNote.CourseNoteType.Title,
                                Text = courseNote.Note,
                                Date = courseNote.DateCreated,
                                User = courseNote.User.Name
                            }    
                        ).OrderByDescending(
                            courseDate => courseDate.Date
                        ),
                        CourseTrainers = courseTrainer.Course.CourseTrainer
                        .Where(
                            theTrainer => theTrainer.TrainerId != trainerId
                        )
                        .Select(
                            theCourseTrainers => new
                            {
                                Name = theCourseTrainers.Trainer.DisplayName
                            }
                        )
                    })
                    .OrderBy(x => x.StartDate)
                    .ToList();

            return courseBookings;
        }

       
        [AuthorizationRequired]
        [Route("api/TrainerBookings/getCourseBookingsByOrganisationTrainer/{OrganisationId}/{TrainerId}")]
        [HttpGet]
        public object getCourseBookingsByOrganisationTrainer(int OrganisationId ,int TrainerId)
        {

            DateTime LastWeek = DateTime.Now.AddDays(-7);

            try
            {
                return atlasDBViews
                    .vwTrainerAllocatedCourses
                    .Where(
                        tac => tac.TrainerId == TrainerId 
                                && tac.CourseOrganisationId == OrganisationId 
                                    && tac.EndDate >= LastWeek)
                    .Select(
                        bookedCourses => new
                        {
                            bookedCourses.StartDate,
                            bookedCourses.CourseTypeCategory,
                            bookedCourses.VenueTitle,
                            bookedCourses.NumberOfBookedClients
                        }
                    )
                    .ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/TrainerBookings/DownloadCourseRegister/{UserId}/{CourseRegisterDocumentId}")]
        public HttpResponseMessage DownloadCourseRegister(int UserId, int CourseRegisterDocumentId)
        {
            var documentController = new DocumentController();
            HttpResponseMessage response = null;
            var courseRegister = atlasDB.Documents
                                        .Where(d => d.Id == CourseRegisterDocumentId);

            if (courseRegister != null)
            {
                response = documentController.DownloadFileContents(CourseRegisterDocumentId, UserId);
            }
            return response;
        }

    }
}