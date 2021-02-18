using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class VenueController : AtlasBaseController
    {
        public struct VenueLists
        {
            public int Id { get; set; }
            public string Title { get; set; }
        }

        protected FormDataCollection formData;

        [AuthorizationRequired]
        [Route("api/Venue/{organisationID}")]
        [HttpGet]
        public object Get(int organisationID)
        {
            var organisationVenues = atlasDBViews.vwVenueDetails
                .Where(
                    venueDetails => venueDetails.OrganisationId == organisationID
                )
                .Select(v => new {
                    v.Id,
                    v.Title,
                    v.Enabled,
                    v.AdditionalInformation,
                    v.DORSVenue
                })
                .ToList();
            return organisationVenues;
        }

        [AuthorizationRequired]
        [Route("api/Venue/GetVenuesWithDorsCheck/{organisationID}/{dorsVenue}")]
        [HttpGet]
        public object GetVenuesWithDorsCheck(int organisationID, string dorsVenue)
        {
            bool dorsVenueCheck = (dorsVenue == "true");
            var organisationVenues = atlasDBViews.vwVenueDetails
                .Where(
                    venueDetails => venueDetails.OrganisationId == organisationID && venueDetails.DORSVenue == dorsVenueCheck
                )
                .Select(v => new {
                    v.Id,
                    v.Title,
                    v.Enabled,
                    v.AdditionalInformation,
                    v.DORSVenue
                })
                .OrderBy(o=> o.Title)
                .ToList();
            return organisationVenues;
        }

        [AuthorizationRequired]
        [Route("api/Venue/{organisationID}/{regionID}")]
        [HttpGet]
        public object Get(int organisationID, int? regionID)
        {
            //var organisationVenues = atlasDB.Venue
            //                                .Include("VenueRegions")
            //                                .Where(x=>x.OrganisationId == organisationID
            //                                       && x.VenueRegions.Any(y=> string.IsNullOrEmpty(regionID.ToString()) ? true : y.RegionId == regionID))
            //                                .Select(v=> new
            //                                                {
            //                                                    v.Id,
            //                                                    v.Title,
            //                                                    v.Enabled
            //                                })
            //                                .ToList();
            //return organisationVenues;

            // Need Venues displaying if not allocated to a region.
            // If this is the case, Set RegionId to -1 and Enabled to false.
            // From the Venue page, the user cannot select the venue but it appears with data error
            // Implemented because Venues created in DORS were being pulled in with no associated regions    
            var organisationVenues = atlasDB.Venue
                                .Include("VenueRegions")
                                .Where(x => x.OrganisationId == organisationID)
                                .Select(v => new
                                {
                                    Id = v.Id,
                                    RegionId = v.VenueRegions.FirstOrDefault().RegionId == null ? -1 : v.VenueRegions.FirstOrDefault().RegionId,
                                    Title = v.VenueRegions.FirstOrDefault().VenueId == null ? v.Title + " (No Region)" : v.Title,
                                    Enabled = v.VenueRegions.FirstOrDefault().RegionId == null ? false : v.Enabled
                                });
                                
            if (regionID != null)
            {

                organisationVenues = organisationVenues
                            .Where(u => u.RegionId == regionID);

                var results = organisationVenues
                       .Select(v => new
                       {
                           Id = v.Id,
                           Title = v.Title,
                           Enabled = v.Enabled
                       });

                return results.ToList();
            }
            
            return organisationVenues.ToList();
            
        }

        [AuthorizationRequired]
        [Route("api/Venue/GetVenue/{venueId}/{userId}")]
        public object GetVenue(int venueId, int userId)
        {
            var venues = 
                atlasDB.Venue
                .Include("VenueDirections")
                .Include("VenueEmail.Email")
                .Include("VenueAddress.Location")
                .Include("VenueCourseType")
                .Include("VenueCourseType.CourseType")
                .Include("VenueLocales")
                .Include("VenueRegions")
                .Include(v => v.DORSSiteVenues)
                .Include(v => v.DORSSiteVenues.Select(dsv => dsv.DORSSite))
                .Where(v => v.Id == venueId)
                .Select(
                    venue => new
                    {
                        id = venue.Id,
                        selectedRegion = venue.VenueRegions.FirstOrDefault() == null ? -1 : venue.VenueRegions.FirstOrDefault().RegionId,
                        prefix = venue.Prefix,
                        title = venue.Title,
                        notes = venue.Notes,
                        enabled = venue.Enabled,
                        description = venue.Description,
                        postCode = venue.VenueAddress.FirstOrDefault() == null ? "" : venue.VenueAddress.FirstOrDefault().Location.PostCode,
                        address = venue.VenueAddress.FirstOrDefault() == null ? "" : venue.VenueAddress.FirstOrDefault().Location.Address,
                        directions = venue.VenueDirections.FirstOrDefault() == null ? "" : venue.VenueDirections.FirstOrDefault().Directions,
                        DORSVenue = venue.DORSVenue,
                        DORSIdentifier = venue.DORSSiteVenues.FirstOrDefault() == null ? -1 : venue.DORSSiteVenues.FirstOrDefault().DORSSite.DORSSiteIdentifier,
                        emails = venue.VenueEmail.Select(theEmails => new
                        {
                            id = theEmails.Id,
                            mainEmail = theEmails.MainEmail,
                            emailAddress = theEmails.Email.Address
                        }),
                        courseTypes = venue.VenueCourseType.Select(course => new
                        {
                            id = course.Id,
                            courseTypeName = course.CourseType.Title
                        }),
                        venueLocales = venue.VenueLocales.Select(theVenue => new
                        {
                            Id = theVenue.Id,
                            Name = theVenue.Title,
                            Enabled = theVenue.Enabled
                        }),
                        venueCosts = venue.VenueCost.Select(theVenueCost => new
                        {
                            id = theVenueCost.Id,
                            costTypeName = theVenueCost.VenueCostType.Name,
                            cost = theVenueCost.Cost
                        })
                    }
                )
                .ToList();

            return venues; 


        }

        [AuthorizationRequired]
        [Route("api/Venue/Location/{VenueId}")]
        [HttpGet]
        public object GetVenueAddress(int VenueId)
        {
            var venueAddress = new object { };

            try
            {

                venueAddress = atlasDB.Venue
                    .Include("VenueAddress")
                    .Include("VenueAddress.Location")
                    .Where(
                        venue =>
                            venue.Id == VenueId
                    )
                    .Select(
                        theVenue => new
                        {
                            theVenue.VenueAddress.FirstOrDefault().Location.Address,
                            theVenue.VenueAddress.FirstOrDefault().Location.PostCode
                        }
                    )
                    .ToList();

            }  catch (DbEntityValidationException ex) {
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Something has gone wrong trying to get your venue address. Please retry!");
            } catch (Exception ex) {
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Their has been an issue retrieving the venue address. Please retry!");
            }

            return venueAddress;
        }

        //POST: api/Venue
        public int Post([FromBody] FormDataCollection formBody)
        {
            this.formData = formBody;

            if (formBody.Count() > 0)
            {
                var id = StringTools.GetInt("id", ref formData);
                var organisationId = StringTools.GetInt("organisationId", ref formData);
                var selectedOrganisation = StringTools.GetInt("selectedOrganisation", ref formData);
                var selectedRegion = StringTools.GetInt("selectedRegion", ref formData);
                var title = StringTools.GetString("title", ref formData);
                var prefix = StringTools.GetString("prefix", ref formData);
                var description = StringTools.GetString("description", ref formData);
                var notes = StringTools.GetString("notes", ref formData);
                var address = StringTools.GetString("address", ref formData);
                var postCode = StringTools.GetString("postCode", ref formData);
                var directions = StringTools.GetString("directions", ref formData);
                var disabled = StringTools.GetBool("disabled", ref formData);
                var DORSVenue = StringTools.GetBool("DORSVenue", ref formData);
                var emails = this.GetVenueEmailList();

                var venue = new Venue();
                
                if (id > 0)
                {
                    //treat as an existing venue
                    venue = atlasDB.Venue
                                   .Include("VenueDirections")
                                   .Include("VenueEmail.Email")
                                   .Include("VenueAddress.Location")
                                   .Include("VenueRegions")
                                   .Where(v => v.Id == id).First();
                }
                else
                {
                    venue.OrganisationId = selectedOrganisation;
                }

                //Persist Venue Table Data
                venue.Title = title;
                venue.Prefix = prefix;
                venue.Description = description;
                venue.Notes = notes;
                venue.Enabled = !disabled;
                venue.DORSVenue = DORSVenue;

                //Persist VenueDirections Table Data
                if (venue.VenueDirections.Count > 0)
                {
                    venue.VenueDirections.First().Directions = directions;
                }
                else
                {
                    //Create VenueDirections entry
                    venue.VenueDirections.Add(new VenueDirections { Directions = directions });
                }

                //Persist VenueRegions Table Data
                if(venue.VenueRegions.Any(x=>x.RegionId == selectedRegion))
                {
                    //Do nothing: the enue has already been assigned to the region
                }
                else
                {
                    venue.VenueRegions.Add(new VenueRegion { RegionId = selectedRegion });
                }

                //Persist VenueAddress Table Data
                if (venue.VenueAddress.Count > 0)
                {
                    venue.VenueAddress.First().Location.Address = address;
                    venue.VenueAddress.First().Location.PostCode = postCode;
                }
                else
                {
                    //Create a Location/VenueAddress
                    var newLocation = new Location { Address = address, PostCode = postCode };
                    var venueAddress = new VenueAddress { Location = newLocation };
                    venue.VenueAddress.Add(venueAddress);
                }

                //Persist emails: for new venues and new emails the emailRecordId will be 0
                if (emails.Count > 0)
                {
                    if (!(id > 0))
                    {
                        //If this is a new Venue, simply add the emails
                        foreach (var email in emails)
                        {
                            VenueEmail newVenueEmail = new VenueEmail
                            {
                                Email = new Email { Address = email.emailAddress },
                                MainEmail = email.mainEmail
                            };
                            venue.VenueEmail.Add(newVenueEmail);
                        }
                    }
                    else
                    {
                        //Otherwise save/add new based on emailRecordId not being 0
                        foreach (var email in emails)
                        {
                            //Add if a new email
                            if (email.id == 0)
                            {
                                if (!string.IsNullOrEmpty(email.emailAddress))
                                {
                                    VenueEmail newVenueEmail = new VenueEmail
                                    {
                                        Email = new Email { Address = email.emailAddress },
                                        MainEmail = email.mainEmail
                                    };
                                    venue.VenueEmail.Add(newVenueEmail);
                                }
                            }
                            else
                            {
                                //Retrieve and update if an existing email
                                var emailToBeUpdated = atlasDB.VenueEmail
                                                              .Include("Email")
                                                              .Where(v => v.Id == email.id).First();
                                if (!string.IsNullOrWhiteSpace(email.emailAddress))
                                {
                                    emailToBeUpdated.Email.Address = email.emailAddress;
                                    emailToBeUpdated.MainEmail = email.mainEmail;

                                    var dbEntry = atlasDB.Entry(emailToBeUpdated);
                                    dbEntry.State = EntityState.Modified;
                                }
                                else
                                {
                                    //But if the email address has been removed, treat this as a delete
                                    atlasDB.Emails.Remove(emailToBeUpdated.Email);
                                    atlasDB.VenueEmail.Remove(emailToBeUpdated);
                                }
                            }
                        }
                    }
                }
                
                if (!(id > 0))
                {
                    atlasDB.Venue.Add(venue);
                }
                atlasDB.SaveChanges();
                return venue.Id;
            } 
            else
            {
                return 0;
            }          
        }
        /// <summary>
        /// Traverses the submitted form data for elements relating to the venue email id and extracts these and thir correcponding email addresses and
        ///  'main' status to a useable list of venue emails
        /// </summary>
        /// <returns></returns>
        private List<VenueJSON.venueEmail> GetVenueEmailList()
        {
            var venueEmails = new List<VenueJSON.venueEmail>();
            var emailNumber = 0;
            var emailFound = true;

            while (emailFound)
            {
                var emailRecordId = formData.Get("emails[" + emailNumber + "][id]");
                if (emailRecordId != null)
                {
                    venueEmails.Add(new VenueJSON.venueEmail
                    {
                        id = StringTools.GetInt("emails[" + emailNumber + "][id]", ref formData),
                        emailAddress = StringTools.GetString("emails[" + emailNumber + "][emailAddress]", ref formData),
                        mainEmail = StringTools.GetBool("emails[" + emailNumber + "][mainEmail]", ref formData)
                    });
                    emailNumber++;
                }
                else
                {
                    emailFound = false;
                }
            }

            return venueEmails;
        }

        [HttpGet]
        [Route("api/Venue/AddRegion/{venueId}/{regionId}/{userId}/{organisationId}")]
        public bool AddRegion(int venueId, int regionId, int userId, int organisationId)
        {
            bool regionAdded = false;
            if(UserHasOrganisationAdminStatus(userId, organisationId) || UserHasSystemAdminStatus(userId))
            {
                var venueRegion = new VenueRegion();
                venueRegion.RegionId = regionId;
                venueRegion.VenueId = venueId;

                atlasDB.VenueRegions.Add(venueRegion);
                atlasDB.SaveChanges();

                regionAdded = true;
            }
            return regionAdded;
        }
    }
}