using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.DORS.Webservice
{
    /// <summary>
    /// This custom exception is just to notify the calling project that there was an error connecting to DORS
    /// </summary>
    public class DORSConnectionException
    {
        static string connectionExceptionMessageText = "An unsecured or incorrectly secured fault was received from the other party.";

        public static bool isDORSConnectionException(Exception ex)
        {
            bool DORSConnectionException = false;
            if (ex.Message.Contains(connectionExceptionMessageText) && ex.GetType() == typeof(System.ServiceModel.Security.MessageSecurityException)) DORSConnectionException = true;
            return DORSConnectionException;
        }
    }
}
