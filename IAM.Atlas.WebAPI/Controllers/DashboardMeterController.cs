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
using System.Web.Http.ModelBinding;
using IAM.Atlas.WebAPI.Classes;


namespace IAM.Atlas.WebAPI.Controllers
{
    public class DashboardMeterController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/dashboardMeter/getmeters/")]
        [HttpGet]
        public object GetMeters()
        {
            try
            {
                return atlasDB.DashboardMeters.ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/dashboardMeter/getmeterdetails/{MeterId}")]
        [HttpGet]
        public object GetMeterDetails(int MeterId)
        {
            try
            {

                return atlasDB.DashboardMeters
                            .Where(dm => dm.Id == MeterId).ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/dashboardMeter/getavailableorganisations/{MeterId}")]
        [HttpGet]
        public object GetAvailableOrganisations(int MeterId)
        {
            try
            {

                // return atlasDB.OrganisationDashboardMeters
                //            .Include("Organisation")
                //            .Where(odb => odb.DashboardMeterId == MeterId)
                //            .Select(
                //    odm => new
                //    {
                //        Id = odm.Organisation.Id,
                //        Name = odm.Organisation.Name

                //    }
                //).ToList();

                var availableOrganisations =
                    (
                        from odm in atlasDB.OrganisationDashboardMeters
                        join o in atlasDB.Organisations on odm.OrganisationId equals o.Id
                        where !atlasDB.DashboardMeterExposures.Any(dme => (dme.OrganisationId == odm.OrganisationId && dme.DashboardMeterId == odm.DashboardMeterId)) && odm.DashboardMeterId == 1
                        select new
                        {
                            Id = o.Id,
                            Name = o.Name
                        }
                );

                return availableOrganisations.ToList();


            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/dashboardMeter/getexposedorganisations/{MeterId}")]
        [HttpGet]
        public object GetExposedOrganisations(int MeterId)
        {
            try
            {
                return atlasDB.DashboardMeterExposures
                            .Include("Organisation")
                            .Where(odb => odb.DashboardMeterId == MeterId)
                            .Select(
                    odm => new
                    {
                        Id = odm.Organisation.Id,
                        Name = odm.Organisation.Name

                    }
                ).ToList();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/dashboardMeter/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {

            var dashboardMeter = formBody.ReadAs<DashboardMeter>();

            atlasDB.DashboardMeters.Attach(dashboardMeter);
            var entry = atlasDB.Entry(dashboardMeter);
            entry.State = System.Data.Entity.EntityState.Modified;
            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }
        
        [AuthorizationRequired]
        [Route("api/dashboardMeter/SaveExposureUpdate")]
        [HttpPost]
        public void SaveExposureUpdate([FromBody] FormDataCollection formBody)
        {

            var action = StringTools.GetString("action", ref formBody);
            var meterId = StringTools.GetInt("meterId", ref formBody);
            var organisationId = StringTools.GetInt("organisationId", ref formBody);

            if (action == "add")
            {

                var dashboardMeterExposure = new DashboardMeterExposure();
                dashboardMeterExposure.DashboardMeterId = meterId;
                dashboardMeterExposure.OrganisationId = organisationId;

                atlasDB.DashboardMeterExposures.Add(dashboardMeterExposure);

            }
            else if (action == "remove")
            {
                var dashboardMeterExposureToRemove = new DashboardMeterExposure();

                dashboardMeterExposureToRemove = atlasDB.DashboardMeterExposures.Where(dme => dme.DashboardMeterId == meterId 
                                                                                            && dme.OrganisationId == organisationId).First();
                dashboardMeterExposureToRemove.DashboardMeterId = meterId;
                dashboardMeterExposureToRemove.OrganisationId = organisationId;

                if (dashboardMeterExposureToRemove != null)
                {
                    atlasDB.DashboardMeterExposures.Remove(dashboardMeterExposureToRemove);
                }
            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }


    }
}