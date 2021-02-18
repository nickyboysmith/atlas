using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{  
    [AllowCrossDomainAccess]
    public class UserPreferenceController : AtlasBaseController
    {
        // Get api/userpreference/5
        public List<AlignmentPosition> Get(int Id)
        {
            var alignmentPreference =
                (
                    from userPreferences in atlasDB.UserPreferences
                    where userPreferences.UserId == Id
                    select new AlignmentPosition
                    {
                        AlignPreference = userPreferences.AlignPreference
                    }
                ).ToList();

            return  alignmentPreference;

        }

        // POST api/userpreference
        public string Post([FromBody] FormDataCollection formBody)
        {


            var status = "";
            var userId = 0;
            if (int.TryParse(formBody["userId"], out userId))
            {
                // It was assigned.
            }


            try
            {
                UserPreferences userPreference = new UserPreferences();

                // check the id if it exists then update
                // if it doesnt then create a new record
                var checkPreferenceExists = atlasDB.UserPreferences.Any(userPreferences => userPreferences.UserId == userId);

                /**
                 * If the ID doesnt exist in the table
                 */
                if (checkPreferenceExists)
                {
                    var theUserPreference = atlasDB.UserPreferences.Where(userPref => userPref.UserId == userId).FirstOrDefault();
                    userPreference.Id = theUserPreference.Id;
                    userPreference.AlignPreference = formBody["preference"];
                    
                    atlasDB.Entry(theUserPreference).CurrentValues.SetValues(userPreference);

                }


                /**
                 * If the ID doesnt exist in the table
                 */
                if (!checkPreferenceExists)
                {
                    userPreference.UserId = userId;
                    userPreference.AlignPreference = formBody["preference"];
                    atlasDB.UserPreferences.Add(userPreference);
                }

                atlasDB.SaveChanges();
                status = "Saved";


            } catch (DbEntityValidationException ex) {
                status = "Not saved";
            }



            return status;
        }

        public class AlignmentPosition
        {
            public string AlignPreference { get; set; }
        }
    }
}
