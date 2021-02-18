using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.Tools;
using Newtonsoft.Json;
using IAM.Atlas.WebAPI.Classes.Payment;
using System.Dynamic;
using IAM.Atlas.WebAPI.Models.Payment;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class PaymentCardTypeController : AtlasBaseController
    {
        [Route("api/PaymentCardType")]
        [HttpGet]
        // GET api/paymentcardtype
        public object Get()
        {
            return atlasDBViews.vwPaymentCardTypes
                    .Where(x => x.PaymentCardTypeDisabled == false)
                    .Select (theCardType => new
                    {
                        id = theCardType.PaymentCardTypeId
                        , Name = theCardType.PaymentCardTypeName
                        , DisplayName = theCardType.PaymentCardTypeDisplayName
                        , ValidationTypeId = theCardType.PaymentCardValidationTypeId
                        , ValidationTypeName = theCardType.PaymentCardValidationTypeName
                    })
                    .ToList();
        }


        [Route("api/PaymentCardValidationType")]
        [HttpGet]
        // GET api/PaymentCardValidationType
        public object PaymentCardValidationType()
        {
            return atlasDBViews.vwPaymentCardValidationTypes
                    .Select (theValidationType => new
                    {
                        Id = theValidationType.PaymentCardValidationTypeId
                        , Name = theValidationType.PaymentCardValidationTypeName
                        , IssuerIdentificationCharacters = theValidationType.IssuerIdentificationCharacters
                        , ValidLength = theValidationType.ValidLength
                    })
                    .ToList();
        }

    }
}