using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using IAM.Atlas.WebAPI.Controllers;

namespace IAM.Atlas.WebAPI.Classes
{    public static class GlobalVariables
    {
        //You Need a Very Special Reason for this.
        public static DateTime LastRefreshOfProcessMonitor { get; set; }
        public static bool LastCheckedValueEbnabledProcessMonitor { get; set; }
        //public static bool SaveProcessesForMonitoring
        //{
        //    get
        //    {
        //        //Refresh After 30 Minutes have passed the Status of the Process Monitor. Stops too many time the DB is accessed.
        //        if (LastRefreshOfProcessMonitor < DateTime.Now.AddMinutes(-30))
        //        {
        //            LastRefreshOfProcessMonitor = DateTime.Now;
        //            LastCheckedValueEbnabledProcessMonitor = (new SystemControlController()).ProcessMonitorEnabled();
        //        }
        //        return LastCheckedValueEbnabledProcessMonitor;
        //    }
        //}
    }
}