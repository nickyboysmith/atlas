using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.Data;
using System.Text;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class InterpreterLanguageController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/GetLanguages")]
        [HttpGet]
        public object GetLanguages()
        {
            var languages = atlasDB.Language
                    .Select(language => new
                    {
                        Id = language.Id,
                        EnglishName = language.EnglishName
                    }).ToList();

            return languages;
        }


        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/GetLanguagesByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetLanguagesByOrganisation(int OrganisationId)
        {

            var interpreterLanguage = atlasDBViews.vwOrganisationInterpreterLanguages
            .Where(
                oil =>
                    oil.OrganisationId == OrganisationId
            )
            .OrderBy(oil => oil.LanguageName)
            .Select(
                il => new 
                {
                    LanguageId = il.LanguageId,
                    LanguageName = il.LanguageName
                }
            ).ToList();
            

            return interpreterLanguage;
        }


        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/GetInterpreterNamesByOrganisationLanguage/{OrganisationId}/{LanguageId}")]
        [HttpGet]
        public object GetInterpreterNamesByOrganisationLanguage(int OrganisationId, int? LanguageId)
        {

            if (LanguageId == null)
            {
                var interpreterNames = atlasDBViews.vwLanguageInterpreters
                                                .Where(
                                                oil =>
                                                   oil.OrganisationId == OrganisationId
                                                )
                                                .OrderBy(oil => oil.InterpreterName)
                                                .Select(
                                                    il => new
                                                    {
                                                       interpreterId = il.InterpreterId,
                                                       InterpreterName = il.InterpreterName,
                                                       LanguageName = "ALL",
                                                       InterpreterLanguageList = il.InterpreterLanguageList
                                                    }
                                                
                                                ).Distinct().ToList();

                return interpreterNames;
            }
            else { 

                 var interpreterNames = atlasDBViews.vwLanguageInterpreters
                                                .Where(
                                                    oil =>
                                                        oil.OrganisationId == OrganisationId && oil.LanguageId == LanguageId
                                                )
                                                .OrderBy(oil => oil.InterpreterName)
                                                .Select(
                                                    il => new
                                                    {
                                                        interpreterId = il.InterpreterId,
                                                        InterpreterName = il.InterpreterName,
                                                        LanguageName = il.LanguageName,
                                                        InterpreterLanguageList = il.InterpreterLanguageList
                                                    }
                                                ).ToList();

                return interpreterNames;
            }
        }

        
        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/GetInterpreterById/{InterpreterId}")]
        [HttpGet]
        public object GetInterpreterById(int InterpreterId)
        {

            var interpreter = atlasDB.Interpreters
                    .Include("InterpreterEmails")
                    .Include("InterpreterEmails.Email")
                    .Include("InterpreterLocations")
                    .Include("InterpreterLocations.Location")
                    .Include("InterpreterPhones")
                    .Include("InterpreterPhones.PhoneType")
                    .Include("InterpreterLanguages")
                    .Include("InterpreterLanguages.Language")
                    //.Include("InterpreterNotes")
                    //.Include("InterpreterNotes.Note")
                    .Where(i => i.Id == InterpreterId).ToList();

            return interpreter;
            
        }
        
        // GET: api/InterpreterLanguage/GetTitles
        public class Titles
        {
            public int Id { get; set; }
            public string StringId { get; set; }
            public string Title { get; set; }
        }
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/GetTitles")]
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

        private string FormatAddress(FormDataCollection formBody)
        {
            StringBuilder addressSB = new StringBuilder("");
            if (!string.IsNullOrEmpty((string)formBody.Get("Address1"))) addressSB.AppendLine((string)formBody.Get("Address1"));
            if (!string.IsNullOrEmpty((string)formBody.Get("Address2"))) addressSB.AppendLine((string)formBody.Get("Address2"));
            if (!string.IsNullOrEmpty((string)formBody.Get("Town"))) addressSB.AppendLine((string)formBody.Get("Town"));
            if (!string.IsNullOrEmpty((string)formBody.Get("County"))) addressSB.AppendLine((string)formBody.Get("County"));
            if (!string.IsNullOrEmpty((string)formBody.Get("PostCode"))) addressSB.AppendLine((string)formBody.Get("PostCode"));
            if (!string.IsNullOrEmpty((string)formBody.Get("Country"))) addressSB.AppendLine((string)formBody.Get("Country"));
            return addressSB.ToString();
        }


        [HttpPost]
        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/AddInterpreter")]
        public string AddInterpreter([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var CreatedByUserId = StringTools.GetInt("CreatedByUserId", ref formData);
            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);

            var Title = StringTools.GetString("Title", ref formData);
            var FirstName = StringTools.GetString("FirstName", ref formData);
            var OtherNames = StringTools.GetString("OtherNames", ref formData);
            var Surname = StringTools.GetString("Surname", ref formData);
            var DisplayName = StringTools.GetString("DisplayName", ref formData);
            var DateOfBirth = StringTools.GetDate("DateOfBirth", ref formData);
            var PostCode = StringTools.GetString("PostCode", ref formData);
            var Email = StringTools.GetString("Email", ref formData);


            string status = "";

            try
            {
                // Create the Interpreter
                Interpreter interpreter = new Interpreter();

                interpreter.Title = Title;
                interpreter.FirstName = FirstName;
                interpreter.Surname = Surname;
                interpreter.OtherNames = OtherNames;
                interpreter.DisplayName = DisplayName;
                interpreter.DateOfBirth = DateOfBirth;
                interpreter.DateCreated = DateTime.Now;
                interpreter.CreatedByUserId = CreatedByUserId;
                atlasDB.Interpreters.Add(interpreter);

                // Create the InterpreterOrganisation
                InterpreterOrganisation interpreterOrganisation = new InterpreterOrganisation();
                interpreterOrganisation.OrganisationId = OrganisationId;
                interpreterOrganisation.InterpreterId = interpreter.Id;
                atlasDB.InterpreterOrganisations.Add(interpreterOrganisation);

                // Create the Email
                Email email = new Email();
                email.Address = Email;
                atlasDB.Emails.Add(email);

                // Create the InterpreterEmail
                InterpreterEmail interpreterEmail = new InterpreterEmail();
                interpreterEmail.InterpreterId = interpreter.Id;
                interpreterEmail.EmailId = email.Id;
                atlasDB.InterpreterEmails.Add(interpreterEmail);

                // Create the Location 
                Location location = new Location();
                location.Address = FormatAddress(formData);
                location.PostCode = PostCode;
                atlasDB.Locations.Add(location);

                // Create the InterpreterLocation
                InterpreterLocation interpreterLocation = new InterpreterLocation();
                interpreterLocation.InterpreterId = interpreter.Id;
                interpreterLocation.LocationId = location.Id;
                atlasDB.InterpreterLocations.Add(interpreterLocation);

                // Create the Interpreter Languages
                var languages = (from fb in formData
                                 where fb.Key.Contains("Languages")
                                     select new { fb.Key, fb.Value });

                if (languages != null)
                {
                    foreach (var language in languages)
                    {
                        if (language.Key.Substring(language.Key.Length - 4) == "[Id]")
                        {

                            InterpreterLanguage interpreterLanguage = new InterpreterLanguage();

                            interpreterLanguage.InterpreterId = interpreter.Id;
                            interpreterLanguage.LanguageId = Int32.Parse(language.Value);

                            atlasDB.InterpreterLanguages.Add(interpreterLanguage);
                        }
                    }
                }

                // Create the Interpreter Phones
                var phones = (from fb in formData
                                 where fb.Key.Contains("PhoneNumbers")
                                 select new { fb.Key, fb.Value });

                if (phones != null)
                {
                    // Create a list of phone types
                    List<PhoneType> phoneTypes = atlasDB.PhoneTypes.ToList();

                    var phoneNumber = "";
                    int phoneNumberTypeId = 0;

                    foreach (var phone in phones)
                    {
                        if (phone.Key.Substring(phone.Key.Length - 13) == "[PhoneNumber]")
                        {
                            phoneNumber = phone.Value;
                        }
                        else if (phone.Key.Substring(phone.Key.Length - 6) == "[Type]")
                        {
                            phoneNumberTypeId = getPhoneTypeId(phone.Value, phoneTypes);

                        }
                        if (!String.IsNullOrEmpty(phoneNumber) && phoneNumberTypeId != 0)
                        {
                            InterpreterPhone interpreterPhone = new InterpreterPhone();

                            interpreterPhone.InterpreterId = interpreter.Id;
                            interpreterPhone.PhoneTypeId = phoneNumberTypeId;
                            interpreterPhone.Number = phoneNumber;
                            atlasDB.InterpreterPhones.Add(interpreterPhone);

                            phoneNumber = "";
                            phoneNumberTypeId = 0;
                        }
                    }
                }
            
                atlasDB.SaveChanges();

                status = "Interpreter Saved Successfully";

            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }
            
            return status;
        }
        
        [HttpPost]
        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/EditInterpreter")]
        public string EditInterpreter([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var InterpreterId = StringTools.GetInt("InterpreterId", ref formData);
            var UpdatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);
            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var EmailId = StringTools.GetInt("EmailId", ref formData);
            var AddressId = StringTools.GetInt("AddressId", ref formData);
            var Title = StringTools.GetString("Title", ref formData);
            var FirstName = StringTools.GetString("FirstName", ref formData);
            var OtherNames = StringTools.GetString("OtherNames", ref formData);
            var Surname = StringTools.GetString("Surname", ref formData);
            var DisplayName = StringTools.GetString("DisplayName", ref formData);
            var DateOfBirth = StringTools.GetDate("DateOfBirth", ref formData);
            var PostCode = StringTools.GetString("PostCode", ref formData);
            var Address = StringTools.GetString("Address", ref formData);
            var Country = StringTools.GetString("Country", ref formData);
            var Email = StringTools.GetString("Email", ref formData);
            var Disabled = StringTools.GetBool("Disabled", ref formData);

            string status = "";

            try
            {

                // Get the Interpreter
                Interpreter interpreter = atlasDB.Interpreters.Find(InterpreterId);

                if (interpreter != null)
                {

                    interpreter.Title = Title;
                    interpreter.FirstName = FirstName;
                    interpreter.Surname = Surname;
                    interpreter.OtherNames = OtherNames;
                    interpreter.DisplayName = DisplayName;
                    interpreter.DateOfBirth = DateOfBirth;
                    interpreter.Disabled = Disabled;
                    interpreter.DateUpdated = DateTime.Now;
                    interpreter.UpdatedByUserId = UpdatedByUserId;
                    atlasDB.Entry(interpreter).State = EntityState.Modified;


                    if (EmailId == 0 && !string.IsNullOrEmpty(Email))
                    {
                        // No previous Email
                        // Create the Email
                        Email email = new Email();
                        email.Address = Email;
                        atlasDB.Emails.Add(email);
                        atlasDB.Entry(email).State = EntityState.Added;

                        InterpreterEmail interpreterEmail = new InterpreterEmail();
                        interpreterEmail.InterpreterId = interpreter.Id;
                        interpreterEmail.EmailId = email.Id;
                        atlasDB.InterpreterEmails.Add(interpreterEmail);
                        atlasDB.Entry(interpreter).State = EntityState.Added;
                    }
                    else
                    {
                        // Get the Email
                        Email email = atlasDB.Emails.Find(EmailId);
                        email.Address = Email;
                        atlasDB.Entry(email).State = EntityState.Modified;
                    }

                    if (AddressId == 0 && !string.IsNullOrEmpty(PostCode))
                    {
                        // No previous Address
                        // Create the Address
                        Location location = new Location();
                        location.Address = Address;
                        location.PostCode = PostCode;
                        atlasDB.Locations.Add(location);

                        //Create the InterpreterLocation
                        InterpreterLocation interpreterLocation = new InterpreterLocation();
                        interpreterLocation.InterpreterId = interpreter.Id;
                        interpreterLocation.LocationId = location.Id;
                        atlasDB.InterpreterLocations.Add(interpreterLocation);
                    }
                    else
                    {
                        // Get the Address
                        Location location = atlasDB.Locations.Find(AddressId);
                        location.Address = Address;
                        location.PostCode = PostCode;
                        location.DateUpdated = DateTime.Now;
                        atlasDB.Entry(location).State = EntityState.Modified;
                    }

                    // Remove any existing InterpreterLanguages
                    var removeLanguages = atlasDB.InterpreterLanguages
                        .Where(il => il.InterpreterId == InterpreterId)
                        .Select(
                           interpreterlanguages => new
                           {
                               InterpreterLanguageId = interpreterlanguages.Id
                           }
                       ).ToList();

                    if (removeLanguages.Count() != 0)
                    {
                        foreach (var removeLanguage in removeLanguages)
                        {
                            InterpreterLanguage interpreterLanguages = atlasDB.InterpreterLanguages.Find(removeLanguage.InterpreterLanguageId);

                            if (interpreterLanguages != null)
                            {
                                atlasDB.InterpreterLanguages.Remove(interpreterLanguages);
                                atlasDB.Entry(interpreterLanguages).State = EntityState.Deleted;
                            }

                        }
                    }

                    // Add the Interpreter Languages
                    var languages = (from fb in formData
                                     where fb.Key.Contains("Languages")
                                     select new { fb.Key, fb.Value });

                    if (languages != null)
                    {
                        foreach (var language in languages)
                        {
                            if (language.Key.Substring(language.Key.Length - 4) == "[Id]")
                            {

                                InterpreterLanguage interpreterLanguage = new InterpreterLanguage();

                                interpreterLanguage.InterpreterId = interpreter.Id;
                                interpreterLanguage.LanguageId = Int32.Parse(language.Value);

                                atlasDB.InterpreterLanguages.Add(interpreterLanguage);
                            }
                        }
                    }


                    // Remove any existing Interpreter Phones 
                    var removePhones = atlasDB.InterpreterPhones
                        .Where(il => il.InterpreterId == InterpreterId)
                        .Select(
                           interpreterphones => new
                           {
                               InterpreterPhoneId = interpreterphones.Id
                           }
                       ).ToList();

                    if (removePhones.Count() != 0)
                    {
                        foreach (var removePhone in removePhones)
                        {
                            InterpreterPhone interpreterPhone = atlasDB.InterpreterPhones.Find(removePhone.InterpreterPhoneId);

                            if (interpreterPhone != null)
                            {
                                atlasDB.InterpreterPhones.Remove(interpreterPhone);
                                atlasDB.Entry(interpreterPhone).State = EntityState.Deleted;
                            }

                        }
                    }

                    // Create the Interpreter Phones
                    var phones = (from fb in formData
                                  where fb.Key.Contains("PhoneNumbers")
                                  select new { fb.Key, fb.Value });

                    if (phones != null)
                    {
                        // Create a list of phone types
                        List<PhoneType> phoneTypes = atlasDB.PhoneTypes.ToList();

                        var phoneNumber = "";
                        int phoneNumberTypeId = 0;

                        foreach (var phone in phones)
                        {
                            if (phone.Key.Substring(phone.Key.Length - 8) == "[Number]")
                            {
                                phoneNumber = phone.Value;
                            }
                            else if (phone.Key.Substring(phone.Key.Length - 6) == "[Type]")
                            {
                                phoneNumberTypeId = getPhoneTypeId(phone.Value, phoneTypes);

                            }
                            if (!String.IsNullOrEmpty(phoneNumber) && phoneNumberTypeId != 0)
                            {
                                InterpreterPhone interpreterPhone = new InterpreterPhone();

                                interpreterPhone.InterpreterId = interpreter.Id;
                                interpreterPhone.PhoneTypeId = phoneNumberTypeId;
                                interpreterPhone.Number = phoneNumber;
                                atlasDB.InterpreterPhones.Add(interpreterPhone);

                                phoneNumber = "";
                                phoneNumberTypeId = 0;
                            }
                        }
                    }

                }
            
                atlasDB.SaveChanges();

                status = "Interpreter Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }


        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/GetInterpreterNotesById/{InterpreterId}")]
        [HttpGet]
        public object GetInterpreterNotesById(int InterpreterId)
        {

            return atlasDBViews.vwInterpreterNotes_SubView
                    .Where(inn => inn.InterpreterId == InterpreterId);

        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/SaveNote")]
        public string SaveNote([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var interpreterId = StringTools.GetInt("interpreterId", ref formData);
            var organisationId = StringTools.GetInt("organisationId", ref formData);
            var noteTypeId = StringTools.GetInt("type", ref formData);
            var userId = StringTools.GetInt("userId", ref formData);
            var text = StringTools.GetString("text", ref formData);

            // Create the Note
            var note = new Note();
            note.Note1 = text;
            note.NoteTypeId = noteTypeId;
            note.DateCreated = DateTime.Now;
            note.CreatedByUserId = userId;
            atlasDB.Notes.Add(note);

            // Create the InterpreterNote
            var interpreterNote = new InterpreterNote();
            interpreterNote.InterpreterId = interpreterId;
            interpreterNote.NoteId = note.Id;
            atlasDB.InterpreterNotes.Add(interpreterNote);
  
            string status = "";

            try
            {
                atlasDB.SaveChanges();

                status = "Interpreter Note Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }

        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/selected/{CourseId}/{OrganisationId}")]
        [HttpGet]
        public object GetSelectedInterpreters(int CourseId, int OrganisationId)
        {
            var selectedInterpreters = atlasDBViews.vwCourseInterpreters
                .Where(x => x.CourseId == CourseId && x.OrganisationId == OrganisationId)
                .Select(theCourseInterpreter => new
                {
                    Id = theCourseInterpreter.InterpreterId,
                    Name = theCourseInterpreter.InterpreterName,
                    FullName = theCourseInterpreter.InterpreterName,
                    InterpreterLanguageList = theCourseInterpreter.InterpreterLanguageList,
                    InterpreterBookedForPractical = theCourseInterpreter.InterpreterForPractical,
                    InterpreterBookedForTheory = theCourseInterpreter.InterpreterForTheory
                }).ToList();
            return selectedInterpreters;
        }

        [AuthorizationRequired]
        [Route("api/InterpreterLanguage/available/{CourseId}/{OrganisationId}")]
        [HttpGet]
        public object GetAvailableInterpreters(int CourseId, int OrganisationId)
        {
            //var availableInterpreters = atlasDBViews.vwCourseAvailableInterpreters
            //    .Where(x => x.CourseId == CourseId && x.OrganisationId == OrganisationId)
            //    .Select(
            //        availableInterpreter => new
            //        {
            //            Id = availableInterpreter.InterpreterId,
            //            Name = availableInterpreter.InterpreterName,
            //            FullName = availableInterpreter.InterpreterName,
            //            InterpreterLanguageList = availableInterpreter.InterpreterLanguageList,
            //        }
            //    )
            //    .ToList();
            var availableInterpreters = atlasDB.Interpreters
                                                .Include(i => i.CourseInterpreters)
                                                .Include(i => i.InterpreterOrganisations)
                                                .Include(i => i.InterpreterLanguages)
                                                .Include(i => i.InterpreterLanguages.Select(il => il.Language))
                                                .Where(
                                                    i => !i.CourseInterpreters.Any(ci => ci.CourseId == CourseId) &&
                                                        i.InterpreterOrganisations.Any(io => io.OrganisationId == OrganisationId)
                                                )
                                                .ToList()
                                                .Select(
                                                    availableInterpreter => new
                                                    {
                                                        Id = availableInterpreter.Id,
                                                        Name = availableInterpreter.DisplayName,
                                                        FullName = availableInterpreter.DisplayName,
                                                        InterpreterLanguageList = String.Join(", ", availableInterpreter.InterpreterLanguages.Select(il => il.Language.EnglishName.ToString()))
                                                    }
                                                )
                                                .ToList();
            return availableInterpreters;
        }


        private int getPhoneTypeId(string phoneTypeName, List<PhoneType> phoneTypes)
        {
            int phoneTypeId = -1;
            foreach (PhoneType phoneType in phoneTypes)
            {
                if (phoneType.Type == phoneTypeName)
                {
                    phoneTypeId = phoneType.Id;
                    break;
                }
            }
            return phoneTypeId;
        }

    }
}