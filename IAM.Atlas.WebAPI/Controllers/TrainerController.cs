using IAM.Atlas.Data;
using System;
using System.Drawing;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System.Globalization;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    
    public class TrainerController : AtlasBaseController
    {

        // GET: api/Trainer/GetTitles
        public class Titles
        {
            public int Id { get; set; }
            public string StringId { get; set; }
            public string Title { get; set; }
        }
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/Trainer/GetTitles")]
        public object GetTitles()
        {
            IList<Titles> TitleList = new List<Titles>() {
                new Titles(){ Id=1, StringId="", Title=""},
                new Titles(){ Id=2, StringId="Dr", Title="Dr"},
                new Titles(){ Id=3, StringId="Miss", Title="Miss"},
                new Titles(){ Id=4, StringId="Mr", Title="Mr"},
                new Titles(){ Id=5, StringId="Mrs", Title="Mrs"},
                new Titles(){ Id=6, StringId="Ms", Title="Ms"},
                new Titles(){ Id=7, StringId="Rev", Title="Rev"},
                new Titles(){ Id=8, StringId="Other", Title="Other"}
            };
            return TitleList;
        }



        [AuthorizationRequired]
        [Route("api/trainer/getProfilePicture/{TrainerId}")]
        [HttpGet]
        public object GetProfilePicture(int TrainerId)
        {
            return
                atlasDB.Trainer
                    .Where(trainer => trainer.Id == TrainerId)
                    .Select(theTrainer => new
                    {
                        theTrainer.PictureName
                    }).ToList();
        }

        [AuthorizationRequired]
        [Route("api/trainer/getSystemTrainerInformation/{OrganisationId}")]
        [HttpGet]
        public object getSystemTrainerInformation(int OrganisationId)
        {
            return
                atlasDBViews.vwSystemTrainerInformations
                    .Where(o => o.OrganisationId == OrganisationId)
                    .ToList();
        }
        
        [AuthorizationRequired]
        //[Route("api/trainer/selected/{CourseId}/{OrganisationId}")]
        [HttpGet]
        public object GetSelectedTrainers(int CourseId, int OrganisationId)
        {
            var selectedTrainers = atlasDBViews.vwCourseAllocatedTrainers
                .Where(x=>x.CourseId == CourseId && x.OrganisationId == OrganisationId)
                .Select(theCourseTrainer => new
                {
                    Id = theCourseTrainer.TrainerId,
                    Name = theCourseTrainer.TrainerName,
                    FullName = theCourseTrainer.TrainerName,
                    TrainerDistanceToVenueInMiles = theCourseTrainer.TrainerDistanceToVenueInMiles,
                    TrainerDistanceToVenueInMilesRounded = theCourseTrainer.TrainerDistanceToVenueInMilesRounded,
                    TrainerBookedForPractical = theCourseTrainer.TrainerBookedForPractical,
                    TrainerBookedForTheory = theCourseTrainer.TrainerBookedForTheory
                }).ToList();
            return selectedTrainers;
        }

        [AuthorizationRequired]
        [Route("api/trainer/selectedPractical/{CourseId}/{OrganisationId}")]
        [HttpGet]
        public object GetSelectedPracticalTrainers(int CourseId, int OrganisationId)
        {
            return GetSelectedTrainers(CourseId, OrganisationId, true, false);
        }

        [AuthorizationRequired]
        [Route("api/trainer/selectedTheory/{CourseId}/{OrganisationId}")]
        [HttpGet]
        public object GetSelectedTheoryTrainers(int CourseId, int OrganisationId)
        {
            return GetSelectedTrainers(CourseId, OrganisationId, false, true);
        }


        private object GetSelectedTrainers(int CourseId, int OrganisationId, bool Practical = false, bool Theory = false)
        {
            var selectedTrainers = atlasDBViews.vwCourseAllocatedTrainers
                .Where(x => x.CourseId == CourseId && x.OrganisationId == OrganisationId 
                                && x.TrainerBookedForPractical == Practical && x.TrainerBookedForTheory == Theory)
                .Select(theCourseTrainer => new
                {
                    Id = theCourseTrainer.TrainerId,
                    Name = theCourseTrainer.TrainerName,
                    FullName = theCourseTrainer.TrainerName,
                    TrainerDistanceToVenueInMiles = theCourseTrainer.TrainerDistanceToVenueInMiles,
                    TrainerDistanceToVenueInMilesRounded = theCourseTrainer.TrainerDistanceToVenueInMilesRounded,
                    TrainerBookedForPractical = theCourseTrainer.TrainerBookedForPractical,
                    TrainerBookedForTheory = theCourseTrainer.TrainerBookedForTheory
                }).ToList();
            return selectedTrainers;
        }


        [AuthorizationRequired]
        [Route("api/trainer/available/{CourseId}/{OrganisationId}")]
        [HttpGet]
        public object GetAvailableTrainers(int CourseId, int OrganisationId)
        {
            var availableTrainers = atlasDBViews.vwCourseAvailableTrainers
                .Where(x => x.CourseId == CourseId && x.OrganisationId == OrganisationId)
                .Select(
                    availableTrainer => new
                    {
                        Id = availableTrainer.TrainerId,
                        Name = availableTrainer.TrainerName,
                        FullName = availableTrainer.TrainerName,
                        TrainerDistanceToVenueInMiles = availableTrainer.TrainerDistanceToVenueInMiles,
                        TrainerDistanceToVenueInMilesRounded = availableTrainer.TrainerDistanceToVenueInMilesRounded,
                        TrainerForPractical = availableTrainer.TrainerForPractical,
                        TrainerForTheory = availableTrainer.TrainerForTheory,
                        TrainerBookedForPractical =   availableTrainer.TrainerBookedForPractical,
                        TrainerBookedForTheory = availableTrainer.TrainerBookedForTheory

                    }
                )
                .ToList();
            return availableTrainers;
        }

        [AuthorizationRequired]
        [Route("api/trainer/available/{CourseId}/{OrganisationId}/{SessionId}")]
        [HttpGet]
        public object GetAvailableTrainersBySession(int CourseId, int OrganisationId, int SessionId)
        {
            var availableTrainers = atlasDBViews.vwCourseAvailableTrainerBySessions
                .Where(x => x.CourseId == CourseId && x.OrganisationId == OrganisationId && x.TrainerAvailableSession == SessionId)
                .Select(
                    availableTrainer => new
                    {
                        Id = availableTrainer.TrainerId,
                        Name = availableTrainer.TrainerName,
                        FullName = availableTrainer.TrainerName,
                        TrainerDistanceToVenueInMiles = availableTrainer.TrainerDistanceToVenueInMiles,
                        TrainerDistanceToVenueInMilesRounded = availableTrainer.TrainerDistanceToVenueInMilesRounded,
                        TrainerForPractical = availableTrainer.TrainerForPractical,
                        TrainerForTheory = availableTrainer.TrainerForTheory,
                        TrainerBookedForPractical = availableTrainer.TrainerBookedForPractical,
                        TrainerBookedForTheory = availableTrainer.TrainerBookedForTheory

                    }
                )
                .ToList();
            return availableTrainers;
        }
        
        [AuthorizationRequired]
        [Route("api/trainer/gettrainersbyorganisation/{OrganisationId}")]
        [HttpGet]
        public object GetTrainersByOrganisation(int OrganisationId)
        {
            return atlasDB.Trainer
                .Include("TrainerOrganisation")
                .Include("TrainerEmail.Email")
                .Where(tr => tr.TrainerOrganisation.Any(o => o.OrganisationId == OrganisationId))
                .ToList()
                .Select(
                newTrainer => new
                {
                    Id = newTrainer.Id,
                    DisplayName = newTrainer.DisplayName,
                    Email = newTrainer.TrainerEmail.FirstOrDefault(x => x.MainEmail == true) != null ? newTrainer.TrainerEmail.First(x => x.MainEmail == true).Email.Address : "No Email",
                    DateOfBirth = newTrainer.DateOfBirth
                })
                .OrderBy(n => n.DisplayName);
        }

        [AuthorizationRequired]
        [Route("api/trainer/gettrainersbycoursetype/{CourseTypeId}")]
        [HttpGet]
        public object GetTrainersByCourseType(int CourseTypeId)
        {
            return atlasDB.Trainer
                .Include("TrainerCourseType")
                .Include("TrainerEmail.Email")
                .Where(tr => tr.TrainerCourseType.Any(ct => ct.CourseTypeId == CourseTypeId))
                .ToList()
                .Select(
                newTrainer => new
                {
                    Id = newTrainer.Id,
                    DisplayName = newTrainer.DisplayName,
                    Email = newTrainer.TrainerEmail.FirstOrDefault(x => x.MainEmail == true) != null ? newTrainer.TrainerEmail.First(x => x.MainEmail == true).Email.Address : "No Email"
                })
                .OrderBy(n => n.DisplayName);
        }

        [AuthorizationRequired]
        [Route("api/trainer/gettrainersunallocatedbyorganisation/{OrganisationId}")]
        [HttpGet]
        public object GetTrainersUnallocatedByOrganisation(int OrganisationId)
        {
            return atlasDB.Trainer
                .Include("TrainerOrganisation")
                .Include("TrainerEmail.Email")
                .Include("TrainerCourseType")
                .Where(tr => tr.TrainerOrganisation.Any(o => o.OrganisationId == OrganisationId)
                            && tr.TrainerCourseType.Count == 0)
                .ToList()
                .Select(
                newTrainer => new
                {
                    Id = newTrainer.Id,
                    DisplayName = newTrainer.DisplayName,
                    Email = newTrainer.TrainerEmail.FirstOrDefault(x => x.MainEmail == true) != null ? newTrainer.TrainerEmail.First(x => x.MainEmail == true).Email.Address : "No Email"
                })
                .OrderBy(n => n.DisplayName);
        }

        [AuthorizationRequired]
        [Route("api/trainer/gettrainersbycoursetypecategory/{CourseTypeCategoryId}")]
        [HttpGet]
        public object GetTrainersByCourseTypeCategory(int CourseTypeCategoryId)
        {
            return atlasDB.Trainer
                .Include("TrainerCourseTypeCategory")
                .Include("TrainerEmail.Email")
                .Where(tr => tr.TrainerCourseTypeCategories.Any(x => x.CourseTypeCategoryId == CourseTypeCategoryId))
                .ToList()
                .Select(
                newTrainer => new
                {
                    Id = newTrainer.Id,
                    DisplayName = newTrainer.DisplayName,
                    Email = newTrainer.TrainerEmail.FirstOrDefault(x => x.MainEmail == true) != null ? newTrainer.TrainerEmail.First(x => x.MainEmail == true).Email.Address : "No Email"
                })
                .OrderBy(n => n.DisplayName);
        }

        [Route("api/trainer/settings/{trainerId}")]
        [HttpGet]
        [AuthorizationRequired]
        public object GetTrainerSettings(int trainerId)
        {
            var trainerDetails = atlasDB.Trainer
                .Include("TrainerSettings")
                .Where(x => x.Id == trainerId)
                .Select(
                trainerSetting => new
                {
                    Id = trainerSetting.Id,
                    FirstName = trainerSetting.FirstName,
                    Surname = trainerSetting.Surname,
                    CourseTypeEditing = trainerSetting.TrainerSettings.FirstOrDefault().CourseTypeEditing,
                    ProfileEditing = trainerSetting.TrainerSettings.FirstOrDefault().ProfileEditing
                })
                .ToList();
            return trainerDetails;
        }

        [Route("api/trainer/savesettings")]
        [HttpPost]
        [AuthorizationRequired]
        public object SaveTrainerSettings(FormDataCollection formBody)
        {
            var formData = formBody;
            var trainerId = StringTools.GetInt("Id", ref formData);
            var profileEditing = StringTools.GetNullableBool("profileEditing", ref formData);
            var courseTypeEditing = StringTools.GetNullableBool("courseTypeEditing", ref formData);
            if (trainerId > 0)
            {
                //Get the trainer setting for this trainer
                var trainerSettings = atlasDB.TrainerSettings.Where(x => x.TrainerId == trainerId).FirstOrDefault();
                if(trainerSettings == null)
                {
                    trainerSettings = new TrainerSetting();
                    trainerSettings.TrainerId = trainerId;
                    trainerSettings.ProfileEditing = profileEditing != null ? profileEditing : null;
                    trainerSettings.CourseTypeEditing = courseTypeEditing != null ? courseTypeEditing : null;
                    atlasDB.TrainerSettings.Add(trainerSettings);
                }
                else
                {
                    trainerSettings.ProfileEditing = profileEditing != null ? profileEditing : null;
                    trainerSettings.CourseTypeEditing = courseTypeEditing != null ? courseTypeEditing : null;
                }
                atlasDB.SaveChanges();
                return "success";
            }
            else
            {
                throw new HttpResponseException(HttpStatusCode.BadRequest);
            }
        }

        [AuthorizationRequired]
        [Route("api/trainer/fororganisation/{CourseTypeId}/{CategoryId}/{OrganisationId}")]
        [HttpGet]
        public object GetOrganisationTrainers(int CourseTypeId, int CategoryId, int OrganisationId)
        {
            return atlasDB.Trainer
                .Include(tr => tr.TrainerCourseTypeCategories)
                .Include("TrainerEmail.Email")
                .Where(tr => tr.TrainerCourseTypeCategories.Any(x => x.CourseTypeCategoryId == CategoryId))
                .ToList()
                .Select(
                newTrainer => new
                {
                    Id = newTrainer.Id,
                    DisplayName = newTrainer.DisplayName,
                    Email = newTrainer.TrainerEmail.FirstOrDefault(x => x.MainEmail == true) != null ? newTrainer.TrainerEmail.First(x => x.MainEmail == true).Email.Address : "No Email"
                })
                .OrderBy(n => n.DisplayName);
        }
        [AuthorizationRequired]
        // GET api/<controller>/5
        public IEnumerable<TrainerJSON> Get(int Id)
        {
            var trainerDetails =
                atlasDB.Trainer
                    .Include("TrainerLocation")
                    .Include("TrainerLocation.Location")
                    .Include("TrainerPhone")
                    .Include("TrainerPhone.PhoneType")
                    .Include("TrainerEmail")
                    .Include("TrainerEmail.Email")
                    .Include("TrainerLicence")
                    .Include("TrainerLicence.DriverLicenceType")
                    .Include("User")
                    .Include(t => t.DORSTrainers)
                    .Where(trainer => trainer.Id == Id)
                    .AsEnumerable()
                    .Select(trainer => new TrainerJSON
                    {
                        Title = trainer.Title,
                        FirstName = trainer.FirstName,
                        Surname = trainer.Surname,
                        OtherNames = trainer.OtherNames,
                        DateofBirth = trainer.DateOfBirth.ToString(),
                        ProfilePicture = trainer.PictureName,
                        DisplayName = trainer.DisplayName,
                        UserName = trainer.UserId.HasValue ? trainer.User.LoginId : "",
                        Addresses = TrainerJSON.TransformLocations(trainer.TrainerLocation),
                        Emails = TrainerJSON.TransformEmails(trainer.TrainerEmail),
                        PhoneNumbers = TrainerJSON.TransformPhones(trainer.TrainerPhone),
                        Licences = TrainerJSON.TransformLicences(trainer.TrainerLicence),
                        DORSTrainerIdentifier = trainer.DORSTrainers.FirstOrDefault() == null ? "" : trainer.DORSTrainers.FirstOrDefault().DORSTrainerIdentifier
                    })
                    .ToList();

            return trainerDetails;
        }

        [AuthorizationRequired]
        [Route("api/trainer/bindtouser/{TrainerId}/{UserId}")]
        [HttpGet]
        public bool BindToUser(int TrainerId, int UserId)
        {
            //Check both trainer and user are valid
            var trainer = atlasDB.Trainer
                .Where(tr => tr.Id == TrainerId)
                .FirstOrDefault();

            var user = atlasDB.Users
                .Where(u => u.Id == UserId)
                .FirstOrDefault();

            if (trainer != null && user != null)
            {
                trainer.UserId = UserId;
                atlasDB.SaveChanges();
                return true;
            }
            else
            {
                return false;
            }            
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/trainer/downloadDocument/{Id}/{UserId}/{trainerId}/{UserSelectedOrganisationId}/{DocumentName}")]
        public HttpResponseMessage downloadDocument(int Id, int UserId, int TrainerId, int UserSelectedOrganisationId, string DocumentName)
        {
            HttpResponseMessage response = null;

            if (!this.UserMatchesToken(UserId, Request))
            {
                return response;
            }

            var document = atlasDB.Documents
                                .Where(x => x.Id == Id)
                                .FirstOrDefault();

            if (document != null)
            {
                var documentController = new DocumentController();
                var documentId = document.Id;
                if (documentId > 0)
                {
                    response = documentController.DownloadFileContents(documentId, UserId, DocumentName);
                }
            }
            return response;
        }

        [AuthorizationRequired]
        // POST api/<controller>      
        public string Post([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var trainerId = StringTools.GetInt("Id", ref formData);
            var locationId = StringTools.GetInt("Address[LocationId]", ref formData);
            var emailId = StringTools.GetInt("Email[EmailId]", ref formData);
            var trainerEmailId = StringTools.GetInt("Email[Id]", ref formData);
            var trainerLocationId = StringTools.GetInt("Address[Id]", ref formData);
            var trainerLicenceId = StringTools.GetInt("Licence[Id]", ref formData);
            var driverLicenceTypeId = StringTools.GetInt("Licence[Type]", ref formData);
            int trainerPhoneNumberId = StringTools.GetInt("", ref formData);
            int trainerPhoneTypeId = StringTools.GetInt("", ref formData);

            var trainerLicenceExpiryDate = StringTools.GetDate("Licence[ExpiryDate]", ref formData);
            var trainerLicencePhotoCardExpiryDate = StringTools.GetDate("Licence[PhotocardExpiryDate]", ref formData);


            var trainerPhoneNumber = "";
            var trainerProfilePicture = "";
                        
            if (trainerId == 0)
            {
                //Treat as a new Trainer here
                Trainer trainer = new Trainer();

                TrainerOrganisation trainerOrganisation = new TrainerOrganisation();

                trainer.Title = formBody["Title"];
                trainer.FirstName = formBody["FirstName"];
                trainer.OtherNames = formBody["OtherNames"];
                trainer.DisplayName = formBody["DisplayName"];
                trainer.Surname = formBody["Surname"];
                var userId = StringTools.GetInt("", ref formData);
                if (int.TryParse(formBody["UserId"], out userId))
                {
                    trainer.UserId = userId;
                }
                var organisationId = 0;
                if (int.TryParse(formBody["OrganisationId"], out organisationId))
                {
                    trainer.TrainerOrganisation.Add(new TrainerOrganisation { OrganisationId = organisationId });
                }

                if (string.IsNullOrEmpty(trainer.FirstName) || string.IsNullOrEmpty(trainer.Surname))
                {
                    return "Please enter a first name and a surname.";
                }

                //New trainers should not be associated to any users yet and cannot be associated to 
                //users that are already assigned to a trainer
                if (atlasDB.Trainer.Count(t => t.UserId == userId) > 0)
                {
                    return "This User is already bound to a Trainer's Details";
                }

                atlasDB.Trainer.Add(trainer);
                atlasDB.SaveChanges();

                return trainer.Id.ToString();
            }
            else
            {   //Otherwise treat as an existing trainer

                // Check the Id exists in the DB
                Trainer existingTrainer = atlasDB.Trainer
                                                .Include(t => t.DORSTrainers)
                                                .Where(t => t.Id == trainerId)
                                                .FirstOrDefault();
                if (existingTrainer == null)
                {
                    return "There was an error verifying your trainer details. Please retry.";
                }

                // Upload image
                if (!string.IsNullOrEmpty(formBody["pictureToUpload"]))
                {
                    trainerProfilePicture = ConvertImageString(formBody["pictureToUpload"], trainerId);
                }
                try
                {
                    /**
                     * Update trainer details
                     */
                    Trainer trainer = new Trainer();

                    var theTrainer = atlasDB.Trainer.Find(trainerId);

                    theTrainer.Title = formBody["Title"];
                    theTrainer.FirstName = formBody["FirstName"];
                    theTrainer.OtherNames = formBody["OtherNames"];
                    theTrainer.DisplayName = formBody["DisplayName"];
                    theTrainer.Surname = formBody["Surname"];


                    // If the picture has been uploaded
                    // Then add picturename to the object
                    if (!string.IsNullOrEmpty(trainerProfilePicture))
                    {
                        theTrainer.PictureName = trainerProfilePicture;
                    }

                    /******************************************************************
                     *
                     * Update location
                     *
                     ******************************************************************/
                    Location location = new Location();
                    location.Address = formBody["Address[Address]"];
                    location.PostCode = formBody["Address[Postcode]"];
                    location.DateUpdated = DateTime.Now;

                    if (locationId != 0)
                    {
                        // Update the Location table
                        location.Id = locationId;

                        atlasDB.Locations.Attach(location);
                        var locationEntry = atlasDB.Entry(location);
                        locationEntry.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (locationId == 0)
                    {
                        atlasDB.Locations.Add(location);
                    }

                    /******************************************************************
                     *
                     * Update trainer location
                     *
                     ******************************************************************/
                    TrainerLocation trainerLocation = new TrainerLocation();

                    trainerLocation.Trainer = theTrainer;
                    trainerLocation.MainLocation = true;
                    trainerLocation.Location = location;

                    if (trainerLocationId != 0)
                    {
                        // Update the Trainer location table
                        trainerLocation.Id = trainerLocationId;
                        trainerLocation.LocationId = location.Id;
                        trainerLocation.TrainerId = theTrainer.Id;

                        atlasDB.TrainerLocation.Attach(trainerLocation);
                        var trainerLocationEntry = atlasDB.Entry(trainerLocation);
                        trainerLocationEntry.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (trainerLocationId == 0)
                    {
                        atlasDB.TrainerLocation.Add(trainerLocation);
                    }

                    /******************************************************************
                     *
                     * Update email
                     *
                     ******************************************************************/
                    Email email = new Email();

                    email.Address = formBody["Email[Address]"];

                    if (emailId != 0)
                    {
                        email.Id = emailId;
                        // Update the Email table
                        atlasDB.Emails.Attach(email);
                        var emailEntry = atlasDB.Entry(email);
                        emailEntry.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (emailId == 0)
                    {
                        atlasDB.Emails.Add(email);
                    }

                    /******************************************************************
                     *
                     * Update trainer email
                     *
                     ******************************************************************/
                    TrainerEmail trainerEmail = new TrainerEmail();

                    trainerEmail.Trainer = theTrainer;
                    trainerEmail.Email = email;
                    trainerEmail.MainEmail = true;

                    if (trainerEmailId != 0)
                    {
                        //Update the Trainer Email table
                        trainerEmail.Id = trainerEmailId;
                        trainerEmail.EmailId = email.Id;
                        trainerEmail.TrainerId = theTrainer.Id;

                        atlasDB.TrainerEmail.Attach(trainerEmail);
                        var trainerEmailEntry = atlasDB.Entry(trainerEmail);
                        trainerEmailEntry.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (trainerEmailId == 0)
                    {
                        atlasDB.TrainerEmail.Add(trainerEmail);
                    }

                    /******************************************************************
                     *
                     * Update trainer licence table
                     *
                     ******************************************************************/
                    TrainerLicence trainerLicence = new TrainerLicence();
                    trainerLicence.Trainer = theTrainer;
                    trainerLicence.LicenceNumber = formBody["Licence[Number]"];
                    if (driverLicenceTypeId > 0)
                    {
                        trainerLicence.DriverLicenceTypeId = driverLicenceTypeId;
                    }

                 

                    trainerLicence.LicenceExpiryDate = trainerLicenceExpiryDate;
                    trainerLicence.LicencePhotoCardExpiryDate = trainerLicencePhotoCardExpiryDate;
                    trainerLicence.DateCreated = DateTime.Now; // datecreated is empty if modifying this way, will error. set to datecreated for now.
                    
                    if (trainerLicenceId != 0)
                    {
                        trainerLicence.Id = trainerLicenceId;
                        trainerLicence.TrainerId = theTrainer.Id;
                        // Update the TrainerLicence table
                        atlasDB.TrainerLicence.Attach(trainerLicence);
                        var trainerLicenceEntry = atlasDB.Entry(trainerLicence);
                        trainerLicenceEntry.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (trainerLicenceId == 0)
                    {
                        trainerLicence.DateCreated = DateTime.Now;
                        theTrainer.TrainerLicence.Add(trainerLicence);
                        //atlasDB.TrainerLicence.Add(trainerLicence);
                    }


                    /******************************************************************
                     *
                     * Update phone table
                     *
                     ******************************************************************/
                    var phoneKeyIndex = PhoneNumberAmount(formBody);
                    var startingIndex = 0;
                    while (startingIndex < phoneKeyIndex)
                    {
                        var numberKey = "PhoneNumbers[" + startingIndex + "][Number]";
                        var idKey = "PhoneNumbers[" + startingIndex + "][Id]";
                        var phoneTypeKey = "PhoneNumbers[" + startingIndex + "][PhoneTypeId]";

                        // Try parse the trainer Licence Id
                        if (Int32.TryParse(formBody[idKey], out trainerPhoneNumberId))
                        {
                        }
                        else
                        {
                            // return "There was an error verifying your trainer information. Please retry.";
                        }

                        // Try parse the trainer Licence Id
                        if (Int32.TryParse(formBody[phoneTypeKey], out trainerPhoneTypeId))
                        {
                        }
                        else
                        {
                            // return "There was an error verifying your trainer information. Please retry.";
                        }


                        var checkTrainerPhoneExists = atlasDB.TrainerPhone.Any(theTrainerPhone => theTrainerPhone.Id == trainerPhoneNumberId);
                        TrainerPhone trainerPhone = new TrainerPhone();

                        trainerPhone.Number = formBody[numberKey];
                        trainerPhone.PhoneTypeId = trainerPhoneTypeId;
                        trainerPhone.Trainer = theTrainer;

                        if (checkTrainerPhoneExists == false)
                        {
                            atlasDB.TrainerPhone.Add(trainerPhone);
                        }


                        if (checkTrainerPhoneExists == true)
                        {
                            trainerPhone.Id = trainerPhoneNumberId;
                            trainerPhone.TrainerId = theTrainer.Id;
                            // Update the TrainerPhone table
                            atlasDB.TrainerPhone.Attach(trainerPhone);
                            var trainerPhoneEntry = atlasDB.Entry(trainerPhone);
                            trainerPhoneEntry.State = System.Data.Entity.EntityState.Modified;
                        }

                        startingIndex++;
                    }

                    /*
                     * save the DORSTrainerIdentifier (this has to be unique in the db)
                     */
                    var DORSTrainerIdentifier = formBody["DORSTrainerIdentifier"];
                    if (!string.IsNullOrEmpty(DORSTrainerIdentifier))
                    {
                        // check to see if there is another trainer in the database that has the same DORSTrainerIdentifier
                        // if there is then we will return an error message.
                        var alreadyExists = atlasDB.DORSTrainers
                                                    .Any(dt => dt.DORSTrainerIdentifier == DORSTrainerIdentifier && dt.TrainerId != existingTrainer.Id);

                        if (alreadyExists)
                        {
                            return "This DORS Trainer Identifier is already being used.  The trainer you are editting may already exist in the system.  This record has not been saved.";
                        }

                        var userId = StringTools.GetInt("", ref formData);
                        if (int.TryParse(formBody["UserId"], out userId))
                        {
                            if (existingTrainer.DORSTrainers.Count > 0)     // update the record
                            {
                                if (existingTrainer.DORSTrainers.Count > 1)
                                {
                                    // delete all the extra records
                                    for(int i = 1; i < existingTrainer.DORSTrainers.Count; i++)
                                    {
                                        var currentDorsTrainer = existingTrainer.DORSTrainers.ElementAt(i);
                                        var currentDorsTrainerEntry = atlasDB.Entry(currentDorsTrainer);
                                        currentDorsTrainerEntry.State = EntityState.Modified;
                                    }
                                }
                                var dorsTrainer = existingTrainer.DORSTrainers.ElementAt(0);
                                if (dorsTrainer.DORSTrainerIdentifier != DORSTrainerIdentifier)
                                {
                                    dorsTrainer.DateUpdated = DateTime.Now;
                                    dorsTrainer.DORSTrainerIdentifier = DORSTrainerIdentifier;
                                    dorsTrainer.UpdatedByUserId = userId;

                                    var dorsTrainerEntry = atlasDB.Entry(dorsTrainer);
                                    dorsTrainerEntry.State = EntityState.Modified;
                                }
                            }
                            else    // add a new record
                            {
                                var dorsTrainer = new DORSTrainer();
                                dorsTrainer.UpdatedByUserId = userId;
                                dorsTrainer.DateUpdated = DateTime.Now;
                                dorsTrainer.DORSTrainerIdentifier = DORSTrainerIdentifier;
                                theTrainer.DORSTrainers.Add(dorsTrainer);
                            }
                        }
                    }

                    atlasDB.SaveChanges();
                    return "success";
                }
                catch (DbEntityValidationException ex)
                {
                    return "An error has occourer when trying to save the Trainer. Please contact your administrator.";
                }
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

        /**
         * Convert the a Base64 String to an Image
         * @return string image path
         * @todo move to a tools folder as used multiple times
         */
        public string ConvertImageString(string imageFile, int trainerId)
        {
            try
            {
                var endPath = "Images\\profile_picture_" + trainerId + ".png";
                var filePath = System.AppDomain.CurrentDomain.BaseDirectory + endPath;

                byte[] imageBytes = Convert.FromBase64String(imageFile);
                MemoryStream ms = new MemoryStream(imageBytes, 0, imageBytes.Length);

                ms.Write(imageBytes, 0, imageBytes.Length);
                Image image = Image.FromStream(ms, true);

                image.Save(filePath);

                return endPath;
            }
            catch
            {
                return null;
            }
        }

        /**
         * Convert the a string to a DateTime
         * @return string image path
         * @todo move to a tools folder as used multiple times
         */
        protected DateTime stringToDate(string theDate)
        {
            if (string.IsNullOrEmpty(theDate))
            {
                return DateTime.Now;
            }

            DateTime newDate = DateTime.Parse(theDate);
            return newDate.Date;
        }

        protected int PhoneNumberAmount(FormDataCollection formBody)
        {
            var theIndex = 0;

            foreach (var phoneNumber in formBody)
            {

                var key = "PhoneNumbers[" + theIndex + "][Number]";
                var thePhoneNumber = formBody[key];

                if (!string.IsNullOrEmpty(thePhoneNumber))
                {
                    theIndex++;
                }

                if (string.IsNullOrEmpty(thePhoneNumber))
                {
                    return theIndex;
                }
            }
            return -1;
        }

        public class TrainerResult
        {
            public int Id { get; set; }
            public string DisplayName { get; set; }
            public string Email { get; set; }
        }


    }
}