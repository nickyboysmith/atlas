using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using System.Text.RegularExpressions;
using IAM.Atlas.Scheduler.WebService.Models.Email;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email
{
    class ProcessEmail
    {
        public object Start(string ProviderName, string Endpoint, object ProviderObject, int EmailId, string MethodName)
        {
            var PaymentProviderClassName = PrepareProviderName(ProviderName);
            return CallProviderClass(PaymentProviderClassName, Endpoint, ProviderObject, EmailId, MethodName);
        }

        private string PrepareProviderName(string ProviderName)
        {
            var pascalCase = ToPascalCase(ProviderName);
            return Regex.Replace(pascalCase, @"\s", "");
        }

        public object CallProviderClass(string Provider, string Endpoint, object ProviderObject, int EmailId, string MethodName)
        {
            // Get a type from the string 
            Type type = Type.GetType("IAM.Atlas.Scheduler.WebService.Classes.Email.Providers." + Provider);

            // Create an instance of that type
            Object obj = Activator.CreateInstance(type);

            // Retrieve the method you are looking for
            MethodInfo methodToCall = type.GetMethod(MethodName);

            // the real one to use
            //try
            //{
            return methodToCall.Invoke(obj, new object[] { Endpoint, ProviderObject, EmailId });

            //}
            //catch (Exception ex)
            //{
            //    return "Error: " + ex.Message + "(" + ex.Source + ")";
            //}

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
