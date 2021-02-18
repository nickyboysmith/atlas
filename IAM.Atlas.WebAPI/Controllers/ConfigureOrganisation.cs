using IAM.Atlas.Data;
using System;
using System.Drawing;
using System.IO;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Web.Http;
using System.Xml.Linq;


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ConfigureOrganisationController : AtlasBaseController
    {


        // GET api/ConfigureOrganisation/1
        public OrganisationDisplay Get(int id) 
        {
            /**
             * Need to do some error checking here today
             */ 
            return atlasDB.OrganisationDisplay.First(o => o.OrganisationId == id);
        }

        // POST api/ConfigureOrganisation
        public string Post([FromBody] FormDataCollection formBody)
        {
            string status = "";

            if (formBody["organisationId"] == "*")
            {
                return "Please select an organisation and retry.";
            }


            var theOrganisationId = Int32.Parse(formBody["organisationId"]);
            var imageFilePath = ConvertImageString(formBody["companyImage"], theOrganisationId);

            try
            {
                OrganisationDisplay organisationDisplay = new OrganisationDisplay();

                var checkOrganisationExists = atlasDB.OrganisationDisplay.Where(o => o.OrganisationId == theOrganisationId).FirstOrDefault();



                organisationDisplay.OrganisationId = theOrganisationId;
                organisationDisplay.Name = formBody["organisationName"];
                organisationDisplay.DisplayName = formBody["companyName"];
                organisationDisplay.HasLogo = Boolean.Parse(formBody["showLogo"]);
                organisationDisplay.ShowLogo = Boolean.Parse(formBody["showLogo"]);
                organisationDisplay.LogoAlignment = formBody["alignLogo"];
                organisationDisplay.DisplayNameAlignment = formBody["alignDisplayName"];
                organisationDisplay.ShowDisplayName = Boolean.Parse(formBody["showDisplayName"]);
                organisationDisplay.BorderColour = formBody["borderColor"];
                organisationDisplay.HasBorder = Boolean.Parse(formBody["showBorder"]);
                organisationDisplay.BackgroundColour = formBody["backgroundColor"];
                organisationDisplay.FontColour = formBody["fontColor"];
                organisationDisplay.SystemFontId = Int32.Parse(formBody["fontName"]);
                organisationDisplay.ChangedByUserId = Int32.Parse(formBody["userID"]);
                organisationDisplay.DateChanged = DateTime.Now;
                organisationDisplay.ImageFilePath = imageFilePath;


                if (checkOrganisationExists == null)
                {
                    atlasDB.OrganisationDisplay.Add(organisationDisplay);
                }


                if (checkOrganisationExists != null) 
                {
                    organisationDisplay.Id = checkOrganisationExists.Id;
                    atlasDB.Entry(checkOrganisationExists).CurrentValues.SetValues(organisationDisplay);
                }


                atlasDB.SaveChanges();
                status = "Your configuration options have been saved successfully.";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error saving your options. Please retry.";
            }


            return status;

        }

        /**
         * Convert the a Base64 String to an Image
         * @return string image path
         */ 
        public string ConvertImageString(string imageFile, int organisationId) 
        {
            try
            {
                var endPath = "Images\\" + organisationId + ".png";
                var filePath = System.AppDomain.CurrentDomain.BaseDirectory + endPath;

                byte[] imageBytes = Convert.FromBase64String(imageFile);
                MemoryStream ms = new MemoryStream(imageBytes, 0, imageBytes.Length);

                ms.Write(imageBytes, 0, imageBytes.Length);
                Image image = Image.FromStream(ms, true);

                image.Save(filePath);

                return endPath;
            }
            catch
            {
                return null;
            }
            

        } 
        

    }
}