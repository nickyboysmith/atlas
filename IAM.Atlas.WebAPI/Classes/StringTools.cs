using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Web;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Classes
{
    public static class StringTools
    {
        /// <summary>
        /// Extracts a boolean value from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>True/False, False for Null</returns>
        public static bool GetBool(string formDataArgument, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);
            bool returnValue = false;
            return variable != null ? bool.TryParse(variable, out returnValue) ? returnValue : false : false;
        }

        public static bool GetBoolOrFail(string formDataArgument, ref FormDataCollection Data, string errorMessage)
        {
            var variable = Data.Get(formDataArgument);
            bool returnValue = false;

            if (bool.TryParse(variable, out returnValue))
            {
                return returnValue;
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }

        }

        /// <summary>
        /// Extracts a nullable boolean value from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>True/False, False for Null</returns>
        public static bool? GetNullableBool(string formDataArgument, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);
            bool returnValue = false;
            if (variable == null)
            {
                return null;
            }
            else
            {
                bool.TryParse(variable, out returnValue);
                return returnValue;
            }
        }

        /// <summary>
        /// Extracts a string value from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>String value, empty string for Null</returns>
        public static string GetString(string formDataArgument, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);
            return variable != null ? variable : "";
        }

        public static string GetStringOrFail(string formDataArgument, ref FormDataCollection Data, string errorMessage)
        {
            var variable = Data.Get(formDataArgument);
            if (!String.IsNullOrEmpty(variable))
            {
                return variable;
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
            return variable != null ? variable : "";
        }

        // Without thje form data
        public static string GetStringOrFail(string inputValue, string errorMessage)
        {
            if (!String.IsNullOrEmpty(inputValue))
            {
                return inputValue;
            }
            else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
        }

        /// <summary>
        /// Extracts an integer value from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>Integer value, zero for Null</returns>
        public static int GetInt(string formDataArgument, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);
            int returnValue = 0;
            return variable != null ? int.TryParse(variable, out returnValue) ? returnValue : 0 : 0;
        }

        public static int? GetIntOrNull(string formDataArgument, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);

            if (string.IsNullOrEmpty(variable)) { return null; }

            int returnValue = 0;
            return variable != null ? int.TryParse(variable, out returnValue) ? returnValue : 0 : 0;
        }

        public static int GetInt(string intString)
        {
            int returnValue = -1;
            if(!int.TryParse(intString, out returnValue))
            {
                returnValue = -1;
            }
            return returnValue;
        }

        // With out the form data
        public static int GetIntOrFail(string intString, string errorMessage)
        {
            int returnValue = 0;

            if (int.TryParse(intString, out returnValue))
            {
                // It was assigned.
                return returnValue;
            }
            else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
        }


        /// <summary>
        /// Extracts an integer value from the FormDataCollection
        /// Throws an error if not an int
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>Integer value, zero for Null</returns>
        public static int GetIntOrFail(string formDataArgument, ref FormDataCollection Data, string errorMessage)
        {
            var variable = Data.Get(formDataArgument);
            int returnValue = 0;

            if (int.TryParse(variable, out returnValue))
            {
                // It was assigned.
                return returnValue;
            } else {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
        }

        /// <summary>
        /// Extracts an integer array from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>Integer array, zero for Null</returns>
        public static int[] GetIntArray(string formDataArgument, char delimiter, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);
            
            List<int> returnValue = new List<int>();
            if(variable == null)
            {
                return returnValue.ToArray();
            }
            else
            {
                var tempData = variable.Replace("[","").Replace("]", "").Split(delimiter);
                int parseOutput;
                foreach(var element in tempData)
                {
                    if(int.TryParse(element, out parseOutput))
                    {
                        returnValue.Add(parseOutput);
                    }
                }
                return returnValue.ToArray(); ;
            }
        }

        /// <summary>
        /// Extracts an decimal value from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>Integer value, zero for Null</returns>
        public static decimal GetDecimal(string formDataArgument, ref FormDataCollection Data)
        {
            var variable = Data.Get(formDataArgument);
            decimal returnValue = 0.0M;
            return variable != null ? decimal.TryParse(variable, out returnValue) ? returnValue : -1 : 0;
        }

        public static DateTime? GetDate(string theDate)
        {
            DateTime? dateOrNull = null;
            DateTime parsedDate;
            if (theDate != null)
            {
                if (DateTime.TryParse(theDate, out parsedDate))
                {
                    dateOrNull = parsedDate;
                }
            }
            return dateOrNull;
        }

        /// <summary>
        /// Extracts a date value from the FormDataCollection
        /// </summary>
        /// <param name="formDataArgument"></param>
        /// <returns>Integer value, zero for Null</returns>
        public static DateTime? GetDate(string FieldName, string expectedDateFormat, ref FormDataCollection Data)
        {
            var variable = Data.Get(FieldName);
            DateTime? dateOrNull = null;
            DateTime parsedDate;
            if (variable != null)
            {
                if (DateTime.TryParseExact(variable, expectedDateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedDate))
                {
                    dateOrNull = parsedDate;
                }
            }
            return dateOrNull;
        }

        public static DateTime? GetDateAllowEmpty(string FieldName, ref FormDataCollection Data, string errorMessage)
        {
            var variable = Data.Get(FieldName);
            var parsedDate = DateTime.Now;

            if (string.IsNullOrEmpty(variable))
            {
                return null;
            }

            //IE 11 has weird unicode characters when instantiating dates in javascript so need to strip them out
            //TODO: should do this in dateFactory.js but need a quick tactical fix
            var onlyACSIICharactersDate = Encoding.UTF8.GetString(Encoding.ASCII.GetBytes(variable)).Replace("?", string.Empty);

            if (DateTime.TryParse(onlyACSIICharactersDate, out parsedDate))
            {
                return parsedDate;
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
        }

        public static DateTime GetDateOrFail(string FieldName, ref FormDataCollection Data, string errorMessage)
        {
            var variable = Data.Get(FieldName);
            var parsedDate = DateTime.Now;

            //IE 11 has weird unicode characters when instantiating dates in javascript so need to strip them out
            //TODO: should do this in dateFactory.js but need a quick tactical fix
            var onlyACSIICharactersDate = Encoding.UTF8.GetString(Encoding.ASCII.GetBytes(variable)).Replace("?", string.Empty);

            if (DateTime.TryParse(onlyACSIICharactersDate, out parsedDate))
            {
                return parsedDate;
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent(errorMessage),
                        ReasonPhrase = "We can't process your request"
                    }
                );
            }
        }

        public static DateTime? GetDate(string FieldName, ref FormDataCollection Data)
        {
            var variable = Data.Get(FieldName);
            var parsedDate = DateTime.Now;
            DateTime? retDate;

            if (variable != null)
            {
                //IE 11 has weird unicode characters when instantiating dates in javascript so need to strip them out
                //TODO: should do this in dateFactory.js but need a quick tactical fix
                var onlyACSIICharactersDate = Encoding.UTF8.GetString(Encoding.ASCII.GetBytes(variable)).Replace("?", string.Empty);

                retDate = DateTime.TryParse(onlyACSIICharactersDate, out parsedDate) ? parsedDate : new Nullable<DateTime>();
            }
            else
            {
                retDate = new Nullable<DateTime>();
            }

            return retDate;
        }

        /// <summary>
        /// Parse a time string and add the hours and minutes to a datetime
        /// </summary>
        /// <param name="hoursMinutes"></param>
        /// <param name="startDate"></param>
        /// <param name="formData"></param>
        /// <returns></returns>
        public static DateTime? GetTime(string FieldName, DateTime? dateTime, ref FormDataCollection Data)
        {
            var variable = Data.Get(FieldName);
            DateTime? dateOrNull = null;
            if (variable != null)
            {
                if(dateTime != null)
                {
                    var hoursMinutesArray = variable.Split(":".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
                    if(hoursMinutesArray.Length == 2)
                    {
                        int hours;
                        int minutes;
                        if (int.TryParse(hoursMinutesArray[0], out hours) && int.TryParse(hoursMinutesArray[1], out minutes))
                        {
                            dateOrNull = ((DateTime)dateTime).AddHours(hours).AddMinutes(minutes);
                        }
                    }
                }
            }
            return dateOrNull;
        }

        public static string ReplaceLastOccurrence(string Source, string Find, string Replace)
        {
            int place = Source.LastIndexOf(Find);

            if (place == -1)
                return Source;

            string result = Source.Remove(place, Find.Length).Insert(place, Replace);
            return result;
        }

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