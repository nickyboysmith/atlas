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
    public class ClientJSON
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string DisplayName { get; set; }

        public string FirstName { get; set; }
        public string Surname { get; set; }
        public bool EmailedConfirmed { get; set; }
        public bool SMSConfirmed { get; set; }
        public string OtherNames { get; set; }
        public List<clientLicence> Licences { get; set; }
        public List<string> Addresses { get; set; }
        public List<string> Emails { get; set; }
        public List<phone> PhoneNumbers { get; set; }
        public DateTime? DateOfBirth { get; set; }

        public ClientJSON()
        {
            Licences = new List<clientLicence>();
            Addresses = new List<string>();
            Emails = new List<string>();
            PhoneNumbers = new List<phone>();
        }

        public ClientJSON(Client client)
        {
            Licences = new List<clientLicence>();
            Addresses = new List<string>();
            Emails = new List<string>();
            PhoneNumbers = new List<phone>();

            Id = client.Id;
            Title = client.Title;
            DisplayName = client.DisplayName;
            FirstName = client.FirstName;
            EmailedConfirmed = Convert.ToBoolean(client.EmailedConfirmed);
            SMSConfirmed = Convert.ToBoolean(client.SMSConfirmed);
            Surname = client.Surname;
            OtherNames = client.OtherNames;


            Licences = TransformLicences(client.ClientLicences);

            Addresses = TransformLocations(client.ClientLocations);

            Emails = TransformEmails(client.ClientEmails);
            
            PhoneNumbers = TransformPhones(client.ClientPhones);
        }

        // have to set the licenses up via public functions so we can use them in a linq call (which needs a parameterless constructor).
        public static List<clientLicence> TransformLicences(ICollection<ClientLicence> clientLicences)
        {
            List<clientLicence> transformedLicences = new List<clientLicence>();
            foreach (var clientLicence in clientLicences)
            {
                if (!string.IsNullOrEmpty(clientLicence.LicenceNumber) && clientLicence.LicenceExpiryDate != null && clientLicence.DriverLicenceTypeId != null)
                {
                    transformedLicences.Add(new clientLicence(clientLicence.LicenceNumber, clientLicence.LicenceExpiryDate.ToString(), clientLicence.LicencePhotoCardExpiryDate.ToString(), (int)clientLicence.DriverLicenceTypeId));
                }
            }
            return transformedLicences;
        }

        public static List<string> TransformLocations(ICollection<ClientLocation> clientLocations)
        {
            List<string> transformedLocations = new List<string>();
            foreach (var clientAddress in clientLocations)
            {
                if (clientAddress.Location != null)
                {
                    if (!string.IsNullOrEmpty(clientAddress.Location.Address))
                    {
                        transformedLocations.Add(clientAddress.Location.Address);
                    }
                }
            }
            return transformedLocations;
        }

        public static List<string> TransformEmails(ICollection<ClientEmail> clientEmails)
        {
            List<string> transformedEmails = new List<string>();
            foreach (var clientEmail in clientEmails)
            {
                if (clientEmail.Email != null && !string.IsNullOrEmpty(clientEmail.Email.Address)) transformedEmails.Add(clientEmail.Email.Address);
            }
            return transformedEmails;
        }

        public static List<phone> TransformPhones(ICollection<ClientPhone> clientPhones)
        {
            List<phone> transformedPhones = new List<phone>();
            foreach (var clientPhone in clientPhones)
            {
                if (!string.IsNullOrEmpty(clientPhone.PhoneNumber) && clientPhone.PhoneType != null)
                {
                    transformedPhones.Add(new phone(clientPhone.PhoneNumber, clientPhone.PhoneType.Type));
                }
            }
            return transformedPhones;
        }

        public class clientLicence
        {
            public string Number { get; set; }
            public string ExpiryDate { get; set; }

            public string PhotocardExpiryDate { get; set; }
            public int Type { get; set; }

            public clientLicence(string Number, string ExpiryDate, string PhotocardExpiryDate, int Type)
            {
                this.Number = Number;
                this.ExpiryDate = ExpiryDate;
                this.PhotocardExpiryDate = PhotocardExpiryDate;
                this.Type = Type;
            }
        }

        public class phone
        {
            public string Number { get; set; }
            public string NumberType { get; set; }

            public phone(string Number, string NumberType)
            {
                this.Number = Number;
                this.NumberType = NumberType;
            }
        }
    }
}