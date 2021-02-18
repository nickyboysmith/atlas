using IAM.Atlas.Data;
//using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using IAM.Atlas.WebAPI.Models.UserSearchHistoryJSON;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Script.Serialization;

namespace IAM.Atlas.WebAPI.Controllers
{  
    [AllowCrossDomainAccess]
    public class UserSearchHistoryController : AtlasBaseController
    {
        // Get api/usersearchhistory
        public object Get(string searchInterfaceTitle, int userId)
        {
            var searchResults =
                (
                    from user in atlasDB.SearchHistoryUser
                    join searchInterface in atlasDB.SearchHistoryInterface on user.SearchHistoryInterfaceId equals searchInterface.Id
                    join historyItem in atlasDB.SearchHistoryItem on user.Id equals historyItem.SearchHistoryUserId
                    where user.UserId == userId && searchInterface.Title == searchInterfaceTitle
                    group new { historyItem.Name, historyItem.Value, historyItem.SearchHistoryUserId, user.CreationDate } by historyItem.SearchHistoryUserId into g
                    select new { SearchId = g.Key, Results = g.ToList() }
                ).ToList().OrderByDescending(s => s.SearchId);

            return searchResults;
        }

        // POST api/usersearchhistory
        public string Post([FromBody] FormDataCollection formBody)
        {
            var status = "";

            try
            {
                SearchHistoryInterface searchHistoryInterface = new SearchHistoryInterface();
                searchHistoryInterface.Name = formBody["screenId"];
                searchHistoryInterface.Title = formBody["screenId"];

                SearchHistoryUser searchHistoryUser = new SearchHistoryUser();
                searchHistoryUser.UserId = Int32.Parse(formBody["userId"]);
                searchHistoryUser.CreationDate = DateTime.Now;

                foreach (var searchParams in formBody)
                {
                    SearchHistoryItem searchHistoryItem = new SearchHistoryItem();
                    if (searchParams.Key == "userId")
                    {
                        // Do nothing
                    }
                    else if (searchParams.Key == "screenId")
                    {
                        // Do nothing
                    }
                    else
                    {
                        /**
                          * Add all search properties
                          * Excluding userId & screenId 
                          */
                        searchHistoryItem.Name = searchParams.Key;
                        searchHistoryItem.Value = searchParams.Value;
                        atlasDB.SearchHistoryItem.Add(searchHistoryItem);
                    }
                }


                searchHistoryUser.SearchHistoryInterface = searchHistoryInterface;
                searchHistoryInterface.SearchHistoryUser.Add(searchHistoryUser);

                atlasDB.SearchHistoryInterface.Add(searchHistoryInterface);
                atlasDB.SearchHistoryUser.Add(searchHistoryUser);

                atlasDB.SaveChanges();
                status = "complete";

            }
            catch
            {
                status = "failed";
            }
            return status;
        }
    }
}
