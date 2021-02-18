using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.WebAPI.Models.Payment;


namespace IAM.Atlas.WebAPI.Classes.Payment
{
    interface PaymentProviderInterface
    {
        object ChargeCard(Card Card, CardHolderAddress Address, decimal Amount, string ChargeType, object ProviderCredentials, string ClientIP, string paymentOrderReference);

        object CompleteAuthorization(object ProviderCredentials, string MD, string PaRes, string CardType, string paymentOrderReference);

        object ErrorHandler(string ErrorMessage);

    }
}
