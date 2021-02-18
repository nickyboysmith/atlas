using IAM.Atlas.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseTrainerController : AtlasBaseController
    {
        string nonDORSCourseMessage = "Not a DORS Course.";

        // GET api/<controller>/5
        public string Get()
        {
            return "value";
        }
        
        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formBody)   
        {

            var courseId = 0;
            var trainerId = 0;
            var userId = 0;
            var bookedSessionNumber = 0;


            // Try parse the SessionNumber
            if (Int32.TryParse(formBody["bookedSessionNumber"], out bookedSessionNumber))
            {
            }
            else
            {
                //return "There was an error verifying your course. Please retry.";
            }

            // Try parse the CourseId
            if (Int32.TryParse(formBody["courseId"], out courseId)) {
            } else {
                return "There was an error verifying your course. Please retry.";
            }

            // Try parse the TrainerId
            if (Int32.TryParse(formBody["trainerId"], out trainerId)) {
            } else {
                return "There was an error verifying the trainer. Please retry.";
            }

            // Try parse the UserId
            if (Int32.TryParse(formBody["userId"], out userId)) {
            } else {
                return "There was an error verifying the user. Please retry.";
            }

            var checkTrainerExists = atlasDB.Trainer.Any(theTrainer => theTrainer.Id == trainerId);
            if (!checkTrainerExists) {
                return "There was an error verifying the trainer. Please retry.";
            }

            var checkCourseExists = atlasDB.Course.Any(theCourse => theCourse.Id == courseId);
            if (!checkCourseExists) {
                return "There was an error verifying your the course. Please retry.";
            }

            //var theCourseTrainer =
            //    atlasDB.CourseTrainer.Where(
            //        theTrainer =>
            //            theTrainer.CourseId == courseId
            //            && theTrainer.TrainerId == trainerId
            //    ).FirstOrDefault();

            // TO DO : Logic here to determine the criteria for an update.
            var theCourseTrainer =
                atlasDB.CourseTrainer.Where(
                    theTrainer =>
                        theTrainer.CourseId == courseId
                        && theTrainer.TrainerId == trainerId
                        && theTrainer.BookedForSessionNumber == bookedSessionNumber
                ).FirstOrDefault();

            if (formBody["action"] == "selectedTrainersForPractical")
            {
                if (theCourseTrainer == null)
                {
                    CourseTrainer courseTrainer = new CourseTrainer();
                    courseTrainer.TrainerId = trainerId;
                    courseTrainer.CourseId = courseId;
                    courseTrainer.DateCreated = DateTime.Now;
                    courseTrainer.CreatedByUserId = userId;
                    courseTrainer.BookedForPractical = true;
                    courseTrainer.BookedForSessionNumber = bookedSessionNumber;

                    atlasDB.CourseTrainer.Add(courseTrainer);
                }
                else
                {
                    theCourseTrainer.BookedForPractical = true;
                    atlasDB.CourseTrainer.Attach(theCourseTrainer);
                    var courseTrainerEntry = atlasDB.Entry(theCourseTrainer);
                    courseTrainerEntry.State = System.Data.Entity.EntityState.Modified;
                }
            }
            else if (formBody["action"] == "selectedTrainersForTheory")
            {
                if (theCourseTrainer == null)
                {
                    CourseTrainer courseTrainer = new CourseTrainer();
                    courseTrainer.TrainerId = trainerId;
                    courseTrainer.CourseId = courseId;
                    courseTrainer.DateCreated = DateTime.Now;
                    courseTrainer.CreatedByUserId = userId;
                    courseTrainer.BookedForTheory = true;
                    courseTrainer.BookedForSessionNumber = bookedSessionNumber;

                    atlasDB.CourseTrainer.Add(courseTrainer);
                }
                else
                {
                    theCourseTrainer.BookedForTheory = true;
                    atlasDB.CourseTrainer.Attach(theCourseTrainer);
                    var courseTrainerEntry = atlasDB.Entry(theCourseTrainer);
                    courseTrainerEntry.State = System.Data.Entity.EntityState.Modified;
                }
            }
            else if (formBody["action"] == "availableTrainersForPractical")
            {
                if (theCourseTrainer.BookedForTheory == false)
                {
                    atlasDB.CourseTrainer.Attach(theCourseTrainer);
                    var courseTrainerEntry = atlasDB.Entry(theCourseTrainer);
                    courseTrainerEntry.State = System.Data.Entity.EntityState.Deleted;
                }
                else
                {
                    theCourseTrainer.BookedForPractical = false;
                    atlasDB.CourseTrainer.Attach(theCourseTrainer);
                    var courseTrainerEntry = atlasDB.Entry(theCourseTrainer);
                    courseTrainerEntry.State = System.Data.Entity.EntityState.Modified;
                }
            }
            else if (formBody["action"] == "availableTrainersForTheory")
            {
                if (theCourseTrainer.BookedForPractical == false)
                {
                    atlasDB.CourseTrainer.Attach(theCourseTrainer);
                    var courseTrainerEntry = atlasDB.Entry(theCourseTrainer);
                    courseTrainerEntry.State = System.Data.Entity.EntityState.Deleted;
                }
                else
                {
                    theCourseTrainer.BookedForTheory = false;
                    atlasDB.CourseTrainer.Attach(theCourseTrainer);
                    var courseTrainerEntry = atlasDB.Entry(theCourseTrainer);
                    courseTrainerEntry.State = System.Data.Entity.EntityState.Modified;
                }
            }

            atlasDB.SaveChanges();

            // if the course is a DORS course send the trainer update to DORS.
            var message = updateCourseTrainersToDORS(courseId, userId);

            if(message == nonDORSCourseMessage)
            {
                message = "Trainers updated.";
            }
            return message;
        }

        string updateCourseTrainersToDORS(int courseId, int userId)
        {
            var message = "";
            var course = atlasDB.Course
                                .Include(c => c.DORSCourses)
                                .Where(c => c.DORSCourses.Any(dc => dc.CourseId == courseId))
                                .FirstOrDefault();
            if(course != null)
            {
                var dorsInterfaceController = new DORSWebServiceInterfaceController();
                try
                {
                    var updated = dorsInterfaceController.updateCourseTrainers(courseId, userId);
                    if (updated)
                    {
                        message = "Trainers for this course were updated on DORS.";
                    }
                    else
                    {
                        message = "Trainers not updated on DORS.";
                    }
                }
                catch(Exception ex)
                {
                    message = ex.Message;
                }
            }
            else
            {
                message = nonDORSCourseMessage;
            }
            return message;
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }
    }
}