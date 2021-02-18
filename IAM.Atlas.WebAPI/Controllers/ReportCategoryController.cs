using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ReportCategoryController : AtlasBaseController
    {


        // GET api/reportCategory/5
        public object Get(int Id)
        {
            var searchResults =
            (
                from organisationUser in atlasDB.OrganisationUsers
                join organisation in atlasDB.Organisations on organisationUser.OrganisationId equals organisation.Id
                where organisationUser.UserId == Id
                select new { organisation.Id, organisation.Name }
            ).ToList();

            return searchResults;
        }

        // GET api/reportCategory/related/5
        [Route("api/reportCategory/related/{OrganisationId}")]
        [HttpGet]
        public object related(int OrganisationId)
        {
            var organisationreportCategories =
            (
                from organisationReportCategory in atlasDB.OrganisationReportCategories
                join reportCategory in atlasDB.ReportCategories
                on organisationReportCategory.ReportCategoryId equals reportCategory.Id
                where organisationReportCategory.OrganisationId == OrganisationId
                select new { reportCategory.Id, reportCategory.Title, reportCategory.Disabled }
            ).ToList();

            return organisationreportCategories;
        }

        // GET api/reportCategory
        public string Post([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var ReportCategoryId = StringTools.GetInt("Id", ref formData);
            var Title = StringTools.GetString("Title", ref formData);
            var Disabled = StringTools.GetBool("Disabled", ref formData);

            string status = "";
            
            // Add the Report Category
            if (ReportCategoryId == 0)
            {
                try
                {
            
                    ReportCategory reportCategory = new ReportCategory();

                    reportCategory.Title = Title;
                    reportCategory.Disabled = Disabled;

                    atlasDB.ReportCategories.Add(reportCategory);

                    OrganisationReportCategory organisationReportCategory = new OrganisationReportCategory();

                    organisationReportCategory.OrganisationId = OrganisationId;
                    organisationReportCategory.ReportCategoryId = reportCategory.Id;

                    atlasDB.OrganisationReportCategories.Add(organisationReportCategory);

                    atlasDB.SaveChanges();

                    status = "Report Category Saved Successfully";

                }
                catch (DbEntityValidationException ex)
                {
                    status = "There was an error Adding your Report Category. Please retry.";
                }
            }
            // Update the Report Category
            else if (ReportCategoryId > 0)
            {
                try
                {

                    var editReportCategory = atlasDB.ReportCategories.Where(rc => rc.Id == ReportCategoryId).FirstOrDefault();

                    if (editReportCategory != null)
                    {

                        atlasDB.ReportCategories.Attach(editReportCategory);
                        var entry = atlasDB.Entry(editReportCategory);

                        editReportCategory.Title = Title;
                        atlasDB.Entry(editReportCategory).Property("Title").IsModified = true;
                        editReportCategory.Disabled = Disabled;
                        atlasDB.Entry(editReportCategory).Property("Disabled").IsModified = true;


                        atlasDB.SaveChanges();

                        status = "Report Category Saved Successfully";

                    }
                }
                catch (DbEntityValidationException ex)
                {
                    status = "There was an error Updating your Report Category. Please retry.";
                }
            }

            return status;

        }

    }
}