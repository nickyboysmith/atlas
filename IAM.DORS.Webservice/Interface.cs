using IAM.DORS.Webservice.Models;
//using IAM.DORS.Webservice.DORSService;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
//using dorsWebservice = IAM.DORS.Webservice.uk.org.ndors.supplier;
using dors.npia.police.uk.services;
using DORSCommon = DORS.Common;

namespace IAM.DORS.Webservice
{
    public class Interface
    {
        protected string username, password;

        public enum DORSAttendanceStates
        {
            BookingPending = 1,
            Booked = 2,
            BookedAndPaid = 3,
            AttendedandCompleted = 4,
            AttendedAndNotCompleted = 4,
            DidNotAttend = 6,
            OfferWithdrawn = 7
        }

        //protected dorsWebservice.OutDorsService_2013_12 DORSService;
        protected OutDorsServiceContractClient DORSService;

        public Interface(string username, string password, bool mockData = true)
        {
            this.username = username;
            this.password = password;
            this.DORSService = getDORSService(mockData);
        }

        OutDorsServiceContractClient getDORSService(bool mockData = true)
        {
            if (mockData)
            {
                var mockService = new Data.MockService();
                mockService.ClientCredentials.UserName.UserName = username;
                mockService.ClientCredentials.UserName.Password = password;
                return mockService;
            }

            var service = new OutDorsServiceContractClient();
            service.ClientCredentials.UserName.UserName = username;
            service.ClientCredentials.UserName.Password = password;
            return service;
        }

        public string GetIdentity()
        {
            var identity = "";
            try
            {
                identity = DORSService.GetIdentity();
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return identity;
        }

        #region Booking functions 
        public bool AddBooking(int attendanceId, int courseId, DateTime bookingDate, DateTime? paidDate, string comments)
        {
            var added = false;

            var addBooking = new AddBooking();
            addBooking.AttendanceID = attendanceId;
            addBooking.CourseID = courseId;
            addBooking.BookingDate = bookingDate;
            addBooking.PaidDate = paidDate;
            addBooking.Comments = comments;

            try
            {
                added = DORSService.AddBooking(addBooking);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            
            return added;
        }

        public bool UpdateBooking(int attendanceId, int courseId, DateTime? bookingDate, DateTime? paidDate, string comments, int attendanceStatusId)
        {
            var updated = false;
            var updateBooking = new UpdateBooking();
            updateBooking.AttendanceID = attendanceId;
            updateBooking.CourseID = courseId;
            updateBooking.BookingDate = bookingDate;
            updateBooking.PaidDate = paidDate;
            updateBooking.Comments = comments;
            updateBooking.AttendanceStatusID = attendanceStatusId;

            try
            {
                updated = DORSService.UpdateBooking(updateBooking);
            }
            catch(Exception ex)
            {
                throw ex;
            }

            return updated;
        }

        public bool CancelBooking(int attendanceId)
        {
            var cancelled = false;
            try
            {
                cancelled = DORSService.CancelBooking(attendanceId);
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return cancelled;
        }

        #endregion

        #region Course functions
        public int AddCourse(string courseTitle, DateTime courseDateTime, int courseCapacity, int siteId, int forceContractId)
        {
            var courseId = 0;
            var course = new CourseEntity();
            course.CourseTitle = courseTitle;
            course.CourseDateTime = courseDateTime;
            course.CourseCapacity = courseCapacity;
            course.SiteID = siteId;
            course.ForceContractID = forceContractId;

            try
            {
                courseId = DORSService.AddCourse(course);
            }
            catch(Exception ex)
            {
                throw ex;
            }

            return courseId;
        }

        public Course UpdateCourse(int courseId, string courseTitle, DateTime courseDateTime, int courseCapacity, int siteId, int forceContractId)
        {
            var updatedCourse = new CourseResponseEntity();
            var course = new CourseEntity();
            course.CourseID = courseId;
            course.CourseTitle = courseTitle;
            course.CourseDateTime = courseDateTime;
            course.CourseCapacity = courseCapacity;
            course.SiteID = siteId;
            course.ForceContractID = forceContractId;

            try
            {
                updatedCourse = DORSService.UpdateCourse(course);
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return new Course() {
                Id = updatedCourse.CourseID,
                Availability = updatedCourse.CourseAvailability,
                Capacity = updatedCourse.CourseCapacity,
                DateTime = updatedCourse.CourseDateTime,
                ForceContractId = updatedCourse.ForceContractID,
                SiteId = updatedCourse.SiteID,
                Title = updatedCourse.CourseTitle,
                TutorForename = "",
                TutorSurname = ""
                // TODO: bring across the courseResponse's Trainer List?
            };
        }

        public bool CancelCourse(int courseId)
        {
            var cancelled = false;
            try
            {
                cancelled = DORSService.CancelCourse(courseId);
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return cancelled;
        }

        #endregion

        #region Client functions

        /// <summary>
        /// Interfaces to the webservice's function LookupStatus
        /// </summary>
        /// <returns></returns>
        public List<ClientStatus> ClientLookupStatus(string driversLicense)
        {
            var statusList = new List<ClientStatus>();
            try
            {
                statusList = DORSService.LookupStatus(driversLicense)
                                        .Select(lookupStatus => new ClientStatus {
                                            AttendanceId = lookupStatus.AttendanceID,
                                            AttendanceStatus = lookupStatus.AttendanceStatus,
                                            AttendanceStatusId = lookupStatus.AttendanceStatusID,
                                            ExpiryDate = lookupStatus.ExpiryDate,
                                            ForceId = lookupStatus.ForceID,
                                            ForceName = lookupStatus.Forcename,
                                            SchemeId = lookupStatus.SchemeID,
                                            SchemeName = lookupStatus.SchemeName
                                        }).ToList();
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return statusList;
        }

        #endregion

        #region Lookup functions

        public List<Attendance> GetAttendanceStatusList()
        {
            var attendanceList = new List<Attendance>();
            try
            {
                attendanceList = DORSService.GetAttendanceStatusList()
                                                    .Select(asl => new Attendance
                                                    {
                                                        Status = asl.AttendanceStatus,
                                                        StatusID = asl.AttendanceStatusID
                                                    }).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return attendanceList;
        }



        public int GetAttendanceId(string driversLicenseNumber, int schemeId)
        {
            var attendanceId = -1;
            var attendanceIdRequest = new dors.npia.police.uk.services.GetAttendanceIDRequest();
            attendanceIdRequest.drivingLicenseNumber = driversLicenseNumber;
            attendanceIdRequest.schemeID = schemeId;

            try
            {
                attendanceId = DORSService.GetAttendanceID(attendanceIdRequest);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return attendanceId;
        }

        public int GetCourseId(string courseTitle, int siteId, DateTime courseDateTime)
        {
            var courseId = -1;
            var courseIdRequest = new dors.npia.police.uk.services.GetCourseIDRequest();
            courseIdRequest.courseTitle = courseTitle;
            courseIdRequest.siteID = siteId;
            courseIdRequest.courseDateTime = courseDateTime;

            try
            {
                courseId = DORSService.GetCourseID(courseIdRequest);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return courseId;
        }

        public List<Scheme> GetSchemeList()
        {
            var schemeList = new List<Scheme>();
            try
            {
                schemeList = DORSService.GetSchemeList().Select(scheme => new Scheme {Id = scheme.SchemeID, Name = scheme.SchemeName }).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return schemeList;
        }

        public List<ForceContract> GetForceContractList()
        {
            var forceContractList = new List<ForceContract>();
            try
            {
                forceContractList = DORSService.GetForceContractList().Select(forceContract => new ForceContract
                {
                    ForceContractID = forceContract.ForceContractID,
                    ForceID = forceContract.ForceID,
                    SchemeID = forceContract.SchemeID,
                    StartDate = forceContract.StartDate,
                    EndDate = forceContract.EndDate,
                    CourseAdminFee = forceContract.CourseAdminFee,
                    AccreditationID = forceContract.AccreditationID
                }).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return forceContractList;
        }

        public List<Site> GetSiteList()
        {
            var siteList = new List<Site>();
            try
            {
                siteList = DORSService.GetSiteList().Select(site => new Site { Id = site.SiteID, Name = site.SiteName }).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return siteList;
        }

        public List<Force> GetForceList()
        {
            var forceList = new List<Force>();
            try
            {
                forceList = DORSService.GetForceList().Select(force => new Force { Id = force.ForceID, Name = force.ForceName, PNCCode = force.PNCCode }).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return forceList;
        }

        public List<OfferWithdrawn> GetOfferWithdrawn(DateTime date)
        {
            var offerWithdrawnList = new List<OfferWithdrawn>();
            var offerWithdrawnRequest = new dors.npia.police.uk.services.GetOfferWithdrawnRequest();
            offerWithdrawnRequest.Date = date;
            try
            {
                offerWithdrawnList = DORSService.GetOfferWithdrawn(offerWithdrawnRequest)
                                                .Select(offerWithdrawn => new OfferWithdrawn
                                                {
                                                    AttendanceID = offerWithdrawn.AttendanceID,
                                                    AttendanceStatusID_Old = offerWithdrawn.AttendanceStatusID_Old,
                                                    DrivingLicenseNumber = offerWithdrawn.DrivingLicenseNumber,
                                                    SchemeID = offerWithdrawn.SchemeID
                                                }).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return offerWithdrawnList;
        }

        // this function has been removed from DORS+ V2
        public void GetCourseListBySiteId(int siteId)
        {
            //var courseList = new List<Course>();
            //try
            //{
            //    courseList = DORSService.GetCourseListBySiteID(siteId).Select(course => new Course
            //    {
            //        Availability = course.CourseAvailability,
            //        Capacity = course.CourseCapacity,
            //        DateTime = course.CourseDateTime,
            //        Id = course.CourseID,
            //        Title = course.CourseTitle,
            //        ForceContractId = course.ForceContractID,
            //        SiteId = course.SiteID
            //    }).ToList();
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}
        }

        public Course GetCourseById(int courseId)
        {
            var getCourseWithAttendeesResponseEntity = DORSService.GetCourseByID(courseId);
            var course = new Course() {
                Availability = getCourseWithAttendeesResponseEntity.CourseAvailability,
                Capacity = getCourseWithAttendeesResponseEntity.CourseCapacity,
                DateTime = getCourseWithAttendeesResponseEntity.CourseDateTime,
                ForceContractId = getCourseWithAttendeesResponseEntity.ForceContractID,
                Id = getCourseWithAttendeesResponseEntity.CourseID,
                SiteId = getCourseWithAttendeesResponseEntity.SiteID,
                Title = getCourseWithAttendeesResponseEntity.CourseTitle,
                AttendeeList = getCourseWithAttendeesResponseEntity.AttendeeList,
                TrainerList = convertToTrainerLicenceList(getCourseWithAttendeesResponseEntity.TrainerList)
            };
            
            return course;
        }

        List<TrainerLicence> convertToTrainerLicenceList(TrainerLicenseEntityCollection dorsTrainerLicences)
        {
            var trainerLicenceList = new List<TrainerLicence>();
            foreach(var dorsTrainerLicence in dorsTrainerLicences)
            {
                trainerLicenceList.Add(new TrainerLicence()
                {
                    Id = dorsTrainerLicence.TrainerID,
                    Forename = dorsTrainerLicence.Forename,
                    LicenceType = dorsTrainerLicence.LicenceType,
                    ExpiryDate = dorsTrainerLicence.ExpiryDate,
                    Surname = dorsTrainerLicence.Surname,
                    LicenseCode = dorsTrainerLicence.LicenseCode,
                    SchemeId = dorsTrainerLicence.SchemeID,
                    Status = dorsTrainerLicence.Status
                });
            }
            return trainerLicenceList;
        }

        #endregion

        #region Trainer functions

        public bool UpdateTrainers(int dorsCourseId, List<UpdateTrainer> trainers)
        {
            bool updated = false;
            UpdateTrainersEntity updateTrainersRequest = new UpdateTrainersEntity();
            var updateTrainersResponse = new CourseResponseEntity();

            updateTrainersRequest.CourseID = dorsCourseId;
            updateTrainersRequest.TrainerOnCourseCollection = new TrainerOnCourseCollection();

            foreach(var trainer in trainers)
            {
                var trainerOnCourseEntity = new WTG.DORS.WCF_6_7.DataContracts.TrainerOnCourseEntity();
                trainerOnCourseEntity.TrainerID = trainer.DORSTrainerId;
                // licence type: theory = 1, Practical = 2
                
                trainerOnCourseEntity.LicenceType = (DORSCommon.ValueLicenseType) trainer.DORSTrainerLicenceTypeId;
                updateTrainersRequest.TrainerOnCourseCollection.Add(trainerOnCourseEntity);
            }

            try
            {
                updateTrainersResponse = DORSService.UpdateTrainers(updateTrainersRequest);
                // double check that the returned Course has all the trainer ids
                var allTrainersExist = true;
                foreach(var returnedTrainer in updateTrainersResponse.TrainerList)
                {
                    var trainerIdExists = false;
                    foreach(var trainer in trainers)
                    {
                        if(returnedTrainer.TrainerID == trainer.DORSTrainerId)
                        {
                            trainerIdExists = true;
                            break;
                        }
                    }
                    if (!trainerIdExists)
                    {
                        allTrainersExist = false;
                        var ex = new Exception("There was a problem adding this trainer to this course, please try again.");
                        throw ex;
                    }
                }
                updated = allTrainersExist;
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return updated;
        }

        #endregion

        #region Lookup functions
        public List<Course> GetCourseListBySiteIdAndDate()
        {
            var courses = new List<Course>();
            try
            {
                var request = new CourseListBySiteIDAndDateEntity();
                var response = DORSService.GetCourseListBySiteIDAndDate(request);
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return courses;
        }

        public List<TrainerLicence> GetTrainerLicences(int? schemeId, int trainerId, string surname)
        {
            var trainerLicences = new List<TrainerLicence>();
            var trainerLicenceRequest = new TrainerLicensesRequestEntity();
            trainerLicenceRequest.TrainerID = trainerId;
            trainerLicenceRequest.Surname = surname;
            trainerLicenceRequest.SchemeID = schemeId;

            try
            {
                var trainerEntityCollection = DORSService.GetTrainerLicenses(trainerLicenceRequest);
                foreach(var trainerEntity in trainerEntityCollection)
                {
                    var trainerLicence = new TrainerLicence() {
                                                    Id = trainerEntity.TrainerID,
                                                    ExpiryDate = trainerEntity.ExpiryDate,
                                                    LicenseCode = trainerEntity.LicenseCode,
                                                    Forename = trainerEntity.Forename,
                                                    Surname = trainerEntity.Surname,
                                                    Status = trainerEntity.Status,
                                                    LicenceType = trainerEntity.LicenceType,
                                                    SchemeId = trainerEntity.SchemeID
                                                };
                    trainerLicences.Add(trainerLicence);
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return trainerLicences;
        }

        #endregion
    }
}
