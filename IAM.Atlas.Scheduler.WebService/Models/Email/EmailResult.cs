using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Scheduler.WebService.Models.Email
{
    public class EmailResult
    {
        public bool HasEmailSucceded { get; set; }
        public int EmailId { get; set; }
        public string Message { get; set; }
    }
}
