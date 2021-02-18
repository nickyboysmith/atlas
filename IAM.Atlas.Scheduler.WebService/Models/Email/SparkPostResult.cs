using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Scheduler.WebService.Models.Email
{
    public class SparkPostResult
    {
        public int total_accepted_recipients { get; set; }
        public int rejected { get; set; }
    }
}
