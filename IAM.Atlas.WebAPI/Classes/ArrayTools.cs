using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web;

namespace IAM.Atlas.WebAPI.Classes
{
    public static class ArrayTools
    {
        /// <summary>
        /// Find out the length of an Array in a form's data parameters.
        /// </summary>
        /// <param name="ArrayName">Name of the array parameter</param>
        /// <param name="formBody">The form data colleciton containing the array</param>
        /// <returns></returns>
        public static int ArrayLength(string ArrayName, ref FormDataCollection formBody)
        {
            var count = 0;
            var findingIndexes = true;
            while (findingIndexes)
            {
                var currentIndexFound = false;
                foreach (var param in formBody)
                {
                    var arrayPrefix = ArrayName + "[" + count + "]";
                    if (param.Key.StartsWith(arrayPrefix))
                    {
                        count++;
                        currentIndexFound = true;
                        break;
                    }
                }
                if (!currentIndexFound)
                {
                    findingIndexes = false;
                }
            }
            return count;
        }
    }
}