using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//using IAM.DORS.Webservice.DORSService;
using dors.npia.police.uk.services;
using WTG.DORS.WCF_6_7.DataContracts;

namespace IAM.DORS.Webservice.Data
{
    public class MockService : OutDorsServiceContractClient
    {
        public override LookupStatusEntityCollection LookupStatus(string drivingLicenseNumber)
        {
            var output = new LookupStatusEntityCollection();
            //if(!string.IsNullOrEmpty(drivingLicenseNumber))
            //{
            //    output.Add(new LookupStatusEntity
            //    {
            //        AttendanceID = -1,
            //        AttendanceStatus = "Booked and Paid",
            //        AttendanceStatusID = 3,
            //        ExpiryDate = DateTime.Now.AddYears(1),
            //        ExtensionData = null,
            //        ForceID = 8,
            //        Forcename = null,
            //        SchemeID = 2,
            //        SchemeName = "National Speed Awareness Course"
            //    });
            //    return output;
            //}
            if (drivingLicenseNumber == "ATLAS812103CD9DW"
                || drivingLicenseNumber == "ATLAS812093CD9LO"
                || drivingLicenseNumber == "ATLAS712093CD9LO"
                || drivingLicenseNumber == "ATLAS612093CD9LO"
                || drivingLicenseNumber == "ATLAS512093CD9LO"
                || drivingLicenseNumber == "ATLAS412093CD9LO"
                || drivingLicenseNumber == "ATLAS312093CD9LO"
                || drivingLicenseNumber == "ATLAS812093CD9LX"
                || drivingLicenseNumber == "ATLAS712093CD9LX"
                || drivingLicenseNumber == "ATLAS612093CD9LX"
                || drivingLicenseNumber == "ATLAS512093CD9LX"
                || drivingLicenseNumber == "ATLAS412093CD9LX"
                || drivingLicenseNumber == "ATLAS312093CD9LX"
                || drivingLicenseNumber == "SMITH123450PA9AX"
                || drivingLicenseNumber == "SMITH123451PA9AX"
                || drivingLicenseNumber == "SMITH123452PA9AX"
                || drivingLicenseNumber == "SMITH123453PA9AX"
                || drivingLicenseNumber == "SMITH123454PA9AX"
                || drivingLicenseNumber == "SMITH123455PA9AX"
                || drivingLicenseNumber == "SMITH123456PA9AX"
                || drivingLicenseNumber == "SMITH123457PA9AX"
                || drivingLicenseNumber == "SMITH123458PA9AX"
                || drivingLicenseNumber == "SMITH123459PA9AX"
                || drivingLicenseNumber == "PETER123450AJ9BY"
                || drivingLicenseNumber == "PETER123451AJ9BY"
                || drivingLicenseNumber == "PETER123452AJ9BY"
                || drivingLicenseNumber == "PETER123453AJ9BY"
                || drivingLicenseNumber == "PETER123454AJ9BY"
                || drivingLicenseNumber == "PETER123455AJ9BY"
                || drivingLicenseNumber == "PETER123456AJ9BY"
                || drivingLicenseNumber == "PETER123457AJ9BY"
                || drivingLicenseNumber == "PETER123458AJ9BY"
                || drivingLicenseNumber == "PETER123459AJ9BY"
                || drivingLicenseNumber == "SCREE123450KL9CZ"
                || drivingLicenseNumber == "SCREE123451KL9CZ"
                || drivingLicenseNumber == "SCREE123452KL9CZ"
                || drivingLicenseNumber == "SCREE123453KL9CZ"
                || drivingLicenseNumber == "SCREE123454KL9CZ"
                || drivingLicenseNumber == "SCREE123455KL9CZ"
                || drivingLicenseNumber == "SCREE123456KL9CZ"
                || drivingLicenseNumber == "SCREE123457KL9CZ"
                || drivingLicenseNumber == "SCREE123458KL9CZ"
                || drivingLicenseNumber == "SCREE123459KL9CZ"
                || drivingLicenseNumber == "CLENS123450LM9DA"
                || drivingLicenseNumber == "CLENS123451LM9DA"
                || drivingLicenseNumber == "CLENS123452LM9DA"
                || drivingLicenseNumber == "CLENS123453LM9DA"
                || drivingLicenseNumber == "CLENS123454LM9DA"
                || drivingLicenseNumber == "CLENS123455LM9DA"
                || drivingLicenseNumber == "CLENS123456LM9DA"
                || drivingLicenseNumber == "CLENS123457LM9DA"
                || drivingLicenseNumber == "CLENS123458LM9DA"
                || drivingLicenseNumber == "CLENS123459LM9DA"
                || drivingLicenseNumber == "POWER123450PQ9FC"
                || drivingLicenseNumber == "POWER123451PQ9FC"
                || drivingLicenseNumber == "POWER123452PQ9FC"
                || drivingLicenseNumber == "POWER123453PQ9FC"
                || drivingLicenseNumber == "POWER123454PQ9FC"
                || drivingLicenseNumber == "POWER123455PQ9FC"
                || drivingLicenseNumber == "POWER123456PQ9FC"
                || drivingLicenseNumber == "POWER123457PQ9FC"
                || drivingLicenseNumber == "POWER123458PQ9FC"
                || drivingLicenseNumber == "POWER123459PQ9FC"
                || drivingLicenseNumber == "GARGA123450RS9GD"
                || drivingLicenseNumber == "GARGA123451RS9GD"
                || drivingLicenseNumber == "GARGA123452RS9GD"
                || drivingLicenseNumber == "GARGA123453RS9GD"
                || drivingLicenseNumber == "GARGA123454RS9GD"
                || drivingLicenseNumber == "GARGA123455RS9GD"
                || drivingLicenseNumber == "GARGA123456RS9GD"
                || drivingLicenseNumber == "GARGA123457RS9GD"
                || drivingLicenseNumber == "GARGA123458RS9GD"
                || drivingLicenseNumber == "GARGA123459RS9GD"
                )
            {
                output.Add(new LookupStatusEntity {
                    AttendanceID = 999999,
                    SchemeID = 2,
                    SchemeName = "National Speed Awareness Course",
                    AttendanceStatusID = 1,
                    AttendanceStatus = "Booking Pending",
                    ExtensionData = null,
                    ForceID = 5,
                    Forcename = "Greater Manchester Police",
                    ExpiryDate = DateTime.Now.AddMonths(1)
                });
                if (drivingLicenseNumber == "ATLAS812103CD9DW"
                    || drivingLicenseNumber == "ATLAS812093CD9LO"
                    || drivingLicenseNumber == "ATLAS312093CD9LO"
                    || drivingLicenseNumber == "ATLAS812093CD9LX"
                    || drivingLicenseNumber == "ATLAS312093CD9LX"
                    || drivingLicenseNumber == "SMITH123450PA9AX"
                    || drivingLicenseNumber == "SMITH123459PA9AX"
                    || drivingLicenseNumber == "PETER123450AJ9BY"
                    || drivingLicenseNumber == "PETER123459AJ9BY"
                    || drivingLicenseNumber == "SCREE123450KL9CZ"
                    || drivingLicenseNumber == "SCREE123459KL9CZ"
                    || drivingLicenseNumber == "CLENS123450LM9DA"
                    || drivingLicenseNumber == "CLENS123459LM9DA"
                    || drivingLicenseNumber == "POWER123450PQ9FC"
                    || drivingLicenseNumber == "POWER123459PQ9FC"
                    || drivingLicenseNumber == "GARGA123450RS9GD"
                    || drivingLicenseNumber == "GARGA123459RS9GD"
                    )
                {
                    output.Add(new LookupStatusEntity
                    {
                        AttendanceID = 999998,
                        SchemeID = 4,
                        SchemeName = "National Driver Alertness Course",
                        AttendanceStatusID = 1,
                        AttendanceStatus = "Booking Pending",
                        ExtensionData = null,
                        ForceID = 6,
                        Forcename = "CHESHIRE",
                        ExpiryDate = DateTime.Now.AddMonths(2)
                    });
                }
                return output;
            }
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -1,
                AttendanceStatus = "Booking Pending",
                AttendanceStatusID = 1,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = "The Ant Hill Mob",
                SchemeID = 2,
                SchemeName = "National Speed Awareness"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -1,
                AttendanceStatus = "Booking Pending",
                AttendanceStatusID = 1,
                ExpiryDate = null,
                ExtensionData = null,
                ForceID = 0,
                Forcename = "The Tweenies",
                SchemeID = 4,
                SchemeName = "Driver Alertness Scheme"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -1,
                AttendanceStatus = "Booked",
                AttendanceStatusID = 2,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = null,
                SchemeID = 10,
                SchemeName = "What's Driving Us Mad"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -2,
                AttendanceStatus = "Booked",
                AttendanceStatusID = 2,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = null,
                SchemeID = 0,
                SchemeName = "Scheme 0"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -3,
                AttendanceStatus = "Booked And Paid",
                AttendanceStatusID = 3,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = null,
                SchemeID = 1,
                SchemeName = "Scheme 1"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -4,
                AttendanceStatus = "Attended And Completed",
                AttendanceStatusID = 4,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = null,
                SchemeID = 2,
                SchemeName = "Scheme 2"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -5,
                AttendanceStatus = "Attended And Not Completed",
                AttendanceStatusID = 5,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = null,
                SchemeID = 3,
                SchemeName = "Scheme 3"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -6,
                AttendanceStatus = "Did Not Attend",
                AttendanceStatusID = 6,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = null,
                SchemeID = 4,
                SchemeName = "Scheme 4"
            });
            output.Add(new LookupStatusEntity
            {
                AttendanceID = -7,
                AttendanceStatus = "Offer Withdrawn",
                AttendanceStatusID = 7,
                ExpiryDate = DateTime.Now.AddYears(1),
                ExtensionData = null,
                ForceID = 0,
                Forcename = "Teletubbies",
                SchemeID = 5,
                SchemeName = "Scheme 5"
            });
            return output;
        }

        public override bool AddBooking(AddBooking NewBooking)
        {
            //throw new Exception("Test Exception Add Booking");
            return true; 
        }

        public override bool CancelBooking(int AttendanceID)
        {
            return true;
        }

        public override bool UpdateBooking(UpdateBooking ExistingBooking)
        {
            //throw new Exception("Test Exception Update Booking");
            return true;
        }

        public override int AddCourse(CourseEntity Course)
        {
            //throw new Exception("Test Exception Add Course");
            return 666666;
        }

        public override CourseResponseEntity UpdateCourse(CourseEntity Course)
        {
            return new CourseResponseEntity();
        }

        public override bool CancelCourse(int CourseID)
        {
            //throw new Exception("Test Exception Cancel Course");
            return true;
        }

        public override AttendanceStatusEntityCollection GetAttendanceStatusList()
        {
            return new AttendanceStatusEntityCollection();
        }

        public override int GetAttendanceID(dors.npia.police.uk.services.GetAttendanceIDRequest GetAttendanceIDRequest)
        {
            return 666666;
        }

        public override int GetCourseID(dors.npia.police.uk.services.GetCourseIDRequest GetCourseIDRequest)
        {
            return 666666;
        }

        public override CourseWithAttendeesResponseEntity GetCourseByID(int courseID)
        {
            var course = new CourseWithAttendeesResponseEntity();
            course.CourseAvailability = 1;
            course.CourseCapacity = 24;
            course.CourseDateTime = DateTime.Now.AddMonths(1);
            course.CourseID = 12345;
            course.CourseTitle = "Mock Driving Course";
            course.ForceContractID = 5;
            course.SiteID = 5;
            course.AttendeeList = new int[0];
            course.TrainerList = new TrainerLicenseEntityCollection();
            return course;
        }

        public override SchemeEntityCollection GetSchemeList()
        {
            return new SchemeEntityCollection();
        }

        public override ForceContractEntityCollection GetForceContractList()
        {

            return new ForceContractEntityCollection();
        }

        public override SiteEntityCollection GetSiteList()
        {
            return new SiteEntityCollection();
        }

        public override ForceEntityCollection GetForceList()
        {
            var forceEntityCollection1 = new ForceEntityCollection();

            var forceEntity1 = new ForceEntity();
            var forceEntity2 = new ForceEntity();
            var forceEntity3 = new ForceEntity();
            var forceEntity4 = new ForceEntity();
            var forceEntity5 = new ForceEntity();
            var forceEntity6 = new ForceEntity();

            forceEntity1.ForceID = 1122;
            forceEntity1.PNCCode = "Blah-NEW";
            forceEntity1.ForceName = "Paul-ice-NEW";
            forceEntityCollection1.Add(forceEntity1);

            forceEntity2.ForceID = 2233;
            forceEntity2.PNCCode = "Testing-NEW";
            forceEntity2.ForceName = "Bot-NEW";
            forceEntityCollection1.Add(forceEntity2);

            forceEntity3.ForceID = 3344;
            forceEntity3.PNCCode = "Hi";
            forceEntity3.ForceName = "Neighbour";
            forceEntityCollection1.Add(forceEntity3);

            forceEntity4.ForceID = 4455;
            forceEntity4.PNCCode = "DanLoves-NEW";
            forceEntity4.ForceName = "SteveBalmer-NEW";
            forceEntityCollection1.Add(forceEntity4);

            forceEntity5.ForceID = 5566;
            forceEntity5.PNCCode = "Poppa-NEW";
            forceEntity5.ForceName = "Tuq-NEW";
            forceEntityCollection1.Add(forceEntity5);

            forceEntity6.ForceID = 6677;
            forceEntity6.PNCCode = "Poppa";
            forceEntity6.ForceName = "Tuq";
            forceEntityCollection1.Add(forceEntity6);

            return forceEntityCollection1;

        }

        // this function was removed from DORS+ V2
        //public override IAM.DORS.Webservice.DORSService.CourseEntityCollection GetCourseListBySiteID(int siteID)
        //{
        //    return new CourseEntityCollection();
        //}

        public override GetOfferWithdrawnEntityCollection GetOfferWithdrawn(dors.npia.police.uk.services.GetOfferWithdrawnRequest GetOfferWithdrawnRequest)
        {
            //throw new Exception("Test Exception Get Offer Withdrawn");
            var getOfferWithdrawnEntityCollection = new GetOfferWithdrawnEntityCollection();

            var offerWidthdrawnEntity1 = new GetOfferWithdrawnEntity();
            var offerWidthdrawnEntity2 = new GetOfferWithdrawnEntity();
            var offerWidthdrawnEntity3 = new GetOfferWithdrawnEntity();
            var offerWidthdrawnEntity4 = new GetOfferWithdrawnEntity();
            var offerWidthdrawnEntity5 = new GetOfferWithdrawnEntity();

            offerWidthdrawnEntity1.AttendanceID = 1;
            offerWidthdrawnEntity1.DrivingLicenseNumber = "nicksmith";
            offerWidthdrawnEntity1.SchemeID = 1;
            offerWidthdrawnEntity1.AttendanceStatusID_Old = 11;
            getOfferWithdrawnEntityCollection.Add(offerWidthdrawnEntity1);

            offerWidthdrawnEntity2.AttendanceID = 2;
            offerWidthdrawnEntity2.DrivingLicenseNumber = "paultuck";
            offerWidthdrawnEntity2.SchemeID = 2;
            offerWidthdrawnEntity2.AttendanceStatusID_Old = 12;
            getOfferWithdrawnEntityCollection.Add(offerWidthdrawnEntity2);

            offerWidthdrawnEntity3.AttendanceID = 3;
            offerWidthdrawnEntity3.DrivingLicenseNumber = "danhough";
            offerWidthdrawnEntity3.SchemeID = 3;
            offerWidthdrawnEntity3.AttendanceStatusID_Old = 13;
            getOfferWithdrawnEntityCollection.Add(offerWidthdrawnEntity3);

            offerWidthdrawnEntity4.AttendanceID = 3;
            offerWidthdrawnEntity4.DrivingLicenseNumber = "danhough";
            offerWidthdrawnEntity4.SchemeID = 3;
            offerWidthdrawnEntity4.AttendanceStatusID_Old = 14;
            getOfferWithdrawnEntityCollection.Add(offerWidthdrawnEntity4);

            offerWidthdrawnEntity5.AttendanceID = 5;
            offerWidthdrawnEntity5.DrivingLicenseNumber = "robertnewnham";
            offerWidthdrawnEntity5.SchemeID = 5;
            offerWidthdrawnEntity5.AttendanceStatusID_Old = 15;
            getOfferWithdrawnEntityCollection.Add(offerWidthdrawnEntity5);


            return getOfferWithdrawnEntityCollection;
        }

        public override TrainerLicenseEntityCollection GetTrainerLicenses(TrainerLicensesRequestEntity TrainerLicensesRequestEntity)
        {
            var trainerLicensesRequestEntityCollection = new TrainerLicenseEntityCollection();

            var trainerLicenseEntity1 = new TrainerLicenseEntity();
            trainerLicenseEntity1.LicenceType = "Theory";
            trainerLicenseEntity1.LicenseCode = "TestCode1";
            trainerLicenseEntity1.Forename = "Bill";
            trainerLicenseEntity1.ExpiryDate = DateTime.Now;
            trainerLicenseEntity1.Status = "Provisional / Conditional";
            trainerLicenseEntity1.SchemeID = 1;
            trainerLicenseEntity1.TrainerID = 13;
            trainerLicensesRequestEntityCollection.Add(trainerLicenseEntity1);

            var trainerLicenseEntity2 = new TrainerLicenseEntity();
            trainerLicenseEntity2.LicenceType = "Practical";
            trainerLicenseEntity2.LicenseCode = "TestCode2";
            trainerLicenseEntity2.Forename = "Professor";
            trainerLicenseEntity2.Surname = "McGregor";
            trainerLicenseEntity2.ExpiryDate = DateTime.Now;
            trainerLicenseEntity2.Status = "Full";
            trainerLicenseEntity2.SchemeID = 3;
            trainerLicenseEntity2.TrainerID = 6;
            trainerLicensesRequestEntityCollection.Add(trainerLicenseEntity2);

            return trainerLicensesRequestEntityCollection;

        }
    }
}
