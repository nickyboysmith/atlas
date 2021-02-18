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

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class PaymentTypeController : AtlasBaseController
    {


        // GET api/paymentType/5
        public object Get(int Id)
        {
            var searchResults =
            (
                from organisationUser in atlasDB.OrganisationUsers
                join organisation in atlasDB.Organisations on organisationUser.OrganisationId equals organisation.Id
                where organisationUser.UserId == Id
                select new { organisation.Id, organisation.Name }
            ).ToList();

            return searchResults;
        }

        

        [AuthorizationRequired]
        [Route("api/paymenttype/getPaymentTypesByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetPaymentTypesByOrganisation(int OrganisationId)
        {
            try
            {
                return atlasDB.OrganisationPaymentType
                        .Include("PaymentType")
                        .Where(o => o.OrganisationId == OrganisationId)
                        .Select(
                            opt => new
                            {
                                Id = opt.PaymentType.Id,
                                Name = opt.PaymentType.Name,
                                Disabled = opt.PaymentType.Disabled
                            }
                        ).ToList();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        
        // GET api/paymentType
        public string Post([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var PaymentTypeId = StringTools.GetInt("Id", ref formData);
            var Name = StringTools.GetString("Name", ref formData);
            var Disabled = StringTools.GetBool("Disabled", ref formData);

            string status = "";
            
            // Add the Payment Type 
            if (PaymentTypeId == 0)
            {
                try {

                    PaymentType paymentType = new PaymentType();
                    
                    paymentType.Name = Name;
                    paymentType.Disabled = Disabled;

                    atlasDB.PaymentType.Add(paymentType);

                    OrganisationPaymentType organisationPaymentType = new OrganisationPaymentType();

                    organisationPaymentType.OrganisationId = OrganisationId;
                    organisationPaymentType.PaymentTypeId = paymentType.Id;

                    atlasDB.OrganisationPaymentType.Add(organisationPaymentType);

                    atlasDB.SaveChanges();

                    status = "Payment Type Saved Successfully";

                }
                catch (DbEntityValidationException ex) {
                    status = "There was an error Adding your Payment Type. Please retry.";
                }
            }
            // Update the payment
            else if (PaymentTypeId > 0)
            {
                try {

                    var editPaymentType = atlasDB.PaymentType.Where(pt => pt.Id == PaymentTypeId).FirstOrDefault();

                    if (editPaymentType != null) {

                        atlasDB.PaymentType.Attach(editPaymentType);
                        var entry = atlasDB.Entry(editPaymentType);

                        editPaymentType.Name = Name;
                        atlasDB.Entry(editPaymentType).Property("Name").IsModified = true;
                        editPaymentType.Disabled = Disabled;
                        atlasDB.Entry(editPaymentType).Property("Disabled").IsModified = true;

                    
                        atlasDB.SaveChanges();

                        status = "Payment Type Saved Successfully";

                    }
                }
                catch (DbEntityValidationException ex)
                {
                    status = "There was an error Updating your Payment Type. Please retry.";
                }
            }
            
            return status;

        }
    }
}