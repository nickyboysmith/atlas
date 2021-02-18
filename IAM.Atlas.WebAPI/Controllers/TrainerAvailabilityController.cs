using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity;
using IAM.Atlas.WebAPI.Models;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class TrainerAvailabilityController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/traineravailability/available/{TrainerId}")]
        [HttpGet]
        // GET api/<controller>
        public object GetAvailableWeekdays(int TrainerId)
        {
            return atlasDB.TrainerWeekDaysAvailables
                .Where(available =>
                    available.TrainerId == TrainerId
                    && available.Removed == false
                )
                .Select(available => new {
                    Id = available.Id,
                    WeekDayNumber = available.WeekDayNumber
                })
                .ToList();
        }

        [AuthorizationRequired]
        [Route("api/traineravailability/unavailable/{TrainerId}/{ShowPastDates}")]
        [HttpGet]
        // GET api/<controller>
        public object GetUnavailableDays(int TrainerId, int ShowPastDates)
        {

            var today = DateTime.Now;
            var startOfDay = today.Date;
            var recentDate = startOfDay.AddDays(-14);

            return atlasDB.TrainerDatesUnavailables
                .Where(available =>
                    ((ShowPastDates == 1) || available.StartDate >= recentDate) &&
                    available.TrainerId == TrainerId
                    && available.Removed == false
                )
                .Select(unAvailable => new {
                    Id = unAvailable.Id,
                    StartDate = unAvailable.StartDate,
                    EndDate = unAvailable.EndDate,
                    AllDay = unAvailable.AllDay,
                    TimeStart = unAvailable.StartTime,
                    TimeEnd = unAvailable.EndTime
                })
                .OrderByDescending(unAvailable => unAvailable.StartDate)
                .ToList();
        }

        [AuthorizationRequired]
        [Route("api/traineravailability/selectedcoursetypes/{TrainerId}/{OrganisationId}")]
        [HttpGet]
        public List<DragDropUpdateJSON> GetSelectedCourseTypes(int TrainerId, int OrganisationId)
        {
            // the expandedCourseTypeList has split 'theory and practical' course types into two entries
            var courseTypeList = new List<DragDropUpdateJSON>();
            var trainerCourseTypes = atlasDB.TrainerCourseType
                                            .Include(tct => tct.CourseType)
                                            .Where(tct => tct.TrainerId == TrainerId && tct.CourseType.OrganisationId == OrganisationId)
                                            .ToList();
            foreach(var trainerCourseType in trainerCourseTypes)
            {
                if (trainerCourseType.ForPractical)
                {
                    courseTypeList.Add(new DragDropUpdateJSON(trainerCourseType.CourseTypeId, trainerCourseType.CourseType.Title + " (Practical)"));
                }
                if (trainerCourseType.ForTheory)
                {
                    courseTypeList.Add(new DragDropUpdateJSON(trainerCourseType.CourseTypeId, trainerCourseType.CourseType.Title + " (Theory)"));
                }
                else if (!trainerCourseType.ForPractical && !trainerCourseType.ForTheory)
                {
                    courseTypeList.Add(new DragDropUpdateJSON(trainerCourseType.CourseTypeId, trainerCourseType.CourseType.Title));
                }
            }
            return courseTypeList;
        }

        [AuthorizationRequired]
        [Route("api/traineravailability/availablecoursetypes/{OrganisationId}/{TrainerId}")]
        [HttpGet]
        public List<DragDropUpdateJSON> GetAvailableCourseTypes(int OrganisationId, int TrainerId)
        {
            // the expandedCourseTypeList has split 'theory and practical' course types into two entries
            var courseTypeList = new List<DragDropUpdateJSON>();
            var availableCourseTypes = atlasDB.CourseType
                                                .Include(ct => ct.TrainerCourseType)
                                                .Where(ct =>    (!ct.TrainerCourseType.Any(tct => tct.TrainerId == TrainerId) || 
                                                                (
                                                                    ct.TrainerCourseType.Any(tct => tct.TrainerId == TrainerId) && 
                                                                    (ct.TrainerCourseType.Any(tct => tct.ForTheory == false) || ct.TrainerCourseType.Any(tct => tct.ForPractical == false)))
                                                                ) && 
                                                                ct.OrganisationId == OrganisationId)
                                                .ToList();
            // find the courses that are both theory and practical and split them up into two separate DragDropUpdateJSON entries
            foreach (var courseType in availableCourseTypes)
            {
                if(courseType.TrainerCourseType.Any(tct => tct.TrainerId == TrainerId))
                {
                    // if it isn't forPractical == false and ForTheory == false combined (This would be a course type that wasn't practical or theoretical)
                    if(!(courseType.TrainerCourseType.Any(tct => tct.ForPractical == false) && courseType.TrainerCourseType.Any(tct => tct.ForTheory == false)))
                    {
                        // this trainer isn't down to do this course type for practical courses
                        if (courseType.TrainerCourseType.Any(tct => tct.ForPractical == false))
                        {
                            courseTypeList.Add(new DragDropUpdateJSON(courseType.Id, courseType.Title + " (Practical)"));
                        }
                        if (courseType.TrainerCourseType.Any(tct => tct.ForTheory == false))
                        {
                            courseTypeList.Add(new DragDropUpdateJSON(courseType.Id, courseType.Title + " (Theory)"));
                        }
                    }
                }
                else
                {
                    if(courseType.MinPracticalTrainers > 0)
                    {
                        courseTypeList.Add(new DragDropUpdateJSON(courseType.Id, courseType.Title + " (Practical)"));
                    }
                    if (courseType.MinTheoryTrainers > 0)
                    {
                        courseTypeList.Add(new DragDropUpdateJSON(courseType.Id, courseType.Title + " (Theory)"));
                    }
                }
            }
            return courseTypeList;
        }

        [AuthorizationRequired]
        [Route("api/traineravailability/courses/{TrainerId}/{ShowPastDates}")]
        [HttpGet]
        public object GetBookedCourses(int TrainerId, int ShowPastDates)
        {

            var today = DateTime.Now;
            var startOfDay = today.Date;
            var recentDate = startOfDay.AddDays(-14);

            return atlasDB.CourseTrainer
                .Include("Course")
                .Include("Course.CourseType")
                .Include("Course.CourseTypeCategory")
                .Include("Course.CourseDate")
                .Where(
                    courseTrainer =>
                    ((ShowPastDates == 1) || courseTrainer.Course.CourseDate.FirstOrDefault().DateStart >= recentDate) &&
                    courseTrainer.TrainerId == TrainerId
                )
                .Select(courseTrainer => new {
                    Id = courseTrainer.Id,
                    CourseId = courseTrainer.CourseId,
                    CourseType = courseTrainer.Course.CourseType.Title,
                    CourseTypeCategory = courseTrainer.Course.CourseTypeCategory.Name,
                    StartDate = courseTrainer.Course.CourseDate.FirstOrDefault().DateStart,
                    EndDate = courseTrainer.Course.CourseDate.FirstOrDefault().DateEnd
                })
                .ToList();
        }


        [Route("api/traineravailability/weekdays")]
        [HttpPost]
        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formParams)
        {
            var theWeekDayNumber = 0;
            var userId          = 0;
            var trainerId       = 0;
            var webApiID        = 0;


            if (int.TryParse(formParams["Id"], out theWeekDayNumber))
            {
                // return "no weekday number";
            }

            if (int.TryParse(formParams["userId"], out userId))
            {
                // return "no associated user";
            }

            if (int.TryParse(formParams["trainerId"], out trainerId))
            {
                // return "no associated trainer";
            }

            try
            {

                TrainerWeekDaysAvailable trainerWeekDay = new TrainerWeekDaysAvailable();
                trainerWeekDay.TrainerId = trainerId;
                trainerWeekDay.UpdatedByUserId = userId;
                trainerWeekDay.DateCreated = DateTime.Now;

                // If the wepApiID is empty 
                if (string.IsNullOrEmpty(formParams["WebApiID"]))
                {
                    trainerWeekDay.WeekDayNumber = theWeekDayNumber;
                    trainerWeekDay.Removed = false;
                    atlasDB.TrainerWeekDaysAvailables.Add(trainerWeekDay);
                }

                // If the wepApiID isnot empty 
                if (!string.IsNullOrEmpty(formParams["WebApiID"]))
                {
                    // try parse the webApiID
                    if (int.TryParse(formParams["WebApiID"], out webApiID))
                    {
                        // return "no associated trainer";
                    }


                    // If the user is removing the day
                    // Just update the Removed flag to true
                    if (formParams["isChecked"] == "true")
                    {
                        trainerWeekDay.Id = webApiID;
                        trainerWeekDay.Removed = true;
                        trainerWeekDay.WeekDayNumber = theWeekDayNumber;
                        atlasDB.TrainerWeekDaysAvailables.Attach(trainerWeekDay);
                        var trainerWeekDaysEntry = atlasDB.Entry(trainerWeekDay);
                        trainerWeekDaysEntry.State = System.Data.Entity.EntityState.Modified;
                    }

                    // If the user is adding the day
                    // Add an new record in the db
                    if (formParams["isChecked"] == "false")
                    {
                        trainerWeekDay.WeekDayNumber = theWeekDayNumber;
                        trainerWeekDay.Removed = false;
                        atlasDB.TrainerWeekDaysAvailables.Add(trainerWeekDay);
                    }


                }

                atlasDB.SaveChanges();

                return "success";

            } catch (DbEntityValidationException ex) {

                return "There has been an error saving your details";

            }


        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }

        [HttpPost]
        [Route("api/traineravailability/saveUnavailability")]
        public void SaveUnavailability([FromBody] FormDataCollection formParams)
        {
            var formData = formParams;
            var unavailability = new TrainerDatesUnavailable();
            unavailability.StartDate = StringTools.GetDate("StartDate", "dd/MM/yyyy", ref formData);
            unavailability.EndDate = StringTools.GetDate("EndDate", "dd/MM/yyyy", ref formData);
            unavailability.AllDay = StringTools.GetBool("AllDay", ref formData);
            unavailability.StartTime = StringTools.GetTime("StartTime", unavailability.StartDate, ref formData);
            unavailability.EndTime = StringTools.GetTime("EndTime", unavailability.EndDate, ref formData);
            unavailability.TrainerId = StringTools.GetInt("TrainerId", ref formData);
            unavailability.UpdatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);
            unavailability.Removed = StringTools.GetBool("Removed", ref formData);
            unavailability.DateUpdated = DateTime.Now;

            atlasDB.TrainerDatesUnavailables.Add(unavailability);
            atlasDB.SaveChanges();
        }

        [HttpGet]
        [Route("api/traineravailability/removeUnavailability/{unavailabilityId}/{userId}")]
        public void RemoveUnavailability(int unavailabilityId, int userId)
        {
            var unavailability = atlasDB.TrainerDatesUnavailables.Where(unavailable => unavailable.Id == unavailabilityId).FirstOrDefault();
            if(unavailability != null)
            {
                unavailability.Removed = true;
                unavailability.DateUpdated = DateTime.Now;
                unavailability.UpdatedByUserId = userId;
                atlasDB.SaveChanges();
            }
        }

        [Route("api/traineravailability/getAvailabilityByMonth/{TrainerId}/{Month}/{Year}")]
        public List<vwTrainerSessionAvailabilityByMonth> GetAvailabilityByMonth(int TrainerId, int Month, int Year)
        {
            var availabilityCalendar = atlasDBViews.vwTrainerSessionAvailabilityByMonths
                                                .Where(a => a.TheMonth == Month &&
                                                            a.TheYear == Year &&
                                                            a.TrainerId == TrainerId)
                                                .OrderBy(a => a.DateRowNumber)
                                                .ToList();
            return availabilityCalendar;
        }

        [Route("api/traineravailability/UpdateAvailability/{TrainerId}/{Available}/{Date}/{SessionNumber}")]
        [HttpGet]
        [AuthorizationRequired]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="available"></param>
        /// <param name="date"></param>
        /// <param name="sessionNumber">1 = AM session, 2 = PM session, 3 = evening session</param>
        /// <returns></returns>
        public bool UpdateAvailability(int TrainerId, bool Available, DateTime Date, int SessionNumber)
        {
            var updated = false;
            if (Available)
            {
                var trainerAvailabilityDate = new TrainerAvailabilityDate();
                trainerAvailabilityDate.TrainerId = TrainerId;
                trainerAvailabilityDate.Date = Date;
                trainerAvailabilityDate.SessionNumber = SessionNumber;

                atlasDB.TrainerAvailabilityDates.Add(trainerAvailabilityDate);
                atlasDB.SaveChanges();
                updated = true;
            }
            else
            {
                var trainerAvailabilityDate = atlasDB.TrainerAvailabilityDates
                                                        .Where(
                                                            tad => tad.TrainerId == TrainerId &&
                                                                    tad.SessionNumber == SessionNumber &&
                                                                    tad.Date == Date
                                                        )
                                                        .FirstOrDefault();
                if(trainerAvailabilityDate != null)
                {
                    var entry = atlasDB.Entry(trainerAvailabilityDate);
                    entry.State = EntityState.Deleted;
                    atlasDB.SaveChanges();
                    updated = true;
                }
            }
            return updated;
        }
    }
}