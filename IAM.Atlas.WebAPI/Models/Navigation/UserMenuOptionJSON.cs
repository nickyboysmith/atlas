using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class UserMenuOptionJSON
    {
        public bool AccessToClients { get; set; }
        public bool AccessToCourses { get; set; }
        public bool AccessToReports { get; set; }
    }
}
