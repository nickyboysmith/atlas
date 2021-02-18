using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is used to return a light weight serialized JSON object to client 
    /// </summary>
    public class TrainerJSON
    {
        public string Title { get; set; }
        public string FirstName { get; set; }
        public string OtherNames { get; set; }
        public string Surname { get; set; }
        public string DateofBirth { get; set; }
        public string ProfilePicture { get; set; }
        public string DisplayName { get; set; }
        public string UserName { get; set; }
        public List<trainerLicence> Licences { get; set; }
        public List<TheTrainerAddress> Addresses { get; set; }
        public List<TheEmails> Emails { get; set; }
        public List<phone> PhoneNumbers { get; set; }
        public string DORSTrainerIdentifier { get; set; }

        public TrainerJSON()
        {
            Licences = new List<trainerLicence>();
            Addresses = new List<TheTrainerAddress>();
            Emails = new List<TheEmails>();
            PhoneNumbers = new List<phone>();
        }

        public TrainerJSON(Trainer trainer)
        {
            Licences = new List<trainerLicence>();
            Addresses = new List<TheTrainerAddress>();
            Emails = new List<TheEmails>();
            PhoneNumbers = new List<phone>();

            Title = trainer.Title;
            FirstName = trainer.FirstName;
            Surname = trainer.Surname;
            OtherNames = trainer.OtherNames;
            DateofBirth = trainer.DateOfBirth.ToString();
            ProfilePicture = trainer.PictureName;
            DisplayName = trainer.DisplayName;
            UserName = trainer.UserId.HasValue ? trainer.User.LoginId : "";
            Licences = TransformLicences(trainer.TrainerLicence);
            Addresses = TransformLocations(trainer.TrainerLocation);
            Emails = TransformEmails( trainer.TrainerEmail );
            PhoneNumbers = TransformPhones(trainer.TrainerPhone );
        }        

        // have to set the licenses up via public functions so we can use them in a linq call (which needs a parameterless constructor).
        public static List<trainerLicence> TransformLicences(ICollection<TrainerLicence> trainerLicences)
        {
            List<trainerLicence> transformedLicences = new List<trainerLicence>();
            foreach (var trainerLicence in trainerLicences)
            {
                if (!string.IsNullOrEmpty(trainerLicence.LicenceNumber) && trainerLicence.DriverLicenceTypeId != null)
                {
                    transformedLicences.Add(new trainerLicence(trainerLicence.LicenceNumber, trainerLicence.LicenceExpiryDate, trainerLicence.LicencePhotoCardExpiryDate, (int)trainerLicence.DriverLicenceTypeId, trainerLicence.Id));
                }
            }
            return transformedLicences;
        }

        public static List<TheTrainerAddress> TransformLocations(ICollection<TrainerLocation> trainerLocations)
        {
            List<TheTrainerAddress> transformedLocations = new List<TheTrainerAddress>();
            foreach (var trainerAddress in trainerLocations)
            {
                if (trainerAddress.Location != null)
                {
                    if (!string.IsNullOrEmpty(trainerAddress.Location.Address))
                    {
                        transformedLocations.Add(new TheTrainerAddress(trainerAddress.Location.Address, trainerAddress.Location.PostCode, trainerAddress.Id, trainerAddress.LocationId) );
                    }
                }
            }
            return transformedLocations;
        }

        public static List<TheEmails> TransformEmails(ICollection<TrainerEmail> trainerEmails)
        {
            List<TheEmails> transformedEmails = new List<TheEmails>();
            foreach (var trainerEmail in trainerEmails)
            {
                if (trainerEmail.Email != null && !string.IsNullOrEmpty(trainerEmail.Email.Address))
                {
                    transformedEmails.Add(new TheEmails(trainerEmail.Id, trainerEmail.EmailId, trainerEmail.Email.Address));
                } 
            }
            return transformedEmails;
        }

        public static List<phone> TransformPhones(ICollection<TrainerPhone> trainerPhones)
        {
            List<phone> transformedPhones = new List<phone>();
            foreach (var trainerPhone in trainerPhones)
            {
                if (!string.IsNullOrEmpty(trainerPhone.Number) && trainerPhone.PhoneType != null)
                {
                    transformedPhones.Add(new phone(trainerPhone.Number, trainerPhone.PhoneType.Type, trainerPhone.Id, trainerPhone.PhoneType.Id));
                }
            }
            return transformedPhones;
        }

        public class trainerLicence
        {
            public int Id { get; set; }
            public string Number { get; set; }
            public DateTime? ExpiryDate { get; set; }

            public DateTime? PhotocardExpiryDate { get; set; }
            public int Type { get; set; }

            public trainerLicence(string Number, DateTime? ExpiryDate, DateTime? PhotocardExpiryDate, int Type, int Id)
            {
                this.Id = Id;
                this.Number = Number;
                this.ExpiryDate = ExpiryDate;
                this.PhotocardExpiryDate = PhotocardExpiryDate;
                this.Type = Type;

            }
        }

        public class phone
        {
            public int Id { get; set; }
            public int PhoneTypeId { get; set; }

            public string Number { get; set; }
            public string NumberType { get; set; }

            public phone(string Number, string NumberType, int Id, int PhoneTypeId)
            {
                this.Id = Id;
                this.PhoneTypeId = PhoneTypeId;
                this.Number = Number;
                this.NumberType = NumberType;
            }
        }

        public class TheTrainerAddress
        {
            public int Id { get; set; }
            public int LocationId { get; set; }
            public string Address { get; set;  }
            public string Postcode { get; set; }

            public TheTrainerAddress(string Address, string Postcode, int Id, int LocationId)
            {
                this.Id = Id;
                this.LocationId = LocationId;
                this.Address = Address;
                this.Postcode = Postcode;
            }
        }

        public class TheEmails
        {
            public int Id { get; set; }
            public int EmailId { get; set; }
            public string Address { get; set; }
            public TheEmails(int Id, int EmailId, string Address)
            {
                this.Id = Id;
                this.EmailId = EmailId;
                this.Address = Address;
            }
        }
    }

    public class TrainerNotesJSON
    {
        public DateTime Date { get; set; }
        public string Type { get; set; }
        public string User { get; set; }
        public string Text { get; set; }
    }
}