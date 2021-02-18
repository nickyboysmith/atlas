using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class PublicHolidayController : AtlasBaseController
    {

        public List<PublicHolidayJSON> Get(int Id)
        {
           
            var countryCode = "ALL";

            DateTime pastDate = DateTime.Now.AddMonths(-6);
            DateTime futureDate = DateTime.Now.AddMonths(18);

            List<PublicHolidayJSON> publicHolidaylist = new List<PublicHolidayJSON>();

            switch (Id)
            {
                case 1: countryCode = "WAL"; break;
                case 2: countryCode = "ENG"; break;
                case 3: countryCode = "SCT"; break;
                case 4: countryCode = "NIR"; break;
            }

            if (countryCode == "ALL")
            {
                var publicHoliday = (
                    from ph in atlasDB.PublicHoliday
                    where (ph.Date > pastDate && ph.Date < futureDate)
                    orderby ph.Date descending
                    select new PublicHolidayJSON { Id = ph.Id, Title = ph.Title, CountryCode = ph.Country_Code, Date = ph.Date }


                ).ToList();

                publicHolidaylist = publicHoliday;

            }
            else
            {
                var publicHoliday = (
                    from ph in atlasDB.PublicHoliday
                    where (ph.Country_Code == countryCode) && (ph.Date > pastDate && ph.Date < futureDate)
                    orderby ph.Date descending
                    select new PublicHolidayJSON { Id = ph.Id, Title = ph.Title, CountryCode = ph.Country_Code, Date = ph.Date }
                ).ToList();

                publicHolidaylist = publicHoliday;
            }

            return publicHolidaylist ;
        }

        public string Post([FromBody] FormDataCollection formBody)
          
        {
            string status;
           

            var formTitle = formBody.Get("Title");
            var formDate = formBody.Get("Date");

            DateTime publicHolidayDate = DateTime.Parse(formDate);

            var formCountries = (from fb in formBody
                           where fb.Key.Contains("Country")
                           select new { fb.Key, fb.Value });

            foreach (var country in formCountries)
            {
                var countryCode = "";

                switch (country.Value)
                {
                    case "1": countryCode = "WAL"; break;
                    case "2": countryCode = "ENG"; break;
                    case "3": countryCode = "SCT"; break;
                    case "4": countryCode = "NIR"; break;
                }
                
                PublicHoliday publicHolidayToAdd = new PublicHoliday();
                publicHolidayToAdd.Title = formTitle;
                publicHolidayToAdd.Date = publicHolidayDate;
                publicHolidayToAdd.Country_Code = countryCode;

                atlasDB.PublicHoliday.Add(publicHolidayToAdd);
                
            }

            atlasDB.SaveChanges();
            
            status = "successful";

            return status;
        }

        public string Post(int Id)
        {
            string status = string.Empty;

            PublicHoliday publicHolidayToRemove = new PublicHoliday();
            publicHolidayToRemove = atlasDB.PublicHoliday.Where(b => b.Id == Id).First();

            if (publicHolidayToRemove != null)
            {
                //DateTime publicHolidayDate = (DateTime).TryParse(publicHolidayToRemove.Date);
                DateTime publicHolidayDate = (DateTime)publicHolidayToRemove.Date;

                if (publicHolidayDate.Date > DateTime.Today)
                { 
                    atlasDB.PublicHoliday.Remove(publicHolidayToRemove);

                    atlasDB.SaveChanges();

                    status = "Successful";
                }
                else
                {
                    status = "Cannot remove dates older than today";
                }
            }
            else
            {
                status = "Does not exist";
            }

            return status;

        }
    }
}
