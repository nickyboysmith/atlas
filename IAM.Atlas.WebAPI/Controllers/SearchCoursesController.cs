using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{

    [AllowCrossDomainAccess]
    public class SearchCoursesController : AtlasBaseController
    {

        // 
        public object getCourseSearchResults([FromBody] FormDataCollection formParams)
        {

            DateTime today = DateTime.Now;
            DateTime startOfDay = today.Date;

            var formData = formParams;

            var organisationId = 0;
            var venueId = 0;
            var courseTypeId = 0;
            var maxRows = 200; // default

            var courseReference = formParams["searchParams[reference]"];
            var dateCheck = formParams["searchParams[searchDates]"];
            var dayAmount = formParams["searchParams[dayAmount]"];
            var updatedDate = UpdateDate(startOfDay, dateCheck, dayAmount);
            var newStartDate = stringToDate(formParams["searchParams[startDate]"]);
            var newEndDate = stringToDate(formParams["searchParams[endDate]"]);
            var includeCancelledCourses = StringTools.GetBool("searchParams[cancelled]", ref formData);
            var twoDaysFromNow = DateTime.Now.AddDays(2.0).Date;
            var threeYearsFromNow = DateTime.Now.AddYears(3).Date;
            var futureCoursesOnly = StringTools.GetBool("searchParams[futureCoursesOnly]", ref formData);

            if (int.TryParse(formParams["organisationId"], out organisationId))
            {
                // It was assigned.
            }

            if (int.TryParse(formParams["searchParams[venue]"], out venueId))
            {
                // It was assigned.
            }

            if (int.TryParse(formParams["searchParams[type]"], out courseTypeId))
            {
                // It was assigned.
            }
            if (int.TryParse(formParams["searchParams[maxRows]"], out maxRows))
            {
                // It was assigned.
            }

            var courseSearchResults = new List<vwCourseDetail>();

            if (futureCoursesOnly == true)
            {
                //Added in a ending start date of three years from today, without this, it times out.
                courseSearchResults = atlasDBViews.vwCourseDetails
                     .Where(
                      x =>
                      (x.OrganisationId == organisationId) &&
                      ((string.IsNullOrEmpty(courseReference)) || x.CourseReference.Contains(courseReference)) &&
                      (x.StartDate >= twoDaysFromNow && x.StartDate <= threeYearsFromNow) &&
                      ((courseTypeId == 0) || x.CourseTypeId == courseTypeId) &&
                      (includeCancelledCourses == false ? x.CourseCancelled == false : true)
                      )
                      .OrderBy(x => x.StartDate)
                      .Take(maxRows)
                      .ToList();
            }
            else
            {
                courseSearchResults = atlasDBViews.vwCourseDetails
                    .Where(
                    x =>
                    (organisationId < 0) || (x.OrganisationId == organisationId) &&
                    ((string.IsNullOrEmpty(courseReference)) || x.CourseReference.Contains(courseReference)) &&
                    ((dateCheck != "next") || x.StartDate >= startOfDay && x.StartDate <= updatedDate) &&
                    ((dateCheck != "previous") || x.StartDate >= updatedDate && x.StartDate <= startOfDay) &&
                    ((dateCheck != "between") || x.StartDate >= newStartDate && x.StartDate <= newEndDate) &&
                    ((courseTypeId == 0) || x.CourseTypeId == courseTypeId) &&
                    (includeCancelledCourses == false ? x.CourseCancelled == false : true)
                    )
                    .OrderByDescending(x => x.StartDate)
                    .Take(maxRows)
                    .ToList();
            }

            var courseResultsQuery = courseSearchResults
                      .Select(x => new
                      {
                          Id = x.CourseId,
                          reference = x.CourseReference,
                          available = x.CourseAvailable,
                          cancelled = x.CourseCancelled == true ? "cancelled" : "non-cancelled",
                          date = x.StartDate,
                          venue = x.VenueName,
                          trainers = x.TrainersRequired,
                          remaining = x.PlacesRemaining,
                          categoryId = x.CourseTypeCategoryId,
                          courseType = x.CourseType,
                          courseTypeCategory = x.CourseTypeCategory
                      }
                      ).ToList();

            return courseResultsQuery;

        }

        // Get api/course
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/SearchCourses/GetPreviousSearches/{courseId}/{userId}")]
        public object GetPreviousSearches(string courseId, int userId)
        {
            var searchResults =
                (
                    from a in atlasDB.SearchHistoryUser
                    join b in atlasDB.SearchHistoryInterface on a.SearchHistoryInterfaceId equals b.Id
                    join c in atlasDB.SearchHistoryItem on a.Id equals c.SearchHistoryUserId
                    where a.UserId == userId && b.Title == courseId
                    group new { c.Name, c.Value, c.SearchHistoryUserId, a.CreationDate } by c.SearchHistoryUserId into g
                    select new { SearchId = g.Key, Results = g.ToList() }
                ).ToList();


            return searchResults;
        }

        // POST api/searchcourses
        [HttpPost]
        [AuthorizationRequired]
        [Route("api/SearchCourses")]
        public object Post([FromBody] FormDataCollection formBody)
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
                    else if (searchParams.Key == "organisationId")
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

            /**
             * After the search has been inserted
             * Then query the DB
             */
            // ;

            if (status == "complete")
            {
                return getCourseSearchResults(formBody);
            }

            else if (status == "failed")
            {
                TheError error = new TheError();
                error.Message = "Failure";
                return error;
            }
            else
            {
                TheError error = new TheError();
                error.Message = "Unknown";
                return error;
            }
            
        }


        // POST api/searchcourses
        //[HttpGet]
        //[AuthorizationRequired]
        //[Route("api/SearchCourses/GetPreviousSearches")]
        //public object Post([FromBody] FormDataCollection formBody)
        //{

        //    var status = "";


        //    try
        //    {
        //        SearchHistoryInterface searchHistoryInterface = new SearchHistoryInterface();
        //        searchHistoryInterface.Name = formBody["screenId"];
        //        searchHistoryInterface.Title = formBody["screenId"];

        //        SearchHistoryUser searchHistoryUser = new SearchHistoryUser();
        //        searchHistoryUser.UserId = Int32.Parse(formBody["userId"]);
        //        searchHistoryUser.CreationDate = DateTime.Now;

        //        foreach (var searchParams in formBody)
        //        {
        //            SearchHistoryItem searchHistoryItem = new SearchHistoryItem();
        //            if (searchParams.Key == "userId")
        //            {
        //                // Do nothing
        //            }
        //            else if (searchParams.Key == "screenId")
        //            {
        //                // Do nothing
        //            }
        //            else if (searchParams.Key == "organisationId")
        //            {
        //                // Do nothing
        //            }
        //            else
        //            {
        //                /**
        //                  * Add all search properties
        //                  * Excluding userId & screenId 
        //                  */
        //                searchHistoryItem.Name = searchParams.Key;
        //                searchHistoryItem.Value = searchParams.Value;
        //                atlasDB.SearchHistoryItem.Add(searchHistoryItem);
        //            }
        //        }


        //        searchHistoryUser.SearchHistoryInterface = searchHistoryInterface;
        //        searchHistoryInterface.SearchHistoryUser.Add(searchHistoryUser);

        //        atlasDB.SearchHistoryInterface.Add(searchHistoryInterface);
        //        atlasDB.SearchHistoryUser.Add(searchHistoryUser);

        //        atlasDB.SaveChanges();
        //        status = "complete";

        //    }
        //    catch
        //    {
        //        status = "failed";
        //    }

        //    /**
        //     * After the search has been inserted
        //     * Then query the DB
        //     */
        //    // ;

        //    if (status == "complete")
        //    {
        //        return getCourseSearchResults(formBody);
        //    }

        //    else if (status == "failed")
        //    {
        //        TheError error = new TheError();
        //        error.Message = "Failure";
        //        return error;
        //    }
        //    else
        //    {
        //        TheError error = new TheError();
        //        error.Message = "Unknown";
        //        return error;
        //    }

        //}



        public class TheError
        {
            public string Message { get; set; }
        }


        protected DateTime UpdateDate(DateTime theDate, string action, string dayAmount)
        {

            int amount;

            // convert The day amount
            if (int.TryParse(dayAmount, out amount))
            {
                // It was assigned.
            }

            if (action == "previous")
            {
                amount = -amount;
            }

            return theDate.AddDays(amount);

        }

        protected DateTime stringToDate(string theDate)
        {
            if (string.IsNullOrEmpty(theDate))
            {
                return DateTime.Now;
            }

            DateTime newDate = DateTime.Parse(theDate);
            return newDate.Date;
        }





    }
}