using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;

namespace IAM.Atlas.WebAPI.Controllers
{
    
    public class SystemFontController : AtlasBaseController
    {
        [AllowCrossDomainAccess]
        public List<SystemFont> Get()
        {
            return atlasDB.SystemFont.ToList();
        }
    }
}