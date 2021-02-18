using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is used to return a light weight serialized JSON object to course and caters both for new course (with type, venue language and category options)
    /// creation as well as clone course creation which returns all these as well as template course presets
    /// 
    /// </summary>
    public class CourseJSON
    {
        public int Id { get; set; }
        public string actionMessage { get; set; }
        public string courseReference { get; set; }
        public int venueId { get; set; }
        public int courseTypeId { get; set; }
        public int categoryId { get; set; }
        public int languageId { get; set; }
        public CourseTypeJSON courseType { get; set; }
        public List<CourseTrainersJSON> courseTrainers { get; set; }
        public List<CourseTrainersAndInterpretersJSON> courseTrainersAndInterpreters { get; set; }
        public List<CourseNotesJSON> courseNotes { get; set; }
        public List<CourseLogJSON> courseLog { get; set; }
        public List<CourseDocumentJSON> documents { get; set; }
        public List<VenueLocationJSON> venueLocations { get; set; }
        public List<CourseDateJSON> courseDates { get; set; }


        public int coursePlaces { get; set; }

        private int? placesAvailable;
        /// <summary>
        /// Have to set the three parameters (coursePlaces, coursePlacesBooked, courseReserved) before you can use this getter
        /// Or it will return an incorrect value.
        /// </summary>
        public int coursePlacesAvailable {
            get
            {
                return (placesAvailable == null ? (coursePlaces - coursePlacesBooked - courseReserved) : (int)placesAvailable);
            }
            set
            {
                placesAvailable = value;
            }
        }
        public int coursePlacesBooked { get; set; }
        public int trainersRequired { get; set; }
        public int courseReserved { get; set; }
        public bool courseMultiDay { get; set; }
        public string courseDateStart { get; set; }
        public string courseTimeStart { get; set; }
        public string courseDateEnd { get; set; }
        public string courseTimeEnd { get; set; }
        public int? sessionNumber { get; set; }
        public bool courseUpdateDorsAttendance { get; set; }
        public bool courseAttendanceByTrainer { get; set; }
        public bool courseManualCarsOnly { get; set; }
        public bool courseRestrictOnlineBookingManualOnly { get; set; }
        public bool courseAvailable { get; set; }
        public bool courseHasInterpreter { get; set; }
        public bool courseDorsCourse { get; set; }
        public bool courseAttendanceCheckRequired { get; set; }
        public bool courseAttendanceVerified { get; set; }
        public bool courseAttendeanceSentToDors { get; set; }
        public string courseAttendeanceSentToDorsTime { get; set; }
        public bool courseCancelled { get; set; }
        public bool courseStarted { get; set; }
        public bool courseDateInPast { get; set; }
        public string venueTitle { get; set; }
        public string courseTypeTitle { get; set; }
        public string courseTypeCategoryName { get; set; }
        public int courseTypeCategoryId { get; set; }
        public string courseAssociatedSession { get; set; }

        public DateTime? lastBookingDate { get; set; }
        public bool TheoryCourse { get; set; }
        public bool PracticalCourse { get; set; }
        public bool isCourseLocked { get; set; }
        public bool isCourseProfileLocked { get; set; }

    }

    public class CourseDateJSON
    {
        public int Id { get; set; }
        public int CourseId { get; set; }
        public DateTime? DateStart { get; set; }
        public DateTime? DateEnd { get; set; }
        public bool? Available { get; set; }
        public bool? AttendanceUpdated { get; set; }
        public bool? AttendanceVerified { get; set; }
        public int? AssociatedSessionNumber { get; set; }
    }

    public class CourseDocumentJSON
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Type { get; set; }
        public string FileName { get; set; }
        public string Description { get; set; }
        public bool MarkedForDeletion { get; set; }
    }

    public class CourseNotesJSON
        {
        public DateTime Date { get; set; }
        public string Type { get; set; }
        public string User { get; set; }
        public string Text { get; set; }
    }

    public class CourseLogJSON
    {
        public DateTime Date { get; set; }
        public string Event { get; set; }
        public string User { get; set; }
        public string Detail { get; set; }
    }

    public class CourseTrainersJSON
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class CourseTrainersAndInterpretersJSON
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class CourseCategoryJSON
    {
        public int Id { get; set; }
        public string Description { get; set; }
    }

    public class CourseLanguageJSON
    {
        public int Id { get; set; }
        public string Description { get; set; }
    }

    public class VenueLocationJSON
    {
        public string Title { get; set; }
        public string Address { get; set; }
        public string PostCode { get; set; }
    }

}