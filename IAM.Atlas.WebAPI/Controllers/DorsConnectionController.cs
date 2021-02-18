using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Globalization;
using IAM.Atlas.WebAPI.Models;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DorsConnectionController : AtlasBaseController
    {

        

        [AuthorizationRequired]
        public object Get(int Id)
        {
            // Validate org belong to the user id in the token
            // will do this as part of another user story

            var connectionDetails = atlasDB.DORSConnections
                .Where(
                    connection => 
                        connection.OrganisationId == Id
                )
                .Select(
                    connection => new {
                        Username = connection.LoginName,
                        Password =connection.Password,
                        Enabled = connection.Enabled,
                        LastChanged = connection.PasswordLastChanged
                    }
                )
                .ToList();


            return connectionDetails;
        }

        [AuthorizationRequired]
        [Route("api/dorsconnection/getall/{UserId}")]
        public object GetAllOrganisations(int UserId)
        {
            // Validate org belong to the user id in the token
            // will do this as part of another user story

            var systemAdminCheck = new SystemAdminController();
            var checkUserIsSystemAdmin = systemAdminCheck.Get(UserId);

            if (checkUserIsSystemAdmin == false)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Failed to authenticate access"),
                        ReasonPhrase = "User not allowed here"
                    }
                );
            }

            var organisationList = 
                atlasDB.OrganisationSystemConfigurations
                .Join(
                    atlasDB.DORSConnections, 
                    organisationSystemConfiguration => organisationSystemConfiguration.OrganisationId,
                    dorsConnection => dorsConnection.OrganisationId,
                    (organisationSystemConfiguration, dorsConnection) => new
                    {
                        Config = organisationSystemConfiguration,
                        Connection = dorsConnection
                    }
                )
                .Select(
                    organisation => new
                    {
                        Id = organisation.Config.OrganisationId,
                        Name = organisation.Config.Organisation.Name,
                        Enabled = organisation.Connection.Enabled
                    }
                )
                .ToList();

            return organisationList;


        }

        [AuthorizationRequired]
        [Route("api/dorsconnection/without/{UserId}")]
        public object GetAllOrganisationsWithoutConnection(int UserId)
        {
            // Validate org belong to the user id in the token
            // will do this as part of another user story

            var systemAdminCheck = new SystemAdminController();
            var checkUserIsSystemAdmin = systemAdminCheck.Get(UserId);

            if (checkUserIsSystemAdmin == false)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Failed to authenticate access"),
                        ReasonPhrase = "User not allowed here"
                    }
                );
            }

            var organisationList = atlasDB.Organisations
                .Include("DORSConnections")
                .Where(
                    organisation =>
                        !(organisation.DORSConnections.Any(
                            dorsConnection => dorsConnection.OrganisationId == organisation.Id
                        ))
                )
                .Select(
                    organisation => new
                    {
                        Id = organisation.Id,
                        Name = organisation.Name
                    }
                )
                .ToList();

            return organisationList;


        }

        [AuthorizationRequired]
        [Route("api/dorsconnection/getallorganisationname")]
        public object GetAllDORSConnectionsOrganisationName()
        {
          
                return atlasDB.DORSConnections
                    .Include("Organisations")
                    .Select(
                       dorsConnections => new
                       {
                           Id = dorsConnections.Id,
                           Name = dorsConnections.Organisation.Name,
                           LoginName = dorsConnections.LoginName
                       }
                   )
                  .ToList();
        }


    [AuthorizationRequired]
        public string Post([FromBody] FormDataCollection formBody)
        {

            var organisationId = 0;

            // Get this user ID ffrom token instead of passing it in
            var userId = 0;

            var dorsConnectionEnabled = 0;
            var dorsConnectionName = formBody["Username"];
            var dorsConnectionPassword = formBody["Password"];



            // Try parse the dorsConnectionEnabled
            if (Int32.TryParse(formBody["Enabled"], out dorsConnectionEnabled)) {
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("We need to know if your connection is enabled or disabled"),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }

            // Try parse the OrganisationId
            if (Int32.TryParse(formBody["OrganisationId"], out organisationId)) {
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("We couldn't verify your organisation"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // Try parse the OrganisationId
            if (Int32.TryParse(formBody["UserId"], out userId)) {
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("We couldn't verify your organisation."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // Check the connection name isnt empty
            if (String.IsNullOrEmpty(dorsConnectionName))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The connection name cannot be empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // Check the connection password isnt empty
            if (String.IsNullOrEmpty(dorsConnectionPassword))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The connection password cannot be empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }



            try {

                var checkDORSConnectionExists = atlasDB.DORSConnections.Where(
                    connection => connection.OrganisationId == organisationId
                )
                .FirstOrDefault();

                DORSConnection dorsConnection = new DORSConnection();


                dorsConnection.LoginName = dorsConnectionName;
                dorsConnection.Password = dorsConnectionPassword;
                dorsConnection.UpdatedByUserId = userId;
                dorsConnection.Enabled = Convert.ToBoolean(dorsConnectionEnabled);
                dorsConnection.OrganisationId = organisationId;

                //
                if (checkDORSConnectionExists == null)
                {
                    atlasDB.DORSConnections.Add(dorsConnection);
                }

                // 
                if (checkDORSConnectionExists != null)
                {

                    if (checkDORSConnectionExists.Password != dorsConnectionPassword) {
                        dorsConnection.PasswordLastChanged = DateTime.Now;
                    }

                    dorsConnection.Id = checkDORSConnectionExists.Id;
                    var dorsEntry = atlasDB.Entry(checkDORSConnectionExists);
                    dorsEntry.CurrentValues.SetValues(dorsConnection);
                }


                atlasDB.SaveChanges();

                return "success";

            } catch (DbEntityValidationException ex) {

                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }



        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [AuthorizationRequired]
        [HttpGet]
        [Route("api/dorsconnection/GetAvailableForDefaultRotation/{UserId}")]
        public List<DORSConnectionJSON> GetAvailableForDefaultRotation(int UserId)
        {
            var availableConnections = new List<DORSConnectionJSON>();
            var systemController = new SystemAdminController();
            if (systemController.Get(UserId))   // is the user a system admin?
            {
                availableConnections = atlasDB.DORSConnections
                                                    .Include(dc => dc.Organisation)
                                                    .Where(
                                                        dc => !dc.DORSConnectionForRotations.Any(dcfr => dcfr.DORSConnectionId == dc.Id) &&
                                                        dc.Enabled == true
                                                    )
                                                    .Select(dc => new DORSConnectionJSON()
                                                    {
                                                        Id = dc.Id,
                                                        Name = dc.LoginName + " (" + dc.Organisation.Name + ")"
                                                    })
                                                    .ToList();
            }            
            return availableConnections;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/dorsconnection/GetSelectedForDefaultRotation/{UserId}")]
        public List<DORSConnectionJSON> GetSelectedForDefaultRotation(int UserId)
        {
            var systemController = new SystemAdminController();
            var selectedConnections = new List<DORSConnectionJSON>();
            if (systemController.Get(UserId))   // is the user a system admin?
            {
                selectedConnections = atlasDB.DORSConnections
                                    .Include(dc => dc.Organisation)
                                    .Where(
                                        dc => dc.DORSConnectionForRotations.Any(dcfr => dcfr.DORSConnectionId == dc.Id) &&
                                        dc.Enabled == true
                                    )
                                    .Select(dc => new DORSConnectionJSON()
                                    {
                                        Id = dc.Id,
                                        Name = dc.LoginName + " (" + dc.Organisation.Name + ")"
                                    })
                                    .ToList();
            }
            return selectedConnections;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/dorsconnection/SelectForDefaultRotation/{DORSConnectionId}/{UserId}")]
        public int SelectForDefaultRotation(int DORSConnectionId, int UserId)
        {
            int selectedForRotationId = -1;
            var systemController = new SystemAdminController();
            if (systemController.Get(UserId))   // is the user a system admin?
            {
                var selectedForRotation = new DORSConnectionForRotation();
                selectedForRotation.DORSConnectionId = DORSConnectionId;
                selectedForRotation.DateAdded = DateTime.Now;
                selectedForRotation.AddedByUserId = UserId;

                atlasDB.DORSConnectionForRotations.Add(selectedForRotation);
                atlasDB.SaveChanges();

                selectedForRotationId = selectedForRotation.Id;
            }
            return selectedForRotationId;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/dorsconnection/DeselectFromDefaultRotation/{DORSConnectionId}/{UserId}")]
        public bool DeselectFromDefaultRotation(int DORSConnectionId, int UserId)
        {
            var deselected = false;
            var systemController = new SystemAdminController();
            if (systemController.Get(UserId))   // is the user a system admin?
            {
                var toBeDeselected = atlasDB.DORSConnectionForRotations.Where(dcfr => dcfr.DORSConnectionId == DORSConnectionId).FirstOrDefault();

                var dbentry = atlasDB.Entry(toBeDeselected);
                dbentry.State = System.Data.Entity.EntityState.Deleted;
                atlasDB.SaveChanges();
                deselected = true;
            }
            return deselected;
        }
    }
}