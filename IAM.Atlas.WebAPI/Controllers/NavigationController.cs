using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{


    public class NavigationController : AtlasBaseController
    {

        [Route("api/Navigation/{UserId}")]
        [HttpGet]
        public UserMenuOptionJSON Get(int UserId)
        {

            var systemAdmin = new SystemAdminController();
            var isSystemAdmin = systemAdmin.Get(UserId);
            var menuItems = new UserMenuOptionJSON();

            if (isSystemAdmin == false) {

                try {

                    var menuOption = atlasDB.UserMenuOption
                        .Where(
                            option => option.UserId == UserId
                        );

                    if (menuOption.Count() == 0) {
                        menuItems.AccessToClients = false;
                        menuItems.AccessToCourses = false;
                        menuItems.AccessToReports = false;
                    } else {

                        menuItems.AccessToClients = (bool)menuOption.FirstOrDefault().AccessToClients;
                        menuItems.AccessToCourses = (bool)menuOption.FirstOrDefault().AccessToCourses;
                        menuItems.AccessToReports = (bool)menuOption.FirstOrDefault().AccessToReports;

                    }

                } catch (DbEntityValidationException ex) {
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "We're having issues getting your main menu items. Please retry!");
                } catch (Exception ex) {
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "There has been an issue retrieving your main menu items. Please retry!");
                }

            } else if (isSystemAdmin == true) {
                menuItems.AccessToClients = true;
                menuItems.AccessToCourses = true;
                menuItems.AccessToReports = true;
            } else {
                menuItems.AccessToClients = false;
                menuItems.AccessToCourses = false;
                menuItems.AccessToReports = false;
            }

            return menuItems;

        }

        [AuthorizationRequired]
        [Route("api/Navigation/UserReportList/{UserId}/{OrganisationId}")]
        [HttpGet]
        public object GetUserReportList(int UserId, int OrganisationId)
        {
            var reportsList = atlasDBViews.vwReportsByUsers.Where(r => r.OrganisationId == OrganisationId && r.UserId == UserId);

            return reportsList;
        }

        [AuthorizationRequired]
        [Route("api/Navigation/Report/{UserId}/{OrganisationId}")]
        [HttpGet]
        public object GetReportNavigationItems(int UserId, int OrganisationId)
        {
            var reportsList = atlasDB.Reports
                    .Include("ReportOwners")
                    .Include("OrganisationReports")
                    .Include("ReportsReportCategories")
                    .Include("ReportsReportCategories.ReportCategory")
                    .Where(
                        reportUser =>
                        (
                            reportUser.ReportOwners.Any(
                                owner => owner.UserId == UserId // Check to see if user is report owner
                            )
                            ||
                            reportUser.OrganisationReports.Any(
                                organisation => organisation.OrganisationId == OrganisationId // Check to see if report belongs to org
                            )
                            ||
                            reportUser.UserReports.Any(
                                userReport => userReport.UserId == UserId // Check to see if user has special access to report
                            )
                        )
                    )
                    .Select(
                        report => new
                        {
                            ReportId = report.Id,
                            report.Title,
                            report.Description,
                            ReportCategory = report.ReportsReportCategories.Select(
                                reportCategory => new {
                                    reportCategory.ReportCategoryId,
                                    reportCategory.ReportCategory.Title
                                }
                            )
                        }
                    )
                    .ToList();

            return reportsList;
        }

        [AuthorizationRequired]
        [Route("api/Navigation/showPaymentReconciliation/{OrganisationId}")]
        [HttpGet]
        public bool ShowPaymentReconciliation(int organisationId)
        {
            var showPaymentReconciliation = atlasDB.OrganisationSystemConfigurations
                                                    .Where(osc => osc.OrganisationId == organisationId)
                                                    .FirstOrDefault()
                                                    .ShowPaymentReconciliation;

            return showPaymentReconciliation;
        }

        // POST api/<controller>
        public void Post([FromBody]string value)
        {
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }
    }
}