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
    public class PaymentCardSupplierController : AtlasBaseController
    {

        // GET api/paymentcardsupplier/{test}
        [Route("api/paymentcardsupplier/{SearchText}")]
        [HttpGet]
        public object Get(string SearchText)
        {
            return atlasDB.PaymentCardSuppliers
                    .Where(
                        cardSupplier =>
                            cardSupplier.Disabled == false &&
                            cardSupplier.Name.Contains(SearchText)
                    )
                    .Take(15)
                    .Select (theCardSupplier => new
                    {
                        theCardSupplier.Id,
                        theCardSupplier.Name
                    })
                    .ToList();
        }

    }
}