using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Scheduler.WebService.Classes.SMS
{
    public static class SMSTools
    {
        public static string FormatToUKNumber(string PhoneNumber)
        {
            var removedZero = PhoneNumber.Substring(1);
            return "+44" + removedZero;
        }
    }
}
