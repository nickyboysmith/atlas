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
    public class VenueJSON
    {
        public VenueJSON()
        {
        }
        public VenueJSON(Venue venue)
        {
            id = venue.Id;
            organisationId = venue.OrganisationId;
            title = venue.Title;
            prefix = venue.Prefix;
            description = venue.Description;
            notes = venue.Notes;
            address = venue.VenueAddress.Count > 0 ? venue.VenueAddress.FirstOrDefault().Location.Address : "";
            postCode = venue.VenueAddress.Count > 0 ? venue.VenueAddress.FirstOrDefault().Location.PostCode : "";
            directions = venue.VenueDirections.Count > 0
                ? venue.VenueDirections.FirstOrDefault().Directions
                : "";
            emails = this.returnEmailList(venue);
        }

        private List<venueEmail> returnEmailList(Venue venue)
        {
            var venueEmailResult = new List<venueEmail>();
            foreach (var emailRecord in venue.VenueEmail)
            {
                venueEmailResult.Add(new venueEmail
                {
                    id = emailRecord.Id,
                    emailAddress = emailRecord.Email.Address,
                    mainEmail = emailRecord.MainEmail.HasValue ? emailRecord.MainEmail.Value : false
                });
            }
            return venueEmailResult;
        }

        public int id { get; set; }
        public int organisationId { get; set; }
        public string title { get; set; }
        public string prefix { get; set; }
        public string description { get; set; }
        public string notes { get; set; }
        public bool disabled { get; set; }
        public string address { get; set; }
        public string postCode { get; set; }
        public string directions { get; set; }
        public List<venueEmail> emails { get; set; }

        public class venueEmail
        {
            public int id { get; set; }
            public bool mainEmail { get; set; }
            public string emailAddress { get; set; }

        }
    }
}