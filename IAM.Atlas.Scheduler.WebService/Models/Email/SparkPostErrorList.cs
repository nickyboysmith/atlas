using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Scheduler.WebService.Models.Email
{
    public class SparkPostErrorList
    {
        public string message { get; set; }
        public string description { get; set; }

        public string code { get; set; }
    }
}
