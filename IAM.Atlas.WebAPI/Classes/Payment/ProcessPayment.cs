using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using IAM.Atlas.Tools;
using System.Text.RegularExpressions;
using IAM.Atlas.WebAPI.Models.Payment;
using System.Runtime.Remoting;

namespace IAM.Atlas.WebAPI.Classes.Payment
{
    class ProcessPayment
    {
        public object Start(string ProviderName
                            , Card Card, CardHolderAddress Address
                            , decimal Amount
                            , string ChargeType
                            , object ProviderCredentials
                            , string MethodName
                            , string ClientIP
                            , string paymentOrderReference
                            )
        {
            var PaymentProviderClassName = PrepareProviderName(ProviderName);
            var CallProviderClassResult = CallProviderClass(PaymentProviderClassName, Card, Address, Amount, ChargeType, ProviderCredentials, MethodName, ClientIP, paymentOrderReference);
            return CallProviderClassResult;
        }

        public object CompleteAuth(string ProviderName, string MD, string PaRes, object ProviderCredentials, string CardType, string MethodName, string paymentOrderReference)
        {
            var PaymentProviderClassName = PrepareProviderName(ProviderName);
            return CallProviderAuthClass(PaymentProviderClassName, MD, PaRes, ProviderCredentials, CardType, MethodName, paymentOrderReference);
        }


        private string PrepareProviderName (string ProviderName)
        {
            var pascalCase = StringTools.ToPascalCase(ProviderName);
            return Regex.Replace(pascalCase, @"\s", "");
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="provider"></param>
        /// <param name="Card"></param>
        /// <param name="Address"></param>
        /// <param name="Amount"></param>
        /// <param name="ChargeType"></param>
        /// <param name="ProviderCredentials"></param>
        /// <param name="MethodName"></param>
        /// <param name="ClientIP"></param>
        /// <returns></returns>
        public object CallProviderClass(string provider, Card Card, CardHolderAddress Address, decimal Amount, string ChargeType, object ProviderCredentials, string MethodName, string ClientIP, string paymentOrderReference)
        {
            // Get a type from the string 
            Type type = Type.GetType("IAM.Atlas.WebAPI.Classes.Payment.Providers." + provider);

            // Create an instance of that type
            Object obj = Activator.CreateInstance(type);

            // Retrieve the method you are looking for
            MethodInfo methodToCall = type.GetMethod(MethodName);

            // the real one to use
            try
            {
                //return methodToCall.Invoke(obj, new object[] { Card, Address, Amount, ChargeType, ProviderCredentials, ClientIP, paymentOrderReference });
                var methodCallResult = methodToCall.Invoke(obj, new object[] { Card, Address, Amount, ChargeType, ProviderCredentials, ClientIP, paymentOrderReference });
                return methodCallResult;

            }
            catch (Exception ex) {
                throw ex;
            }

        }

        private object CallProviderAuthClass(string Provider, string MD, string PaRes, object ProviderCredentials, string CardType, string MethodName, string paymentOrderReference)
        {

            // Get a type from the string 
            Type type = Type.GetType("IAM.Atlas.WebAPI.Classes.Payment.Providers." + Provider);

            // Create an instance of that type
            Object obj = Activator.CreateInstance(type);

            // Retrieve the method you are looking for
            MethodInfo methodToCall = type.GetMethod(MethodName);

            try
            {
                return methodToCall.Invoke(obj, new object[] { ProviderCredentials, MD, PaRes, CardType, paymentOrderReference });
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


    }

}
