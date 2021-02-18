using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Scheduler.WebService.Models.Email
{
    public class SparkPostError
    {
        public List<SparkPostErrorList> errors { get; set; }

        public SparkPostResult results { get; set; }

    }
}
