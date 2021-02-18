using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class QuickSearchController : AtlasBaseController
    {


        // GET api/quickSearch/client/searchText/5
        [Route("api/quicksearch/client/{SearchText}/{OrganisationId}")]
        [HttpGet]
        public List<ClientQuickSearch> ClientQuickSearch(string SearchText, int OrganisationId)
        {

            var updatedSearchText = SearchText.ToString().Replace("%20", " ");
            var searchResults = atlasDB.ClientQuickSearches
                                    .Where(
                                        clientQuickSearch =>
                                            clientQuickSearch.OrganisationId == OrganisationId
                                            && clientQuickSearch.SearchContent.Contains(updatedSearchText)
                                    )
                                    .GroupBy(cqs => cqs.ClientId)
                                    .Select(gb => gb.FirstOrDefault())
                                    .Take(15)
                                    .ToList();
            return searchResults;              
        }


        // GET api/quickSearch/client/searchText/5
        [Route("api/quicksearch/systemfeature/{SearchText}/{OrganisationId}")]
        [HttpGet]
        public List<SystemInformation> SystemFeatureQuickSearch(string SearchText, int OrganisationId)
        {

            var updatedSearchText = SearchText.ToString().Replace("%20", " ");
            var searchResults = atlasDB.SystemInformations
                                    .Where(
                                        systemFeatureQuickSearch =>
                                            (
                                                systemFeatureQuickSearch.OrganisationId == null
                                                ||
                                                systemFeatureQuickSearch.OrganisationId == OrganisationId
                                            )
                                            && systemFeatureQuickSearch.SearchContent.Contains(updatedSearchText)
                                    )
                                    .Take(15)
                                    .ToList();
            return searchResults;
        }


        // GET api/quickSearch/client/searchText/5
        [Route("api/quicksearch/course/{SearchText}/{OrganisationId}/{ShowRecent}")]
        [HttpGet]
        public List<CourseQuickSearch> CourseQuickSearch(string SearchText, int OrganisationId, int ShowRecent)
        {
            var today = DateTime.Now;
            var startOfDay = today.Date;
            var recentDate = startOfDay.AddDays(-14);
            var courseQuickSearches = atlasDB.CourseQuickSearches
                                                .Where(
                                                    clientQuickSearch =>
                                                        clientQuickSearch.OrganisationId == OrganisationId &&
                                                        ((ShowRecent == 0) || clientQuickSearch.Date >= recentDate) &&
                                                        clientQuickSearch.SearchContent.Contains(SearchText)
                                                )
                                                .GroupBy(cqs => cqs.CourseId)
                                                .Select(gb => gb.FirstOrDefault())
                                                .Take(15)
                                                .OrderBy(clientQuickSearch => clientQuickSearch.Date)
                                                .ToList();
            return courseQuickSearches;
        }

    }
}