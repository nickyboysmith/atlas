using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Web.Script.Serialization;
using System.Web;
using System.Configuration;
using System.IO;
using System.Data.Entity.Validation;
using System.Web.Http.ModelBinding;
using System.Globalization;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseController : AtlasBaseController
    {
        protected FormDataCollection formData;
        //Allows template course data (for cloning) to be retrieved along with alternative options for the dropdowns. 
        //Where 0 is passed in as the course ID this denotes course creation from scratch        

        //POST: api/Client
        [AuthorizationRequired]
        public CourseJSON Post([FromBody] FormDataCollection formBody)
        {
            //Cater for 2 functions: fetch and add
            this.formData = formBody;
            var courseReturnData = new CourseJSON();

            if (formBody.Count() > 0)
            {
                string operation = StringTools.GetString("operation", ref formData).ToUpper();
                int userID = StringTools.GetInt("userId", ref formData);
                int courseId = StringTools.GetInt("courseId", ref formData);
                int organisationId = StringTools.GetInt("organisationId", ref formData);

                if (userID > 0)
                {
                    switch (operation)
                    {
                        case "ADD":
                            return this.SaveCourse(userID, courseReturnData, true);

                        case "SAVE":
                            return this.SaveCourse(userID, courseReturnData);

                        default:
                            break;
                    }
                }
            }
            return courseReturnData;
        }

        [HttpGet]
        [Route("api/Course/GetCoursePlacesDetail/{courseId}")]
        public object GetCoursePlacesDetail(int courseId)
        {
            var coursePlaces = atlasDBViews.vwCourseDetails
                                        .Where(cd => cd.CourseId == courseId)
                                        .Select(cd => new
                                        {
                                            PlacesRemaining = cd.PlacesRemaining,
                                            NumberOfBookedClients = cd.NumberOfBookedClients,

                                        })
                                        .FirstOrDefault();
            return coursePlaces;
        }

        [Route("api/course/{courseId}/{userId}")]
        /// <summary>
        /// A simple get that checks to see that the user has permission to view the course requested
        /// Might have to be changed to get the userId from the authenication
        /// </summary>
        /// <param name="courseId">Request course</param>
        /// <param name="userId">User requesting course</param>
        /// <returns></returns>
        public CourseJSON Get(int courseId, int userId)
        {
            CourseJSON courseJSON = null;
            bool isAdmin = false;
            var user = atlasDB.SystemAdminUsers.Where(sau => sau.UserId == userId).FirstOrDefault();
            if (user != null) isAdmin = true;
            var course = atlasDB.Course
                                .Include(c => c.Organisation)
                                .Include(c => c.Organisation.OrganisationAdminUsers)
                                .Include(c => c.CourseVenue)
                                .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                                .Include(c => c.CourseDate)
                                .Include(c => c.CourseType)
                                .Include(c => c.CourseTypeCategory)
                                .Include(c => c.CourseDORSForceContracts)
                                .Where(c => c.Id == courseId)
                                .FirstOrDefault();
            if (course != null)
            {
                if (course.Organisation != null && course.Organisation.OrganisationAdminUsers.Any(oau => oau.UserId == userId))
                {
                    isAdmin = true; // is the user a Organisation Admin User?
                }
                courseJSON = new CourseJSON();
                courseJSON.Id = course.Id;
                courseJSON.courseReference = course.Reference;
                // find the start date and end date
                var startDateString = "";
                var endDateString = "";
                var startDate = course.CourseDate.OrderBy(cd => cd.DateStart).FirstOrDefault();
                var endDate = course.CourseDate.OrderBy(cd => cd.DateEnd).LastOrDefault();
                if (startDate != null)
                {
                    startDateString = startDate.DateStart != null ? ((DateTime)startDate.DateStart).ToString("dd/MM/yyyy HH:mm") : "";
                }
                if (endDate != null)
                {
                    endDateString = endDate.DateEnd != null ? ((DateTime)startDate.DateEnd).ToString("dd/MM/yyyy HH:mm") : "";
                }
                courseJSON.courseDateStart = startDateString;
                courseJSON.courseDateEnd = endDateString;
                //courseJSON.sessionNumber = endDateString;

                var courseVenue = course.CourseVenue.FirstOrDefault();
                if (courseVenue != null && courseVenue.Venue != null)
                {
                    courseJSON.venueTitle = courseVenue.Venue.Title;
                    courseJSON.courseDorsCourse = isCourseADORSCourse(courseVenue.Venue, course.CourseType, course.CourseDORSForceContracts.FirstOrDefault());
                }
                else
                {
                    // a dors course needs to have a DORS Venue
                    courseJSON.courseDorsCourse = false;
                }

                courseJSON.courseTypeTitle = course.CourseType.Title;
                if (course.CourseTypeCategory != null)
                {
                    courseJSON.courseTypeCategoryName = course.CourseTypeCategory.Name;
                }

                courseJSON.courseTypeId = course.CourseTypeId;
                courseJSON.courseTypeCategoryId = course.CourseTypeCategoryId == null ? -1 : (int)course.CourseTypeCategoryId;
            }
            return courseJSON;
        }

        // TODO: This needs to be refactored / commented
        [AuthorizationRequired]
        public CourseJSON Get(int userID, int courseId, int organisationId, int cloneId)
        {
            //Cater for 2 functions: fetch and add            
            var courseReturnData = new CourseJSON();

            if (courseId > 0)
            {
                //Retrieve an existing course
                return this.GetCourseAndOptions(userID, courseId, organisationId, courseReturnData);
            }
            else
            {
                //Retrieve dropdown and optional clone course data for a new course
                return this.GetCourseAndOptions(userID, cloneId > 0 ? cloneId : courseId, organisationId, courseReturnData, cloneId > 0 ? true : false);
            }
        }

        private CourseJSON SaveCourse(int userID, CourseJSON courseReturnData, bool asNew = false)
        {
            string exceptionMessage = "";
            int courseId = StringTools.GetInt("courseId", ref formData);
            var vwCourseClients = atlasDBViews.vwCourseClients.Where(cc => cc.CourseId == courseId).ToList();
            int courseTypeId = StringTools.GetInt("courseTypeId", ref formData);
            int organisationId = StringTools.GetInt("organisationId", ref formData);
            int categoryId = StringTools.GetInt("categoryId", ref formData);
            int venueId = StringTools.GetInt("venueId", ref formData);
            int languageId = StringTools.GetInt("languageId", ref formData);
            int coursePlaces = StringTools.GetInt("coursePlaces", ref formData);
            int courseReserved = StringTools.GetInt("courseReserved", ref formData);
            int trainersRequired = StringTools.GetInt("trainersRequired", ref formData);
            int? sessionNumber = StringTools.GetIntOrNull("sessionNumber", ref formData);
            string courseReference = StringTools.GetString("courseReference", ref formData);
            if (string.IsNullOrEmpty(courseReference))
            {
                // if string is an empty string set it to null
                courseReference = null;
            }
            string courseDateStart = StringTools.GetString("courseDateStart", ref formData);
            string courseTimeStart = StringTools.GetString("courseTimeStart", ref formData);
            string courseDateEnd = StringTools.GetString("courseDateEnd", ref formData);
            string courseTimeEnd = StringTools.GetString("courseTimeEnd", ref formData);

            if (courseTimeStart == null && sessionNumber != null)
            {
                courseTimeStart = atlasDB.TrainingSessions
                                            .Where(ts => ts.Number == sessionNumber)
                                            .First()
                                            .EndTime;
            }

            if (courseTimeEnd == null && sessionNumber != null)
            {
                courseTimeEnd = atlasDB.TrainingSessions
                                            .Where(ts => ts.Number == sessionNumber)
                                            .First()
                                            .EndTime;
            }

            DateTime courseDateStartDateTime;
            DateTime courseDateEndDateTime;
            //Just in case courseDateStart Already has A Time on the End
            courseDateStart = DateTime.Parse(courseDateStart).Date.ToString("dd MMM yyyy").Replace(" 00:00:00", "");
            courseDateEnd = DateTime.Parse(courseDateEnd).Date.ToString("dd MMM yyyy").Replace(" 00:00:00", "");
            var courseStartDateParse = DateTime.TryParse(courseDateStart + " " + courseTimeStart, out courseDateStartDateTime);
            var courseEndDateParse = DateTime.TryParse(courseDateEnd + " " + courseTimeEnd, out courseDateEndDateTime);
            bool courseMultiDay = StringTools.GetBool("multiday", ref formData);

            if (courseDateEndDateTime != null && courseDateStartDateTime != null && courseMultiDay == false)
            {
                courseDateEndDateTime = courseDateStartDateTime.Date + courseDateEndDateTime.TimeOfDay;
            }

            bool courseHasInterpreter = StringTools.GetBool("courseHasInterpreter", ref formData);
            bool courseUpdateDorsAttendance = StringTools.GetBool("courseUpdateDorsAttendance", ref formData);
            bool courseAttendanceByTrainer = StringTools.GetBool("courseAttendanceByTrainer", ref formData);
            bool courseManualCarsOnly = StringTools.GetBool("courseManualCarsOnly", ref formData);
            bool courseRestrictOnlineBookingManualOnly = StringTools.GetBool("courseRestrictOnlineBookingManualOnly", ref formData);
            bool courseDorsCourse = StringTools.GetBool("courseDorsCourse", ref formData);
            bool courseAttendanceCheckRequired = StringTools.GetBool("courseAttendanceCheckRequired", ref formData);
            bool notifyDORS = StringTools.GetBool("notifyDORS", ref formData);
            bool TheoryCourse = StringTools.GetBool("TheoryCourse", ref formData);
            bool PracticalCourse = StringTools.GetBool("PracticalCourse", ref formData);
            bool Available = StringTools.GetBool("available", ref formData);

            int numberOfCourseDates = StringTools.GetInt("NumberOfCourseDates", ref formData);

            var existingCourse = false;


            DateTime? lastBookingDate = asNew ? new DateTime() : StringTools.GetDate("lastBookingDate", "dd/MM/yyyy", ref formData);

            // does the course reference conform to the uniqueness settings in the SystemSelfConfiguration table?
            bool courseReferencePassed = true;
            if (asNew)
            {
                courseReferencePassed = CheckCourseReference(courseReference, organisationId, courseDorsCourse);
            }

            if (courseTypeId == 0 || organisationId == 0 || (asNew == false && !(courseId > 0)) || !courseReferencePassed)
            {
                if (!courseReferencePassed)
                {
                    if (string.IsNullOrEmpty(courseReference))
                    {
                        exceptionMessage = "Please enter a Course Reference.";
                    }
                    else
                    {
                        exceptionMessage = "Course reference already exists.";
                    }
                }
                else
                {
                    exceptionMessage = "A course must have a valid Course Type selected before it can be saved.";
                }
            }
            else
            {
                Course newCourse;
                DateTime? existingCourseStartDate = new DateTime();
                DateTime? existingCourseEndDate = new DateTime();

                if (courseId > 0)
                {
                    //Existing Course
                    newCourse = atlasDB.Course
                        .Include("CourseDate")
                        .Where(x => x.Id == courseId).First();

                    existingCourse = true;

                    if (newCourse.CourseDate.Count > 0)
                    {
                        existingCourseStartDate = newCourse.CourseDate.FirstOrDefault().DateStart;
                        existingCourseEndDate = newCourse.CourseDate.FirstOrDefault().DateEnd;
                    }
                    else
                    {
                        existingCourseStartDate = null;
                        existingCourseEndDate = null;
                    }
                }
                else
                {
                    //New Course
                    newCourse = new Course();
                    newCourse.Reference = courseReference;
                    newCourse.CourseTypeId = courseTypeId;
                    if (courseDorsCourse) newCourse.DORSNotified = false;
                }
                //Can not update course date time if clients are already booked on it
                if ((existingCourse == true && vwCourseClients.Count > 0) && existingCourseStartDate != courseDateStartDateTime)
                {
                    courseReturnData.actionMessage = "Can not update the course date and time if clients are already booked on to the course";
                }
                else
                {
                    newCourse.OrganisationId = organisationId;
                    newCourse.CourseTypeId = courseTypeId;
                    newCourse.Reference = courseReference;
                    newCourse.HasInterpreter = courseHasInterpreter;
                    newCourse.TrainersRequired = trainersRequired;
                    newCourse.SendAttendanceDORS = courseUpdateDorsAttendance;
                    newCourse.TrainerUpdatedAttendance = courseAttendanceByTrainer;
                    newCourse.ManualCarsOnly = courseManualCarsOnly;
                    newCourse.OnlineManualCarsOnly = courseRestrictOnlineBookingManualOnly;
                    newCourse.TheoryCourse = TheoryCourse;
                    newCourse.PracticalCourse = PracticalCourse;
                    newCourse.Available = Available;
                    if (!asNew)
                    {
                        newCourse.LastBookingDate = lastBookingDate;
                    }

                    if (notifyDORS)
                    {
                        newCourse.DORSNotificationRequested = notifyDORS;
                    }
                    if (courseDorsCourse)
                    {
                        newCourse.DORSCourse = courseDorsCourse;
                        if (Available)
                        {
                            newCourse.DORSNotificationRequested = true;
                        }
                        if (newCourse.Id < 1)   // a new DORS course
                        {
                            // find the forcecontract for this coursetype
                            var forceContract = getDORSForceContract(courseTypeId, venueId, courseDateStartDateTime);
                            if (forceContract != null)
                            {
                                var courseDORSForceContract = new CourseDORSForceContract();
                                courseDORSForceContract.DORSForceContractId = forceContract.Id;
                                newCourse.CourseDORSForceContracts.Add(courseDORSForceContract);
                            }
                            else
                            {
                                var ex = new Exception("Couldn't find a Force Contract for Course '" + newCourse.Reference + "', courseDorsForceContract to be inserted by 'Course' sql trigger.");
                                LogError("Add Course" + getSystemName(), ex);
                            }
                        }
                    }

                    newCourse.AttendanceCheckRequired = courseAttendanceCheckRequired;

                    if (categoryId > 0)
                    {
                        newCourse.CourseTypeCategoryId = categoryId;
                    }
                    else
                    {
                        newCourse.CourseTypeCategoryId = null;
                    }
                    if (venueId > 0)
                    {
                        CourseVenue CourseVenue, CurrentVenue;
                        if (courseId > 0)
                        {
                            //Existing Course
                            CurrentVenue = atlasDB.CourseVenue.Where(x => x.CourseId == courseId).FirstOrDefault();
                            CourseVenue = CurrentVenue;
                            if (CourseVenue == null)
                            {
                                //Avenue to existing course
                                CourseVenue = new CourseVenue();
                            }
                        }
                        else
                        {
                            //New Course
                            CurrentVenue = CourseVenue = new CourseVenue();
                        }

                        CourseVenue.MaximumPlaces = coursePlaces;
                        CourseVenue.ReservedPlaces = courseReserved;
                        CourseVenue.VenueId = venueId;

                        if (courseId == 0 || CurrentVenue == null)
                        {
                            newCourse.CourseVenue.Add(CourseVenue);
                        }
                    }

                    if (languageId > 0)
                    {
                        CourseLanguage CourseLanguage, CurrentLanguage;
                        if (courseId > 0)
                        {
                            //Existing Course
                            CurrentLanguage = atlasDB.CourseLanguage.Where(x => x.CourseId == courseId).FirstOrDefault();
                            CourseLanguage = CurrentLanguage;
                            if (CourseLanguage == null)
                            {
                                CourseLanguage = new CourseLanguage();
                            }
                        }
                        else
                        {
                            //New Course
                            CurrentLanguage = CourseLanguage = new CourseLanguage();
                        }
                        CourseLanguage.OrganisationLanguageId = languageId;

                        if (courseId == 0 || CurrentLanguage == null)
                        {
                            newCourse.CourseLanguage.Add(CourseLanguage);
                        }
                    }
                    else if (languageId == 0)
                    {
                        if (courseId > 0)
                        {
                            //Existing Course Language
                            var courseLanguageToRemove = atlasDB.CourseLanguage.Where(x => x.CourseId == courseId).FirstOrDefault();
                            if (courseLanguageToRemove != null)
                            {
                                atlasDB.CourseLanguage.Remove(courseLanguageToRemove);
                            }
                        }

                    }

                    var existingCourseDates = atlasDB.CourseDate.Where(cd => cd.CourseId == courseId).ToList();
                    if (courseMultiDay)
                    {
                        if (courseId > 0 && existingCourseDates.Count > 0 && existingCourseDates.Count > numberOfCourseDates)
                        {
                            //Remove Extra Course Dates on Existing Course
                            for (var i = numberOfCourseDates; i < existingCourseDates.Count; i++)
                            {
                                var existingCourseDate = existingCourseDates[i];
                                var cd = atlasDB.CourseDate.Find(existingCourseDate.Id);

                                if (cd != null)
                                {
                                    atlasDB.CourseDate.Remove(cd);
                                    atlasDB.Entry(cd).State = EntityState.Deleted;
                                }
                            }

                            atlasDB.SaveChanges();
                        }

                        //var EmptyDateAndTime = { Indx: i, StartDate: '', EndDate: '', Session: '', StartTime: '', EndTime: '', DisplayCalendar: false };
                        for (var i = 0; i < numberOfCourseDates; i++)
                        {
                            CourseDate CourseDate;
                            if (courseId > 0 && existingCourseDates.Count > 0 && existingCourseDates.Count > (i - 1))
                            {
                                //Update Existing CourseDates First
                                CourseDate = atlasDB.CourseDate.Where(x => x.CourseId == courseId).OrderBy(ord => ord.Id).Skip(i).Take(1).First();
                                CourseDate.DateUpdated = DateTime.Now;
                            }
                            else
                            {
                                //New Course Dates
                                CourseDate = new CourseDate();
                                CourseDate.CreatedByUserId = userID;
                                CourseDate.DateUpdated = DateTime.Now;
                            }

                            var arrayName = "MultiDatesAndTimes";
                            var fieldIndx = arrayName + "[" + i + "][Indx]";
                            var fieldStartDate = arrayName + "[" + i + "][StartDate]";
                            var fieldEndDate = arrayName + "[" + i + "][EndDate]";
                            var fieldSession = arrayName + "[" + i + "][Session]";
                            var fieldSessionNumber = arrayName + "[" + i + "][Session][SessionNumber]";
                            var fieldStartTime = arrayName + "[" + i + "][StartTime]";
                            var fieldEndTime = arrayName + "[" + i + "][EndTime]";

                            var startTime = StringTools.GetString(fieldStartTime, ref formData);
                            var endTime = StringTools.GetString(fieldEndTime, ref formData);
                            if (newCourse.DefaultStartTime == null || newCourse.DefaultStartTime == "")
                            {
                                newCourse.DefaultStartTime = startTime; //Set to the First One
                            }
                            newCourse.DefaultEndTime = endTime; //Set to the Last One

                            CourseDate.DateStart = StringTools.GetDate(fieldStartDate, ref formData);
                            CourseDate.DateStart = DateTime.Parse(((DateTime)CourseDate.DateStart).ToString("dd MMM yyyy") + " " + startTime);
                            CourseDate.DateEnd = StringTools.GetDate(fieldEndDate, ref formData);
                            CourseDate.DateEnd = DateTime.Parse(((DateTime)CourseDate.DateEnd).ToString("dd MMM yyyy") + " " + endTime);

                            CourseDate.Available = true;
                            CourseDate.AttendanceUpdated = false;
                            CourseDate.AttendanceVerified = false;
                            CourseDate.AssociatedSessionNumber = StringTools.GetInt(fieldSessionNumber, ref formData);

                            if (courseId > 0 && existingCourseDates.Count > 0 && existingCourseDates.Count > (i - 1))
                            {
                                atlasDB.Entry(CourseDate).State = EntityState.Modified;
                            }
                            else
                            {
                                newCourse.CourseDate.Add(CourseDate);
                            }
                        }
                    }
                    else
                    {
                        if (courseDateStartDateTime != null)
                        {
                            DateTime courseDate = new DateTime();
                            DateTime.TryParse(courseDateEnd, out courseDate);

                            CourseDate CourseDate;

                            if (courseId > 0 && existingCourseDates.Count > 0)
                            {
                                //Existing Course
                                CourseDate = atlasDB.CourseDate.Where(x => x.CourseId == courseId).First();
                            }
                            else
                            {
                                //New Course
                                CourseDate = new CourseDate();
                            }

                            CourseDate.CreatedByUserId = userID;

                            if (courseDateEndDateTime != null)
                            {
                                CourseDate.DateEnd = courseDateEndDateTime;
                            }

                            CourseDate.DateStart = courseDateStartDateTime;

                            CourseDate.AssociatedSessionNumber = sessionNumber;

                            if (courseId > 0)
                            {
                                if (existingCourseDates.Count > 0)
                                {
                                    foreach (var existingCourseDate in existingCourseDates)
                                    {
                                        var cd = atlasDB.CourseDate.Find(existingCourseDate.Id);

                                        if (cd != null)
                                        {
                                            atlasDB.CourseDate.Remove(cd);
                                            atlasDB.Entry(cd).State = EntityState.Deleted;
                                        }
                                    }

                                    atlasDB.SaveChanges();
                                }

                                newCourse.DateUpdated = DateTime.Now;
                                newCourse.CourseDate.Add(CourseDate);
                            }
                            else
                            {
                                newCourse.CourseDate.Add(CourseDate);
                            }

                            newCourse.DefaultStartTime = courseTimeStart;
                            newCourse.DefaultEndTime = courseTimeEnd;
                        }
                    }

                    newCourse.DateUpdated = DateTime.Now;
                    if (courseId == 0)
                    {
                        newCourse.CreatedByUserId = userID;
                        atlasDB.Course.Add(newCourse);
                    }
                    else
                    {
                        atlasDB.Entry(newCourse).State = EntityState.Modified;
                    }

                    atlasDB.SaveChanges();

                    courseReturnData.Id = newCourse.Id;
                    courseReturnData.actionMessage = courseId > 0 ? "courseSaved" : "courseAdded";
                }
            }

            if (!string.IsNullOrEmpty(exceptionMessage))
            {
                throw new Exception(exceptionMessage);
            }
            else
            {
                return courseReturnData;
            }
        }

        private DORSForceContract getDORSForceContract(int courseTypeId, int venueId, DateTime courseStartDate)
        {
            DORSForceContract dorsForceContract = null;
            dorsForceContract = atlasDB.uspGetDORSForceContract(courseTypeId, venueId, courseStartDate)
                                        .Select(dfc => new DORSForceContract() {
                                            Id = dfc.Id,
                                            DORSForceContractIdentifier = dfc.DORSForceContractIdentifier,
                                            DORSForceIdentifier = dfc.DORSForceIdentifier,

                                        })
                                        .FirstOrDefault();
            return dorsForceContract;
        }

        private bool CheckCourseReference(string courseReference, int organisationId, bool isDorsCourse)
        {
            bool referencePassed = false;
            var organisationSelfConfiguration = atlasDB.OrganisationSelfConfigurations.Where(osc => osc.OrganisationId == organisationId).FirstOrDefault();
            if (organisationSelfConfiguration != null)
            {
                if (isDorsCourse)
                {
                    if (organisationSelfConfiguration.UniqueReferenceForAllDORSCourses)
                    {
                        referencePassed = isUniqueCourseReference(courseReference, organisationId);
                    }
                    else
                    {
                        referencePassed = true;
                    }
                }
                else
                {
                    if (organisationSelfConfiguration.UniqueReferenceForAllNonDORSCourses)
                    {
                        if (organisationSelfConfiguration.NonDORSCoursesMustHaveReferences)
                        {
                            referencePassed = isUniqueCourseReference(courseReference, organisationId);
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(courseReference))
                            {
                                referencePassed = true;
                            }
                            else
                            {
                                referencePassed = isUniqueCourseReference(courseReference, organisationId);
                            }
                        }
                    }
                    else
                    {
                        if (organisationSelfConfiguration.NonDORSCoursesMustHaveReferences)
                        {
                            if (string.IsNullOrEmpty(courseReference))
                            {
                                referencePassed = false;
                            }
                            else
                            {
                                referencePassed = true;
                            }
                        }
                        else
                        {
                            referencePassed = true;
                        }
                    }
                }
            }
            return referencePassed;
        }

        bool isUniqueCourseReference(string courseReference, int organisationId)
        {
            bool isUnique = true;
            var course = atlasDB.Course.Where(c => c.Reference == courseReference && c.OrganisationId == organisationId).FirstOrDefault();
            if (course != null)
            {
                isUnique = false;
            }
            return isUnique;
        }

        private CourseJSON GetCourseAndOptions(int userID, int courseId, int organisationId, CourseJSON courseReturnData, bool asTemplate = false)
        {
            //Provide template defaults if a template course id is passed in
            if (courseId > 0)
            {
                Course course = atlasDB.Course
                    .Include("CourseDate")
                    .Include("CourseLanguage")
                    .Include("CourseVenue")
                    .Include("DORSCourses")
                    .Include("CancelledCourses")
                    .Include("CourseType")
                    .Include("CourseLockeds")
                    .Include("CourseProfileUneditables")
                    .Where(c => c.Id == courseId).FirstOrDefault();

                if (course != null)
                {
                    courseReturnData.Id = course.Id;
                    courseReturnData.courseTypeId = course.CourseTypeId;

                    if (course.CourseType != null)
                    {
                        courseReturnData.courseType = new CourseTypeJSON();
                        courseReturnData.courseType.Id = course.CourseType.Id;
                        courseReturnData.courseType.Title = course.CourseType.Title;
                        courseReturnData.courseType.Code = course.CourseType.Code;
                        courseReturnData.courseType.Description = course.CourseType.Description;
                        courseReturnData.courseType.MaxPracticalTrainers = course.CourseType.MaxPracticalTrainers;
                        courseReturnData.courseType.MaxTheoryTrainers = course.CourseType.MaxTheoryTrainers;
                    }

                    if (course.CourseTypeCategoryId == null)
                    {
                        course.CourseTypeCategoryId = 0;
                    }
                    else
                    {
                        courseReturnData.categoryId = (int)course.CourseTypeCategoryId;
                    }


                    courseReturnData.languageId = course.CourseLanguage.FirstOrDefault() != null ? course.CourseLanguage.FirstOrDefault().OrganisationLanguageId : -1;

                    if (course.CourseVenue.FirstOrDefault() == null)
                    {
                        courseReturnData.venueId = -1;
                        courseReturnData.coursePlaces = -1;
                        courseReturnData.courseReserved = 0;
                    }
                    else
                    {
                        courseReturnData.venueId = course.CourseVenue.FirstOrDefault().VenueId;
                        courseReturnData.coursePlaces = course.CourseVenue.FirstOrDefault().MaximumPlaces;
                        courseReturnData.courseReserved = (int)course.CourseVenue.First().ReservedPlaces;
                    }

                    courseReturnData.courseHasInterpreter = course.HasInterpreter != null ? course.HasInterpreter.Value : false;
                    courseReturnData.courseUpdateDorsAttendance = course.SendAttendanceDORS != null ? course.SendAttendanceDORS.Value : false;
                    courseReturnData.courseAttendanceByTrainer = course.TrainerUpdatedAttendance != null ? course.TrainerUpdatedAttendance.Value : false;
                    courseReturnData.courseManualCarsOnly = course.ManualCarsOnly != null ? course.ManualCarsOnly.Value : false;
                    courseReturnData.courseRestrictOnlineBookingManualOnly = course.OnlineManualCarsOnly != null ? course.OnlineManualCarsOnly.Value : false;
                    DateTime? courseStartDate = null;
                    DateTime? courseEndDate = null;
                    int? courseStartSessionNumber = null;
                    courseReturnData.courseMultiDay = false;

                    if (course.CourseDate.Count > 1)
                    {
                        courseReturnData.courseMultiDay = true;
                    }

                    courseStartDate = course.CourseDate.OrderBy(o => o.DateStart).FirstOrDefault().DateStart;
                    courseStartSessionNumber = course.CourseDate.OrderBy(o => o.DateStart).FirstOrDefault().AssociatedSessionNumber;
                    courseEndDate = course.CourseDate.OrderByDescending(o => o.DateStart).FirstOrDefault().DateEnd;

                    courseReturnData.courseDateStart = courseStartDate != null ? ((DateTime)courseStartDate).ToString("dd/MM/yyyy") : "";
                    courseReturnData.courseStarted = courseStartDate != null ? ((DateTime)courseStartDate) < DateTime.Now : false;
                    courseReturnData.courseDateEnd = courseEndDate != null ? ((DateTime)courseEndDate).ToString("dd/MM/yyyy") : "";
                    courseReturnData.courseTimeStart = course.DefaultStartTime != null ? course.DefaultStartTime.ToString() : "";
                    courseReturnData.courseTimeEnd = course.DefaultEndTime != null ? course.DefaultEndTime.ToString() : "";
                    courseReturnData.sessionNumber = courseStartSessionNumber;
                    courseReturnData.courseDateInPast = isCourseDateInPast(courseReturnData.courseDateEnd, course.DefaultEndTime);
                    courseReturnData.lastBookingDate = course.LastBookingDate;
                    courseReturnData.trainersRequired = course.TrainersRequired.HasValue ? course.TrainersRequired.Value : 0;

                    courseReturnData.courseDorsCourse = course.DORSCourse == null ? false : (bool)course.DORSCourse;

                    courseReturnData.courseCancelled = course.CancelledCourses.Count() > 0;
                    courseReturnData.courseAttendanceCheckRequired = course.AttendanceCheckRequired != null ? course.AttendanceCheckRequired.Value : false;
                    courseReturnData.courseAttendanceVerified = course.AttendanceCheckVerified != null ? course.AttendanceCheckVerified.Value : false;
                    courseReturnData.courseAttendeanceSentToDors = course.AttendanceSentToDORS != null ? course.AttendanceSentToDORS.Value : false;
                    courseReturnData.courseAttendeanceSentToDorsTime = course.DateAttendanceSentToDORS != null ? course.DateAttendanceSentToDORS.ToString() : "";
                    courseReturnData.TheoryCourse = course.TheoryCourse == null ? false : (bool)course.TheoryCourse;
                    courseReturnData.PracticalCourse = course.PracticalCourse == null ? false : (bool)course.PracticalCourse;
                    if (UserHasSystemAdminStatus(userID))
                    {
                        var hasCourseFinished = isCourseDateInPast(courseEndDate.ToString(), course.DefaultEndTime);
                        courseReturnData.isCourseLocked = hasCourseFinished;
                    }
                    else { 
                        courseReturnData.isCourseLocked = course.CourseLockeds.Any(cl => cl.AfterDate < DateTime.Now);
                    }
                    courseReturnData.isCourseProfileLocked = course.CourseProfileUneditables.Any(cpu => cpu.AfterDate < DateTime.Now);
                    if (!asTemplate)
                    {
                        //If the course is not being retrieved as a clone template get the availability, reference, trainers and notes
                        courseReturnData.courseAvailable = course.Available.HasValue ? course.Available.Value : false;
                        courseReturnData.courseReference = course.Reference;

                        //Course Trainers And Interpreters
                        courseReturnData.courseTrainersAndInterpreters = atlasDBViews.vwCourseAllocatedTrainerAndInterpreters
                                                                    .Where(ctai => ctai.CourseId == courseId)
                                                                    .Select(ctai => new CourseTrainersAndInterpretersJSON
                                                                    {
                                                                        Id = ctai.TrainerOrInterpreterId,
                                                                        Name = ctai.TrainerOrInterpreterCourseDisplayName
                                                                    })
                                                                    .ToList();
                        //Course Notes
                        courseReturnData.courseNotes = (from cn in atlasDB.CourseNote
                                                       .Include("CourseNoteType")
                                                       .Include("User")
                                                       .Include("SystemAdminUsers")
                                                        where cn.CourseId == courseId
                                                        orderby cn.DateCreated descending
                                                        select (new CourseNotesJSON
                                                        {
                                                            Date = cn.DateCreated != null ? cn.DateCreated.Value : DateTime.Now,
                                                            Type = cn.CourseNoteType.Title,
                                                            User = "User",//cn.User.SystemAdminUsers!=null?"Administration": cn.User.Name,
                                                            Text = cn.Note
                                                        })).ToList();

                        // Course Documents
                        courseReturnData.documents = atlasDB.Documents
                                                        .Include(d => d.CourseDocuments)
                                                        .Where(d => d.CourseDocuments.Any(cd => cd.CourseId == courseId))
                                                        .Select(d => new CourseDocumentJSON
                                                        {
                                                            Id = d.Id,
                                                            Title = d.Title,
                                                            Type = d.Type,
                                                            FileName = d.FileName,
                                                            Description = d.Description,
                                                            MarkedForDeletion = d.DocumentMarkedForDeletes.Any()
                                                        }).ToList();
                        
                        // Course Dates
                        courseReturnData.courseDates = atlasDB.CourseDate
                                                        .Where(cd => cd.CourseId == courseId)
                                                        .Select(cd => new CourseDateJSON
                                                        {
                                                            Id = cd.Id,
                                                            CourseId = cd.CourseId,
                                                            DateStart = cd.DateStart,
                                                            DateEnd = cd.DateEnd,
                                                            Available = cd.Available,
                                                            AttendanceUpdated = cd.AttendanceUpdated,
                                                            AttendanceVerified = cd.AttendanceVerified,
                                                            AssociatedSessionNumber = cd.AssociatedSessionNumber
                                                        }).ToList();
                        
                        var courseLogData = new List<CourseLogJSON>();

                        foreach (var noteItem in courseReturnData.courseNotes)
                        {
                            courseLogData.Add(new CourseLogJSON
                            {
                                Date = noteItem.Date,
                                Detail = noteItem.Text,
                                User = noteItem.User,
                                Event = "Course Note"
                            });
                        }
                        courseReturnData.courseLog = courseLogData.OrderByDescending(x => x.Date).ToList();
                    }

                    if (courseReturnData.venueId > 0)
                    {
                        // Course Venue Locations
                        courseReturnData.venueLocations = atlasDBViews.vwVenueDetails
                                                        .Where(d => d.Id == courseReturnData.venueId)
                                                        .Select(d => new VenueLocationJSON
                                                        {
                                                            Title = d.Title,
                                                            Address = d.Address,
                                                            PostCode = d.PostCode
                                                        }).ToList();
                    }

                    if (courseReturnData.sessionNumber > 0)
                    {
                        // Course Venue Locations
                        courseReturnData.courseAssociatedSession = atlasDBViews.vwTrainingSessions
                                                        .Where(d => d.SessionNumber == courseReturnData.sessionNumber)
                                                        .FirstOrDefault().SessionTitle;
                    }
                }
            }
            return courseReturnData;
        }

        private bool isCourseDateInPast(string courseDateEnd, string defaultEndTime)
        {
            bool courseInPast = true;
            DateTime endDate;
            courseDateEnd = courseDateEnd.Replace(" 00:00:00", "").Replace(" 00:00", ""); //Remove Empty Times
            if (courseDateEnd.Contains(":"))
            {
                //Has Time Element
                if (DateTime.TryParse(courseDateEnd, out endDate))
                {
                    if (endDate > DateTime.Now)
                    {
                        courseInPast = false;
                    }
                }
            }
            else if (DateTime.TryParseExact(courseDateEnd, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out endDate))
            {
                if (!string.IsNullOrEmpty(defaultEndTime))
                {
                    var hhmmArray = defaultEndTime.Trim().Split(":".ToCharArray());
                    int hours, minutes;
                    if (int.TryParse(hhmmArray[0], out hours) && int.TryParse(hhmmArray[1], out minutes))
                    {
                        endDate = endDate.AddHours(hours);
                        endDate = endDate.AddMinutes(minutes);
                    }
                }
                if (endDate > DateTime.Now)
                {
                    courseInPast = false;
                }
            }
            return courseInPast;
        }

        private string CompileDetail(string OldValue, string NewValue)
        {
            if (string.IsNullOrWhiteSpace(OldValue) || string.IsNullOrWhiteSpace(NewValue))
            {
                return string.IsNullOrWhiteSpace(OldValue) ? NewValue : OldValue;
            }
            else
            {
                return "From: " + OldValue + " to: " + NewValue;
            }
        }

        [Route("api/course/getClients/{CourseId}/{OrganisationId}")]
        public IEnumerable<CourseClientJSON> GetClients(int CourseId, int OrganisationId)
        {
            var courseClientData = atlasDBViews.vwClientsWithinCourses.Where(x => x.OrganisationId == OrganisationId && x.CourseId == CourseId).ToList();
            var courseClients = new List<CourseClientJSON>();

            foreach (var courseClient in courseClientData)
            {
                //Check that the client is not on the deleted clients list
                if (atlasDB.CourseClientRemoveds.Count(x => x.ClientId == courseClient.ClientId && x.CourseId == courseClient.CourseId && x.DateAddedToCourse == courseClient.DateClientAdded) == 0)
                {
                    courseClients.Add(new CourseClientJSON(courseClient));
                }
            }

            return courseClients;
        }

        [HttpGet]
        [AuthorizationRequired]
        [AllowCrossDomainAccess]
        [Route("api/course/GetDORSCourse/{courseId}")]
        public DORSCourse GetDORSCourse(int courseId)
        {
            var dorsCourse = atlasDB.DORSCourses.Where(dc => dc.CourseId == courseId).FirstOrDefault();
            return dorsCourse;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/course/book/{clientId}/{courseId}/{addedByUserId}")]
        /* This function is going to have to be changed as the requirements for payments haven't been finalised */
        public bool Book(int clientId, int courseId, int addedByUserId)
        {
            try
            { 
                var message = "";
                bool courseBooked = false;
                var course = atlasDB.Course
                                    .Include(c => c.CourseClients)
                                    .Include(c => c.CourseType)
                                    .Include(c => c.CourseType.DORSSchemeCourseTypes)
                                    .Include(c => c.CourseDORSClients)
                                    .Where(c => c.Id == courseId).FirstOrDefault();
                var client = getClientWithDORSData(clientId);

                var clientLicence = client.ClientLicences.FirstOrDefault();

                var licenceNumber = "";
                if (clientLicence != null)
                {
                    licenceNumber = clientLicence.LicenceNumber;
                }

                

                if (course != null)
                {
                    if (client != null)
                    {
                        var existingCourseClients = course.CourseClients.Where(cc => cc.ClientId == clientId).ToList();

                        var existingCourseClientLicences = atlasDBViews.vwClientDetails
                                                                        .Where(x => x.OrganisationId == course.OrganisationId 
                                                                                    && x.CourseId == courseId 
                                                                                    && x.LicenceNumber == licenceNumber
                                                                                    ).ToList();

                        if (existingCourseClients.Count > 0)
                        {
                            message = "Client is already booked on this course.";
                        }
                        else if (existingCourseClientLicences.Count > 0 && licenceNumber.Length > 0)
                        {
                            message = "Client with the same Licence Number is already booked on this course.";
                        }
                        else
                        {
                            // is client a DORS client?
                            // if so have they got an offer to book this course type?  make a look to DORS
                            // are they are the booking pending state?
                            var DORSClient = false;
                            var bookingPending = false;
                            var haveAnOffer = false;
                            var DORSAttendanceReference = -1;
                            var BookingPendingAttendanceStateIdentifier = -1;
                            if (client.ClientDORSDatas.Count() > 0)
                            {
                                // this is a DORS client
                                DORSClient = true;
                                var currentOffer = client.ClientDORSDatas.Where(cdd => cdd.DORSScheme.DORSSchemeCourseTypes.Any(dsct => dsct.CourseTypeId == course.CourseTypeId)).FirstOrDefault();
                                if (currentOffer != null)
                                {
                                    haveAnOffer = true;
                                    if (currentOffer.DORSAttendanceState != null)
                                    {
                                        if (currentOffer.DORSAttendanceState != null)
                                        {
                                            if (currentOffer.DORSAttendanceState.Name.Contains("Booking Pending"))
                                            {
                                                BookingPendingAttendanceStateIdentifier = currentOffer.DORSAttendanceState.DORSAttendanceStateIdentifier;
                                                bookingPending = true;
                                                if (currentOffer.DORSAttendanceRef != null)
                                                {
                                                    DORSAttendanceReference = (int)currentOffer.DORSAttendanceRef;
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        // check DORS to see what the status is
                                        var dorsController = new DORSWebServiceInterfaceController();
                                        //var clientLicence = client.ClientLicences.FirstOrDefault();
                                        if (clientLicence != null)
                                        {
                                            var DORSCheckResult = dorsController.PerformDORSCheck(client.Id, clientLicence.LicenceNumber);
                                            // refresh the current offer
                                            client = getClientWithDORSData(clientId);   // get the client from the DB again
                                            currentOffer = client.ClientDORSDatas.Where(cdd => cdd.DORSScheme.DORSSchemeCourseTypes.Any(dsct => dsct.CourseTypeId == course.CourseTypeId)).FirstOrDefault();
                                            if (currentOffer != null)
                                            {
                                                if (currentOffer.DORSAttendanceState != null)
                                                {
                                                    if (currentOffer.DORSAttendanceState != null)
                                                    {
                                                        if (currentOffer.DORSAttendanceState.Name.Contains("Booking Pending"))
                                                        {
                                                            BookingPendingAttendanceStateIdentifier = currentOffer.DORSAttendanceState.DORSAttendanceStateIdentifier;
                                                            bookingPending = true;
                                                            if (currentOffer.DORSAttendanceRef != null)
                                                            {
                                                                DORSAttendanceReference = (int)currentOffer.DORSAttendanceRef;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    // if at booking pending, check to see that the client doesn't already have a booking in the que to notify DORS
                                    if (bookingPending)
                                    {
                                        var courseDORSClient = atlasDB.CourseDORSClients
                                                                        .Where(
                                                                            cdc => cdc.ClientId == client.Id &&
                                                                            (cdc.DORSNotified != null ? cdc.DORSNotified == false : true) &&
                                                                            cdc.Course.CourseTypeId == course.CourseTypeId
                                                                        )
                                                                        .FirstOrDefault();
                                        if(courseDORSClient != null)
                                        {
                                            // we found one return an error message
                                            bookingPending = false;
                                            message = "Unable to book course, this client already has a course booking being sent to DORS.";
                                        }
                                    }
                                }
                            }

                            if ((DORSClient && haveAnOffer && bookingPending) || !DORSClient)
                            {
                                var courseClient = new CourseClient();
                                courseClient.ClientId = clientId;
                                courseClient.CourseId = courseId;
                                courseClient.DateAdded = DateTime.Now;
                                courseClient.EmailReminderSent = false;
                                courseClient.AddedByUserId = addedByUserId;
                                courseClient.SMSReminderSent = false;

                                var courseFeeController = new CourseFeeController();
                                var courseFees = courseFeeController.Get(course.CourseTypeId, course.CourseTypeCategoryId);
                                if (courseFees.Count > 0)
                                {
                                    courseClient.TotalPaymentDue = courseFees[0].CourseFee;
                                }
                                atlasDB.CourseClients.Add(courseClient);

                                // if they are a dors client create/update a coursedorsclient entry
                                if (DORSClient)
                                {
                                    var courseDORSClient = course.CourseDORSClients.Where(cdc => cdc.ClientId == clientId).FirstOrDefault();
                                    if (courseDORSClient == null)
                                    {
                                        courseDORSClient = new CourseDORSClient();
                                    }
                                    courseDORSClient.ClientId = clientId;
                                    courseDORSClient.CourseId = courseId;
                                    courseDORSClient.DORSAttendanceRef = DORSAttendanceReference;
                                    courseDORSClient.DORSAttendanceStateIdentifier = BookingPendingAttendanceStateIdentifier;

                                    if (courseDORSClient.Id > 0)
                                    {
                                        var entry = atlasDB.Entry(courseDORSClient);
                                        entry.State = EntityState.Modified;
                                    }
                                    else
                                    {
                                        courseDORSClient.DateAdded = DateTime.Now;
                                        atlasDB.CourseDORSClients.Add(courseDORSClient);
                                    }
                                }

                                atlasDB.SaveChanges();
                                courseBooked = true;
                            }
                            else
                            {
                                if (string.IsNullOrEmpty(message))
                                {
                                    if (DORSClient)
                                    {
                                        if (!haveAnOffer)
                                        {
                                            message = "DORS Client doesn't have an offer for this course type.";
                                        }
                                        else
                                        {
                                            if (!bookingPending)
                                            {
                                                message = "DORS Client not at booking pending status.";
                                            }
                                        }
                                    }
                                    else
                                    {
                                        // shouldn't ever get in here because non DORS clients should have gotten into the if statement.
                                        message = "An error occurred.";
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        message = "Client could not be found.";
                    }
                }
                else
                {
                    message = "Course not found.";
                }
                if (!string.IsNullOrEmpty(message))
                {
                    throw new Exception(message);
                }
                return courseBooked;
            }
            catch (Exception ex){
                var err = ex;
                LogError("WebApI.Controllers.CourseConctoller.Book", ex);
                throw ex;
            }
        }

        private Client getClientWithDORSData(int clientId)
        {
            var client = atlasDB.Clients
                                .Include(c => c.ClientDORSDatas)
                                .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSAttendanceState))
                                .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSScheme))
                                .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSScheme.DORSSchemeCourseTypes))
                                .Include(c => c.ClientLicences)
                                .Where(c => c.Id == clientId).FirstOrDefault();
            return client;
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        [Route("api/course/change/{clientId}/{newCourseId}/{oldCourseId}")]
        public bool Change(int clientId, int newCourseId, int oldCourseId)
        {
            bool courseChanged = false;

            return courseChanged;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="courseId"></param>
        /// <returns></returns>
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/course/organisation/{courseTypeId}")]
        public object Organisation(int courseTypeId)
        {
            var singleOrganisationContacts = atlasDB.CourseType
                .Include("Organisation")
                .Include("Organisation.OrganisationRegion")
                .Include("Organisation.OrganisationRegion.Region")
                .Include("Organisation.OrganisationContacts")
                .Include("Organisation.OrganisationContacts.Location")
                .Where(x => x.Id == courseTypeId)
                .Select(e => new OrganisationContact
                {
                    //Note that 'Organisation' refers to the root organisation whilst 'Organisation1' refers to the organisation as a management contact
                    AreaId = e.Organisation.OrganisationRegion.FirstOrDefault().Region.Id.ToString(),
                    Area = e.Organisation.OrganisationRegion.FirstOrDefault().Region.Name,
                    OrganisationId = e.Organisation.Id.ToString(),
                    OrganisationName = e.Organisation.Name,
                    OrganisationAddress = e.Organisation.OrganisationContacts.FirstOrDefault().Location.Address,
                    OrganisationPostCode = e.Organisation.OrganisationContacts.FirstOrDefault().Location.PostCode,
                    OrganisationEmail = e.Organisation.OrganisationContacts.FirstOrDefault().Email.Address,
                    OrganisationPhone = e.Organisation.OrganisationContacts.FirstOrDefault().PhoneNumber
                })
                .ToList();

            return singleOrganisationContacts;
        }

        [Route("api/course/GetCourseDocuments/{courseId}")]
        [HttpGet]
        [AuthorizationRequired]
        public List<Document> GetCourseDocuments(int courseId)
        {
            var courseDocuments = atlasDB.Documents
                                            .Include(d => d.CourseDocuments)
                                            .Where(d => d.CourseDocuments.Any(cd => cd.CourseId == courseId))
                                            .ToList();
            return courseDocuments;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/course/downloadDocument/{Id}/{UserId}/{courseId}/{UserSelectedOrganisationId}/{DocumentName}")]
        public HttpResponseMessage downloadDocument(int Id, int UserId, int CourseId, int UserSelectedOrganisationId, string DocumentName)
        {
            HttpResponseMessage response = null;

            if (!this.UserMatchesToken(UserId, Request))
            {
                return response;
            }

            if (!this.UserAuthorisedForCourse(UserId, CourseId, UserSelectedOrganisationId, UserLevel.OrganisationUser))
            {
                return response;
            }

            //Confirm that the document relates to the course
            var courseDocument = atlasDB.CourseDocuments
                                            .Where(x => x.CourseId == CourseId && x.DocumentId == Id).FirstOrDefault();

            if (courseDocument != null)
            {
                var documentController = new DocumentController();
                var documentId = courseDocument.DocumentId;
                if (documentId != null)
                {
                    response = documentController.DownloadFileContents((int)documentId, UserId, DocumentName);
                }
            }
            return response;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/course/cancel")]
        public string Cancel([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            var courseId = StringTools.GetInt("courseId", ref formData);
            var userId = StringTools.GetInt("userId", ref formData);

            if (this.UserCanCancelCourse(userId, courseId))
            {
                try
                {
                    var course = atlasDB.Course
                                        .Include(c => c.DORSCourses)
                                        .Include(c => c.CourseVenue)
                                        .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                                        .Include(c => c.CourseDORSForceContracts)
                                        .Where(c => c.Id == courseId)
                                        .FirstOrDefault();

                    var isDorsCourse = false;
                    if (course.CourseVenue.Count() > 0) {
                        if(course.CourseVenue.First().Venue != null)
                        {
                            if (course.CourseDORSForceContracts.Count() > 0)
                            {
                                isDorsCourse = isCourseADORSCourse(course.CourseVenue.First().Venue, course.CourseType, course.CourseDORSForceContracts.First());
                            }                            
                        }
                    }

                    var cancelledCourse = new CancelledCourse
                    {
                        CancelledByUserId = userId,
                        CourseId = courseId,
                        DateCancelled = DateTime.Now,
                        DORSCourse = isDorsCourse
                    };

                    atlasDB.CancelledCourses.Add(cancelledCourse);

                    if (isDorsCourse)
                    {
                        var dorsCancelledCourse = new DORSCancelledCourse();
                        dorsCancelledCourse.CourseId = courseId;
                        dorsCancelledCourse.DORSNotified = false;
                        atlasDB.DORSCancelledCourses.Add(dorsCancelledCourse);
                    }

                    atlasDB.SaveChanges();
                    return "Success";
                }
                catch (Exception ex)
                {
                    return "Failed: " + ex.Message;
                }
            }
            else
            {
                return "Failed: You cannot cancel this course.";
            }
        }

        private bool UserCanCancelCourse(int userId, int courseId)
        {
            var canCancel = false;

            var course = atlasDB.Course
                .Where(x => x.Id == courseId).FirstOrDefault();

            //Check if the User is a System or Organisation Admin

            var userHasAdminStatus = (atlasDB.SystemAdminUsers.Any(x => x.UserId == userId)
                                  || atlasDB.OrganisationAdminUsers.Any(x => x.UserId == userId && x.OrganisationId == course.OrganisationId))
                                  && atlasDB.Users.Any(x => x.Id == userId && x.Disabled != true);

            //Check if there are any clients allocated to the course
            var clientsAllocated = atlasDB.CourseClients
                                            .Include(cc => cc.CourseClientRemoveds)
                                            .Any(cc => cc.CourseId == courseId && cc.CourseClientRemoveds.Count() == 0);

            if (userHasAdminStatus && !clientsAllocated)
            {
                canCancel = true;
            }

            return canCancel;
        }

        [Route("api/course/addDocument")]
        [HttpPost]
        [AuthorizationRequired]
        public int AddDocument()
        {
            var documentId = -1;
            var message = "";
            var httpRequest = HttpContext.Current.Request;
            var documentTempFolder = Path.GetTempPath(); //ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var title = httpRequest.Form["Title"];
            var description = httpRequest.Form["Description"];
            var fileName = httpRequest.Form["FileName"];
            var originalFileName = httpRequest.Form["OriginalFileName"];
            int courseId = -1;
            int updatedByUserId = StringTools.GetInt(httpRequest.Form["UpdatedByUserId"]);
            int organisationId = StringTools.GetInt(httpRequest.Form["OrganisationId"]);

            if (Int32.TryParse(httpRequest.Form["CourseId"], out courseId))
            {
                // check to see that there isn't a document with this title or filename
                var documentsWithTitleOrFilename = atlasDB.CourseDocuments
                                                            .Include(cd => cd.Document)
                                                            .Where(cd => cd.CourseId == courseId && (cd.Document.Title == title || cd.Document.FileName == fileName))
                                                            .ToList();

                if (documentsWithTitleOrFilename.Count == 0)
                {
                    // Create the Azure blob container:
                    var documentManagementController = new DocumentManagementController();
                    try
                    {
                        documentManagementController.CreateContainer(containerName, updatedByUserId);
                    }
                    catch (Exception ex)
                    {
                        if (!ex.Message.Contains("Container already exists"))
                        {
                            message = ex.Message;
                        }
                    }
                    if (string.IsNullOrEmpty(message))  // no errors so continue...
                    {
                        // save the file as Course<CourseId>_<File Name>
                        var blobName = "org" + organisationId + "/course/Course" + courseId + "_" + fileName;

                        // save the file to our document cache and then upload to the cloud.
                        if (httpRequest.Files.Count == 1)
                        {
                            var filePath = "";
                            var postedFileSize = 0;
                            foreach (string file in httpRequest.Files)
                            {
                                var postedFile = httpRequest.Files[file];
                                postedFileSize = postedFile.ContentLength;
                                var postedFileName = postedFile.FileName;
                                if (postedFileName.Contains("\\"))    // in IE the filename is a full local file path
                                {
                                    postedFileName = postedFileName.Substring(postedFileName.LastIndexOf("\\"));
                                }
                                if (!postedFile.FileName.ToLower().EndsWith(".exe"))
                                {
                                    filePath = documentTempFolder + "/" + postedFileName;
                                    postedFile.SaveAs(filePath);
                                }
                                else
                                {
                                    message = "Error: executable files are not allowed to be uploaded.";
                                    break;
                                }
                            }
                            if (!string.IsNullOrEmpty(filePath) && string.IsNullOrEmpty(message))
                            {
                                var uploaded = documentManagementController.UploadBlob(containerName, blobName, filePath, updatedByUserId);

                                //save to atlasDB
                                if (uploaded)
                                {
                                    var courseDocument = new CourseDocument();
                                    var document = new Document();
                                    var documentOwner = new DocumentOwner();
                                    var fileStoragePath = new FileStoragePath();
                                    var fileStoragePathOwner = new FileStoragePathOwner();

                                    courseDocument.CourseId = courseId;
                                    documentOwner.OrganisationId = organisationId;
                                    fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                                    fileStoragePath.Path = blobName;//containerName + blobName;
                                    fileStoragePathOwner.OrganisationId = organisationId;
                                    fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                                    document.DateUpdated = DateTime.Now;
                                    document.Description = description;
                                    document.Title = title;
                                    document.OriginalFileName = originalFileName;
                                    document.UpdatedByUserId = updatedByUserId;
                                    document.FileName = fileName;
                                    document.CourseDocuments.Add(courseDocument);
                                    document.DocumentOwners.Add(documentOwner);
                                    document.FileStoragePath = fileStoragePath;
                                    document.FileSize = postedFileSize;
                                    document.DateAdded = DateTime.Now;

                                    atlasDB.Documents.Add(document);
                                    atlasDB.SaveChanges();

                                    // now lets delete the uploaded file from the file cache.
                                    if (File.Exists(filePath))
                                    {
                                        File.Delete(filePath);
                                    }

                                    documentId = document.Id;
                                }
                                else
                                {
                                    message = "Error: File not uploaded, please contact support.";
                                }
                            }
                            else
                            {
                                if (string.IsNullOrEmpty(message))  // this is to allow for the .exe check message
                                {
                                    message = "Directory error, please contact support.";
                                }
                            }
                        }
                        else
                        {
                            message = "Please select a file to upload.";
                        }
                    }
                }
                else
                {
                    message = "Document not added. A file with that filename or title already exists on the system.";
                }
            }
            else
            {
                message = "Document not added: Course could be found.";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return documentId;
        }

        // commented out function below may be useful in the future...
        //[HttpGet]
        //[AuthorizationRequired]
        //[Route("api/course/getCourseReference/{courseId}")]
        //public string GetCourseReference(int courseId)
        //{
        //    var courseReference = "";

        //    var course = atlasDB.Course
        //                            .Include(c => c.CourseDate)
        //                            .Include(c => c.CourseType)
        //                            .Include(c => c.CourseVenue)
        //                            .Include(c => c.Organisation)
        //                            .Include(c => c.Organisation.OrganisationSelfConfigurations)
        //                            .Include(c => c.Organisation.OrganisationSelfConfigurations.Select(osc => osc.CourseReferenceGenerator))
        //                            .Include(c => c.Organisation.CourseReferencePrefixSuffixSeparators)
        //                            .Include(c => c.Organisation.CourseReferenceDateFormats)
        //                            .Include(c => c.Organisation.CourseReferenceNumbers)
        //                            .Where(c => c.Id == courseId)
        //                            .FirstOrDefault();

        //    courseReference = CourseReferenceGenerator.generateCourseReference(course, atlasDB);
        //    return courseReference;
        //}

        [HttpGet]
        [AuthorizationRequired]
        [AllowCrossDomainAccess]
        [Route("api/course/getCourseReference/{organisationId}/{courseTypeCode}")]
        public string GetCourseReference(int organisationId, string courseTypeCode)
        {
            var courseReference = "";
            var organisation = atlasDB.Organisations
                                    .Include(o => o.OrganisationSelfConfigurations)
                                    .Include(o => o.OrganisationSelfConfigurations.Select(osc => osc.CourseReferenceGenerator))
                                    .Include(o => o.CourseReferencePrefixSuffixSeparators)
                                    .Include(o => o.CourseReferenceDateFormats)
                                    .Include(o => o.CourseReferenceNumbers)
                                    .Where(o => o.Id == organisationId)
                                    .FirstOrDefault();

            courseReference = CourseReferenceGenerator.GenerateCourseReference(organisation, courseTypeCode, atlasDB);
            return courseReference;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/course/GetAvailableCourses/{organisationId}/{userId}/{courseTypeId}/{courseTypeCategoryId}/{DORSCoursesOnly}/{clientId}")]
        /// <summary>
        /// Returns a list of Available Courses, which have available places, 
        /// the Course Start Date is not in the past and are in the same Course Type and Course Type Category 
        /// and if the current course is a DORS Course then all the courses must be DORS Courses
        /// </summary>
        /// <returns></returns>
        public List<CourseJSON> GetAvailableCourses(int organisationId, int userId, int courseTypeId, int courseTypeCategoryId, bool DORSCoursesOnly, int clientId)
        {
            List<CourseJSON> availableCourses = new List<CourseJSON>();

            //Check to see if client is already booked on same course type, 
            //if they are, then an empty list will be returned later.

            var existingCourseClientCount = atlasDBViews.vwCourseClients
                                                        .Where(cc => cc.OrganisationId == organisationId
                                                                    && cc.ClientId == clientId
                                                                    && cc.CourseTypeId == courseTypeId
                                                                    && cc.StartDate >= DateTime.Now)
                                                        .Count();

            bool isAdmin = false;
            var user = atlasDB.SystemAdminUsers.Where(sau => sau.UserId == userId).FirstOrDefault();
            if (user != null) isAdmin = true;

            //var clientDorsData = atlasDB.ClientDORSDatas
            //                            .Include(cdd => cdd.DORSScheme)
            //                            .Include(cdd => cdd.DORSScheme.DORSSchemeCourseTypes)
            //                            .Where(cdd => cdd.ClientId == clientId &&
            //                                            cdd.DORSScheme.DORSSchemeCourseTypes.Any(dsct => dsct.CourseTypeId == courseTypeId))
            //                            .FirstOrDefault();

            //DateTime? expiryDate = null;
            //if (clientDorsData != null)
            //{
            //    expiryDate = clientDorsData.ExpiryDate;
            //}

            var lastClientDetailEntry = atlasDBViews.vwClientDetailMinimals.Where(x => x.ClientId == clientId).OrderByDescending(x => x.CourseStartDate).FirstOrDefault();
            DateTime? lastBookingDay = null;

            if (lastClientDetailEntry != null)
            {
                lastBookingDay = lastClientDetailEntry.LastDateForCourseBooking;
            }

            var courses = atlasDBViews.vwCoursesWithPlaces
                                    .Where(
                                            c => c.OrganisationId == organisationId &&
                                                 c.CourseTypeId == courseTypeId &&
                                                 (lastBookingDay == null ? true : (c.StartDate <= lastBookingDay)) && existingCourseClientCount == 0
                                    )
                                    .OrderBy(c => c.StartDate)
                                    .ToList();

            if (courses.Count() > 0)
            {
                availableCourses = courses.Select(course => new CourseJSON()
                {
                    Id = course.CourseId
                    , courseReference = course.CourseReference
                    , courseDateStart = ((DateTime)course.StartDate).ToString("dddd, dd/MM/yyyy HH:mm")
                    , courseDateEnd = ((DateTime)course.EndDate).ToString("dd/MM/yyyy HH:mm")
                    , courseDorsCourse = course.DORSCourse != null && (Boolean)course.DORSCourse
                    , venueTitle = course.VenueName
                    , courseTypeTitle = course.CourseType
                    , courseTypeCategoryName = course.CourseTypeCategory
                    , courseTypeId = course.CourseTypeId
                    , courseTypeCategoryId = course.CourseTypeCategoryId == null ? -1 : (int)course.CourseTypeCategoryId
                    , lastBookingDate = course.CourseLastBookingDate
                    , coursePlaces = course.CourseMaximumPlaces
                    , coursePlacesBooked = course.NumberofClientsonCourse == null ? 0 : (int)course.NumberofClientsonCourse
                    , courseReserved = course.CourseReservedPlaces
                    , coursePlacesAvailable = course.PlacesRemaining == null ? 0 : (int)course.PlacesRemaining
                }).ToList();
            }
            return availableCourses;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/course/GetAvailableCoursesForTransfer/{organisationId}/{userId}/{courseTypeId}/{courseTypeCategoryId}/{DORSCoursesOnly}/{clientId}")]
        /// <summary>
        /// Returns a list of Available Courses, which have available places, 
        /// the Course Start Date is not in the past and are in the same Course Type and Course Type Category 
        /// and if the current course is a DORS Course then all the courses must be DORS Courses.
        /// For Transfer purposes only!
        /// </summary>
        /// <returns></returns>
        public List<CourseJSON> GetAvailableCoursesForTransfer(int organisationId, int userId, int courseTypeId, int courseTypeCategoryId, bool DORSCoursesOnly, int clientId)
        {
            List<CourseJSON> availableCourses = new List<CourseJSON>();
            bool isAdmin = false;
            var user = atlasDB.SystemAdminUsers.Where(sau => sau.UserId == userId).FirstOrDefault();
            if (user != null) isAdmin = true;

            var lastClientDetailEntry = atlasDBViews.vwClientDetailMinimals.Where(x => x.ClientId == clientId).OrderByDescending(x => x.CourseStartDate).FirstOrDefault();
            DateTime? lastBookingDay = null;

            if (lastClientDetailEntry != null)
            {
                lastBookingDay = lastClientDetailEntry.LastDateForCourseBooking;
            }

            var courses = atlasDBViews.vwCoursesWithPlaces
                                    .Where(
                                            c => c.OrganisationId == organisationId &&
                                                 c.CourseTypeId == courseTypeId &&
                                                 (lastBookingDay == null ? true : (c.StartDate <= lastBookingDay))
                                    )
                                    .OrderBy(c => c.StartDate)
                                    .ToList();

            if (courses.Count() > 0)
            {
                availableCourses = courses.Select(course => new CourseJSON()
                {
                    Id = course.CourseId
                    , courseReference = course.CourseReference
                    , courseDateStart = ((DateTime)course.StartDate).ToString("dddd, dd/MM/yyyy HH:mm")
                    , courseDateEnd = ((DateTime)course.EndDate).ToString("dd/MM/yyyy HH:mm")
                    , courseDorsCourse = course.DORSCourse != null && (Boolean)course.DORSCourse
                    , venueTitle = course.VenueName
                    , courseTypeTitle = course.CourseType
                    , courseTypeCategoryName = course.CourseTypeCategory
                    , courseTypeId = course.CourseTypeId
                    , courseTypeCategoryId = course.CourseTypeCategoryId == null ? -1 : (int)course.CourseTypeCategoryId
                    , lastBookingDate = course.CourseLastBookingDate
                    , coursePlaces = course.CourseMaximumPlaces
                    , coursePlacesBooked = course.NumberofClientsonCourse == null ? 0 : (int)course.NumberofClientsonCourse
                    , courseReserved = course.CourseReservedPlaces
                    , coursePlacesAvailable = course.PlacesRemaining == null ? 0 : (int)course.PlacesRemaining
                    , courseAssociatedSession = course.CourseSessionTitle
                }).ToList();
            }
            return availableCourses;
        }

        

        [HttpGet]
        [AuthorizationRequired]
        [AllowCrossDomainAccess]
        [Route("api/course/GetReminderEmailByOrganisationCourseCode/{organisationId}/{courseCode}")]
        public object GetReminderEmailByOrganisationCourseCode(int organisationId, string courseCode)
        {
            
            return atlasDB.OrganisationEmailTemplateMessages
                         .Where(oetm => oetm.Code == courseCode && oetm.OrganisationId == organisationId).FirstOrDefault();
                        
        }

        [AuthorizationRequired]
        [Route("api/course/SaveReminderEmailTemplate/")]
        [HttpPost]
        public bool SaveReminderEmailTemplate([FromBody] FormDataCollection formBody)
        {


            var organisationEmailTemplateMessage = formBody.ReadAs<OrganisationEmailTemplateMessage>();

            organisationEmailTemplateMessage.DateLastUpdated = DateTime.Now;

            atlasDB.OrganisationEmailTemplateMessages.Attach(organisationEmailTemplateMessage);
            var entry = atlasDB.Entry(organisationEmailTemplateMessage);
            entry.State = System.Data.Entity.EntityState.Modified;
    
            try
            {
                atlasDB.SaveChanges();
            
            } catch (Exception e) {

                throw (e);

            }

            return true;
        }

        [HttpGet]
        [AuthorizationRequired]
        [AllowCrossDomainAccess]
        [Route("api/course/GetReminderSMSByOrganisationCourseCode/{organisationId}/{courseCode}")]
        public object GetReminderSMSByOrganisationCourseCode(int organisationId, string courseCode)
        {
            return atlasDB.OrganisationSMSTemplateMessages
                         .Where(ostm => ostm.Code == courseCode && ostm.OrganisationId == organisationId).FirstOrDefault();
           
        }

        [AuthorizationRequired]
        [Route("api/course/SaveReminderSMSTemplate/")]
        [HttpPost]
        public bool SaveReminderSMSTemplate([FromBody] FormDataCollection formBody)
        {


            var organisationSMSTemplateMessage = formBody.ReadAs<OrganisationSMSTemplateMessage>();

            organisationSMSTemplateMessage.DateLastUpdated = DateTime.Now;

            atlasDB.OrganisationSMSTemplateMessages.Attach(organisationSMSTemplateMessage);
            var entry = atlasDB.Entry(organisationSMSTemplateMessage);
            entry.State = System.Data.Entity.EntityState.Modified;

            try
            {
                atlasDB.SaveChanges();

            }
            catch (Exception e)
            {

                throw (e);

            }

            return true;
        }

        [HttpGet]
        [Route("api/course/GetCoursesWithPlaces/{organisationId}/{courseTypeId}/{regionId}/{venueId}/{interpreter}/{clientId}")]
        public List<vwCoursesWithPlace> GetCoursesWithPlaces(int organisationId, int courseTypeId, int regionId, int venueId, string interpreter, int clientId)
        {
            bool? hasInterpreters = null;
            if (interpreter == "interpreter") hasInterpreters = true;
            else if (interpreter == "noInterpreter") hasInterpreters = false;
            DateTime? lastBookingDay = null;


            // if a clientId is passed in (ie is greater than -1)
            // see if the client is a DORS client
            // if it is only return courses prior to the DORS expiry date
            //DateTime? clientDORSExpiryDate = null;

            bool? isDORSClient = null;
            if(clientId > 0)
            {
                var client = atlasDB.Clients
                                    .Include(c => c.ClientDORSDatas)
                                    .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSScheme))
                                    .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSScheme.DORSSchemeCourseTypes))
                                    .Where(c => c.Id == clientId)
                                    .FirstOrDefault();
                if(client != null)
                {
                    var lastClientDetailEntry = atlasDBViews.vwClientDetailMinimals.Where(x => x.ClientId == clientId).OrderByDescending(x => x.CourseStartDate).FirstOrDefault();

                    if (lastClientDetailEntry != null)
                    {
                        lastBookingDay = lastClientDetailEntry.LastDateForCourseBooking;
                    }

                    isDORSClient = false;
                    if (client.ClientDORSDatas.Count() > 0)
                    {
                        isDORSClient = true;
                    }
                }
            }

            var availableCourses = atlasDBViews.vwCoursesWithPlaces
                                            .Where(
                                                cwp =>  (cwp.OrganisationId == organisationId) &&
                                                        (courseTypeId > 0 ? cwp.CourseTypeId == courseTypeId : true) &&
                                                        (regionId > 0 ? cwp.RegionId == regionId : true) &&
                                                        (venueId > 0 ? cwp.VenueId == venueId : true) &&
                                                        (hasInterpreters == null ? true : cwp.HasInterpreter == hasInterpreters) &&
                                                        (lastBookingDay != null ? cwp.EndDate <= lastBookingDay : true) &&
                                                        // if a DORS Client only show dors courses and visa versa
                                                        (isDORSClient == null ? true : isDORSClient == (cwp.DORSCourse == null ? false : (bool)cwp.DORSCourse))        
                                            )
                                            //.Take(100) -- Unlikely there will be a huge amount of 
                                            //courses before expiry date so removed limit and was causing problems with clients
                                            //unable to find course via filtering.
                                            .ToList();
            return availableCourses;
        }

        [AuthorizationRequired]
        [Route("api/course/GetTrainingSessions/")]
        [HttpGet]
        public object GetTrainingSessions()
        {
            return atlasDBViews.vwTrainingSessions.ToList();
                          
        }

        [AuthorizationRequired]
        [Route("api/course/GetCourseAllocatedTrainersAndInterpreters/{courseId}")]
        [HttpGet]
        public object GetCourseAllocatedTrainerAndInterpreters(int courseId)
        {
            var courseTrainersAndInterpreters = atlasDBViews.vwCourseAllocatedTrainerAndInterpreters
                                                        .Where(ctai => ctai.CourseId == courseId)
                                                        .Select(ctai => new CourseTrainersAndInterpretersJSON
                                                        {
                                                            Id = ctai.TrainerOrInterpreterId,
                                                            Name = ctai.TrainerOrInterpreterCourseDisplayName
                                                        })
                                                        .ToList();
            return courseTrainersAndInterpreters;
        }

        [AllowCrossDomainAccess]
        [HttpGet]
        [Route("api/course/GetByOrganisation/{organisationId}")]
        /// <summary>
        /// Gets courses that are one month in the past onwards for an organisation
        /// </summary>
        /// <param name="organisationId"></param>
        /// <returns></returns>
        public List<vwCourseDetail> GetByOrganisation(int organisationId)
        {
            var oneMonthAgo = DateTime.Now.AddMonths(-1);
            var courses = atlasDBViews.vwCourseDetails
                                    .Where(cd => cd.OrganisationId == organisationId && cd.StartDate > oneMonthAgo)
                                    .ToList();
            return courses;
        }


        /// <summary>
        /// This function will return incorrect values if the client.CourseClientTransferreds and client.CourseClientRemoveds are not included with the course's courseclient object
        /// </summary>
        /// <param name="course"></param>
        /// <returns></returns>
        private int clientsOnCourse(Course course)
        {
            int clients = 0;
            if (course != null)
            {
                foreach (var courseClient in course.CourseClients)
                {
                    var client = courseClient.Client;
                    var sinceTransferred = false;
                    var sinceRemoved = false;
                    sinceTransferred = client.CourseClientTransferreds.Any(cct => cct.DateTransferred > courseClient.DateAdded && cct.TransferFromCourseId == course.Id);
                    sinceRemoved = client.CourseClientRemoveds.Any(ccr => ccr.DateRemoved > courseClient.DateAdded && ccr.CourseId == course.Id);
                    if (!sinceRemoved && !sinceTransferred)
                    {
                        clients++;
                    }
                }
            }
            return clients;
        }

        /// <summary>
        /// Checks to see if the course is a DORS course by looking at the CourseType, ForceContract and Venue.
        /// </summary>
        /// <param name="venue"></param>
        /// <param name="courseType"></param>
        /// <param name="dorsForceContract"></param>
        /// <returns></returns>
        private bool isCourseADORSCourse(Venue venue, CourseType courseType, CourseDORSForceContract courseDORSForceContract)
        {
            var dorsCourse = false;
            if (venue != null && courseType != null && courseDORSForceContract != null)
            {
                if (venue.DORSVenue)
                {
                    if (courseType.DORSOnly == null ? false : (bool)courseType.DORSOnly)
                    {
                        dorsCourse = true;
                    }
                }
            }
            return dorsCourse;
        }

        private string startDateToString(CourseDate courseDate)
        {
            var dateString = "";
            if (courseDate != null)
            {
                dateString = courseDate.DateStart != null ? ((DateTime)courseDate.DateStart).ToString("dd/MM/yyyy HH:mm") : "";
            }
            return dateString;
        }

        private string endDateToString(CourseDate courseDate)
        {
            var dateString = "";
            if (courseDate != null)
            {
                dateString = courseDate.DateEnd != null ? ((DateTime)courseDate.DateEnd).ToString("dd/MM/yyyy HH:mm") : "";
            }
            return dateString;
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
    }
    public class CourseReferenceGenerator
    {
        /// <summary>
        /// I had to refactor this function but thought this old way might be useful in the future...
        /// </summary>
        /// <param name="course"></param>
        /// <param name="atlasDB"></param>
        /// <returns></returns>
        public static string GenerateCourseReference(Course course, Atlas_DevEntities atlasDB)
        {
            var courseReference = "";
            if (course.Organisation != null)
            {
                var organisation = course.Organisation;
                if (organisation.OrganisationSelfConfigurations != null && organisation.CourseReferencePrefixSuffixSeparators != null)
                {
                    var osc = organisation.OrganisationSelfConfigurations.FirstOrDefault();
                    var courseReferencePrefixSuffixSeparators = organisation.CourseReferencePrefixSuffixSeparators.FirstOrDefault();
                    var courseVenue = course.CourseVenue.FirstOrDefault();
                    var courseReferenceDateFormat = organisation.CourseReferenceDateFormats.FirstOrDefault();
                    var courseType = course.CourseType;
                    var venueCode = "";
                    var courseTypeCode = "";
                    var formattedDate = "";
                    if (courseVenue != null)
                    {
                        var venue = courseVenue.Venue;
                        if (venue != null)
                        {
                            venue = courseVenue.Venue;
                            venueCode = venue.Code;
                        }
                    }
                    if (course.CourseType != null)
                    {
                        courseTypeCode = course.CourseType.Code;
                    }
                    if (courseReferenceDateFormat != null)    // courseReferenceDateFormat
                    {
                        var courseDate = course.CourseDate.FirstOrDefault();
                        if (courseDate != null)
                        {
                            if (courseDate.DateStart != null)
                            {
                                formattedDate = ((DateTime)courseDate.DateStart).ToString(courseReferenceDateFormat.DateFormat);
                            }
                        }
                    }
                    if (courseReferencePrefixSuffixSeparators != null)
                    {
                        var prefix = courseReferencePrefixSuffixSeparators.Prefix;
                        var suffix = courseReferencePrefixSuffixSeparators.Suffix;
                        var separator = courseReferencePrefixSuffixSeparators.Separator;
                        if (osc != null)
                        {
                            if (osc.CourseReferenceGenerator != null)
                            {
                                switch (osc.CourseReferenceGenerator.Code)
                                {
                                    case "AN":
                                        courseReference = GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "ANP":
                                        courseReference = prefix + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "ANS":
                                        courseReference = GetNumber(organisation, atlasDB) + suffix;
                                        break;
                                    case "ANPS":
                                        courseReference = prefix + GetNumber(organisation, atlasDB) + suffix;
                                        break;
                                    case "PSAN":
                                        courseReference = prefix + separator + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "ANSP":
                                        courseReference = GetNumber(organisation, atlasDB).ToString() + separator + suffix;
                                        break;
                                    case "VAN":
                                        courseReference = venueCode + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "VSAN":
                                        courseReference = venueCode + separator + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "TAN":
                                        courseReference = courseTypeCode + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "TSAN":
                                        courseReference = courseTypeCode + separator + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "TD":
                                        courseReference = courseTypeCode + formattedDate;
                                        break;
                                    case "TSD":
                                        courseReference = courseTypeCode + separator + formattedDate;
                                        break;
                                }
                            }
                        }
                    }
                }
            }
            return courseReference;
        }

        public static string GenerateCourseReference(Data.Organisation organisation, string courseTypeCode, Atlas_DevEntities atlasDB)
        {
            var courseReference = "";
            if (organisation != null)
            {
                if (organisation.OrganisationSelfConfigurations != null && organisation.CourseReferencePrefixSuffixSeparators != null)
                {
                    var osc = organisation.OrganisationSelfConfigurations.FirstOrDefault();
                    var courseReferencePrefixSuffixSeparators = organisation.CourseReferencePrefixSuffixSeparators.FirstOrDefault();
                    var venueCode = "";
                    var formattedDate = "";

                    if (courseReferencePrefixSuffixSeparators != null)
                    {
                        var prefix = courseReferencePrefixSuffixSeparators.Prefix;
                        var suffix = courseReferencePrefixSuffixSeparators.Suffix;
                        var separator = courseReferencePrefixSuffixSeparators.Separator;
                        if (osc != null)
                        {
                            if (osc.CourseReferenceGenerator != null)
                            {
                                switch (osc.CourseReferenceGenerator.Code)
                                {
                                    case "AN":
                                        courseReference = GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "ANP":
                                        courseReference = prefix + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "ANS":
                                        courseReference = GetNumber(organisation, atlasDB) + suffix;
                                        break;
                                    case "ANPS":
                                        courseReference = prefix + GetNumber(organisation, atlasDB) + suffix;
                                        break;
                                    case "PSAN":
                                        courseReference = prefix + separator + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "ANSP":
                                        courseReference = GetNumber(organisation, atlasDB).ToString() + separator + suffix;
                                        break;
                                    case "VAN":
                                        courseReference = venueCode + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "VSAN":
                                        courseReference = venueCode + separator + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "TAN":
                                        courseReference = courseTypeCode + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "TSAN":
                                        courseReference = courseTypeCode + separator + GetNumber(organisation, atlasDB).ToString();
                                        break;
                                    case "TD":
                                        courseReference = courseTypeCode + formattedDate;
                                        break;
                                    case "TSD":
                                        courseReference = courseTypeCode + separator + formattedDate;
                                        break;
                                }
                            }
                        }
                    }
                }
            }
            return courseReference;
        }

        

        private static int GetNumber(Data.Organisation organisation, Atlas_DevEntities atlasDB)
        {
            int referenceNumber = 1;
            if (organisation.CourseReferenceNumbers != null)
            {
                var courseReferenceNumber = organisation.CourseReferenceNumbers.FirstOrDefault();
                if (courseReferenceNumber != null)
                {
                    referenceNumber = courseReferenceNumber.ReferenceNumber + 1;
                    courseReferenceNumber.ReferenceNumber = referenceNumber;

                    var entry = atlasDB.Entry(courseReferenceNumber);
                    entry.State = EntityState.Modified;
                }
                else
                {
                    courseReferenceNumber = new CourseReferenceNumber();
                    courseReferenceNumber.ReferenceNumber = referenceNumber;
                    courseReferenceNumber.OrganisationId = organisation.Id;

                    atlasDB.CourseReferenceNumbers.Add(courseReferenceNumber);
                }
                atlasDB.SaveChanges();
            }
            return referenceNumber;
        }



    }
    public class OrganisationContact
    {
        public string Area { get; set; }
        public string AreaId { get; set; }
        public string OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public string OrganisationAddress { get; set; }
        public string OrganisationPostCode { get; set; }
        public string OrganisationEmail { get; set; }
        public string OrganisationPhone { get; set; }
    }
}