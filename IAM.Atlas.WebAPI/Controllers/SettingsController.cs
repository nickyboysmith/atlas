using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.Web.Script.Serialization;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SettingsController : AtlasBaseController
    {
        // GET 
        public string Get()
        {
            var settingValue = "";
            string setting = "Version";
            try
            {
                settingValue = ConfigurationManager.AppSettings["atlas:" + setting];
            }
            catch
            {

            }
            return settingValue;
        }

        public string Get(string setting)
        {
            var settingValue = "";
            try
            {
                settingValue = ConfigurationManager.AppSettings["atlas:" + setting];
            }
            catch
            {

            }
            return settingValue;
        }

        // GETALL api/getall 
        [Route("api/Settings/GetAll")]
        public string GetAll()
        {
            var settings = new 
            {
                Version = ConfigurationManager.AppSettings["atlas:Version"]
                , VersionRelease = ConfigurationManager.AppSettings["atlas:VersionRelease"]
            };
            var javaScriptSerializer = new JavaScriptSerializer();
            return javaScriptSerializer.Serialize(settings);
        }

    }
}
