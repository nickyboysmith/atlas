using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.Scheduler.WebService.Models.Email;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email
{
    interface EmailProviderInterface
    {

        EmailResult Send(string Endpoint, object ProviderObject, int EmailId); 

    }
}
