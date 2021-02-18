using System.Web;
using System.Web.Mvc;

namespace IAM.Atlas.Scheduler.WebService
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}
