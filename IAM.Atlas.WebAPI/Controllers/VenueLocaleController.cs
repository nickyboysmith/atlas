using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class VenueLocaleController : AtlasBaseController
    {



        // Gets all venue locales related to the venue
        [AuthorizationRequired]
        public object Get(int Id)
        {
            var relatedVenueLocale = atlasDB.VenueLocales
                .Where(
                    venue => venue.VenueId == Id
                )
                .Select(
                    theVenue => new
                    {
                        Id = theVenue.Id,
                        VenueId = theVenue.VenueId,
                        Name = theVenue.Title
                    }
                )
                .ToList();

            return relatedVenueLocale;
        }

        // gets the venue lcale details
        [AuthorizationRequired]
        [Route("api/venuelocale/single/{VenueLocaleId}")]
        public object GetSingle(int VenueLocaleId)
        {

            var venueLocale = atlasDB.VenueLocales
                .Where(
                    venue => venue.Id == VenueLocaleId
                )
                .Select(
                    theLocale => new
                    {
                        VenueLocaleId = theLocale.Id,
                        theLocale.Description,
                        theLocale.Enabled,
                        ReservedPlaces = theLocale.DefaultReservedPlaces,
                        MaximumPlaces = theLocale.DefaultMaximumPlaces,
                        theLocale.Title
                    }
                )
                .FirstOrDefault();

            return venueLocale;
        }

        [AuthorizationRequired]
        public object Post([FromBody] FormDataCollection formBody)
        {

            var title = formBody["Title"];
            var venueId = 0;
            var venueLocaleId = 0;
            var maximumPlaces = 0;
            var reservedPlaces = 0;
            var enabled = 0;


            // Check the venue id 
            if (Int32.TryParse(formBody["VenueId"], out venueId)) {
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("We couldn't verify your venue."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // check the title isnt empty
            if (String.IsNullOrEmpty(title)) {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The title is empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // Check to see if the venueLocaleId string exists
            // then convert it into an integer
            if (!String.IsNullOrEmpty(formBody["VenueLocaleId"]))
            {
                if (Int32.TryParse(formBody["VenueLocaleId"], out venueLocaleId)) {
                } else {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("Venue Locale Id must be a number."),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }
            }

            // Check to see if the maximum places string exists
            // then convert it into an integer
            if (!String.IsNullOrEmpty(formBody["MaximumPlaces"]))
            {
                if (Int32.TryParse(formBody["MaximumPlaces"], out maximumPlaces))
                {
                }
                else {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("Maximum places must be a number."),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }
            }

            // Check to see if the resrrved places string exists
            // then convert it into an integer
            if (!String.IsNullOrEmpty(formBody["ReservedPlaces"]))
            {
                if (Int32.TryParse(formBody["ReservedPlaces"], out reservedPlaces)) {
                } else {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("Reserved places must be a number."),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }
            }

            // check to see if the enabled flag is set
            // If it is then convert into an int
            if (!String.IsNullOrEmpty(formBody["Enabled"]))
            {
                if (Int32.TryParse(formBody["Enabled"], out enabled)) {
                } else {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("The enabled flag can not be text."),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }
            }


            try
            {

                var checkVenueLocaleExists = atlasDB.VenueLocales.Where(
                    venue => venue.Id == venueLocaleId
                )
                .FirstOrDefault();

                VenueLocale venueLocale = new VenueLocale();

                venueLocale.VenueId = venueId;

                // If maximum places is set
                // add to the venueLocale object
                if (!String.IsNullOrEmpty(formBody["MaximumPlaces"])) {
                    venueLocale.DefaultMaximumPlaces = maximumPlaces;
                }

                // If resrved places is set
                // add to the venueLocale object
                if (!String.IsNullOrEmpty(formBody["ReservedPlaces"])) {
                    venueLocale.DefaultReservedPlaces = reservedPlaces;
                }

                // If resrved places is set
                // add to the venueLocale object
                if (!String.IsNullOrEmpty(formBody["Description"]))
                {
                    venueLocale.Description = formBody["Description"];
                }

                // If no venueLocaleId add
                if (checkVenueLocaleExists == null) {
                    venueLocale.Title = title;
                    atlasDB.VenueLocales.Add(venueLocale);
                }

                if (checkVenueLocaleExists != null) {
                    venueLocale.Id = checkVenueLocaleExists.Id;
                    venueLocale.Title = checkVenueLocaleExists.Title;

                    // Check the enabled flag has been set
                    // if it has add it tot he object
                    if (!String.IsNullOrEmpty(formBody["Enabled"]))
                    {
                        venueLocale.Enabled = Convert.ToBoolean(enabled);
                    }

                    var venueLocaleEntry = atlasDB.Entry(checkVenueLocaleExists);
                    venueLocaleEntry.CurrentValues.SetValues(venueLocale);
                }

                atlasDB.SaveChanges();

                return "Venue Locale saved successfully";

            } catch ( DbEntityValidationException ex ) {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

        }

        

    }
}