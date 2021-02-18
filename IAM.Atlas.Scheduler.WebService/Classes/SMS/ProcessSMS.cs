using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using System.Text.RegularExpressions;

namespace IAM.Atlas.Scheduler.WebService.Classes.SMS
{
    class ProcessSMS
    {

        public object Start(string ProviderName, string PhoneNumber, object ProviderCredentials, string MethodName, string MessageContent)
        {
            var PaymentProviderClassName = PrepareProviderName(ProviderName);
            return CallProviderClass(PaymentProviderClassName, PhoneNumber, ProviderCredentials, MethodName, MessageContent);
        }

        private string PrepareProviderName(string ProviderName)
        {
            var pascalCase = ToPascalCase(ProviderName);
            return Regex.Replace(pascalCase, @"\s", "");
        }

        public object CallProviderClass(string Provider, string PhoneNumber, object ProviderCredentials, string MethodName, string MessageContent)
        {
            // Get a type from the string 
            Type type = Type.GetType("IAM.Atlas.Scheduler.WebService.Classes.SMS.Providers." + Provider);

            // Create an instance of that type
            Object obj = Activator.CreateInstance(type);

            // Retrieve the method you are looking for
            MethodInfo methodToCall = type.GetMethod(MethodName);

            // the real one to use
            try
            {
                return methodToCall.Invoke(obj, new object[] { PhoneNumber, ProviderCredentials, MessageContent });

            }
            catch (Exception ex)
            {
                return "There is an error";
            }

        }

        // @TODO: Refactor because already in webapi string tools
        // Convert the string to Pascal case.
        public static string ToPascalCase(string theString)
        {
            // If there are 0 or 1 characters, just return the string.
            if (theString == null) return theString;
            if (theString.Length < 2) return theString.ToUpper();

            // Split the string into words.
            string[] words = theString.Split(
                new char[] { },
                StringSplitOptions.RemoveEmptyEntries);

            // Combine the words.
            string result = "";
            foreach (string word in words)
            {
                result +=
                    word.Substring(0, 1).ToUpper() +
                    word.Substring(1);
            }

            return result;
        }

    }
}
