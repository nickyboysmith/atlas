using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class VatController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/Vat/getList")]
        public List<vwVatRate> getList()
        {
            var vatRates = atlasDBViews.vwVatRates.OrderByDescending(vr => vr.EffectiveFromDate).ToList();
            return vatRates;
        }

        [HttpGet]
        [Route("api/Vat/delete/{vatRateId}/{userId}")]
        public bool delete(int vatRateId, int userId)
        {
            var deleted = false;
            if (UserHasSystemAdminStatus(userId))
            {
                var vatRate = atlasDB.VatRates.Where(vr => vr.Id == vatRateId).FirstOrDefault();
                if(vatRate != null)
                {
                    vatRate.Deleted = true;
                    vatRate.DeletedByUserId = userId;
                    vatRate.DateDeleted = DateTime.Now;

                    var entry = atlasDB.Entry(vatRate);
                    entry.State = System.Data.Entity.EntityState.Modified;
                    atlasDB.SaveChanges();
                    deleted = true;
                }
            }
            
            return deleted;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns>the new VAT Rate's Id</returns>
        [HttpGet]
        [Route("api/vat/add/{vatRateToAdd}/{effectiveFromDate}/{userId}")]
        public int add(double vatRateToAdd, DateTime effectiveFromDate, int userId)
        {
            var addedVatRateId = -1;

            if (UserHasSystemAdminStatus(userId))
            {
                // check to see if it already exists
                var existingVatRate = atlasDB.VatRates.Where(vr => vr.EffectiveFromDate == effectiveFromDate && vr.VATRate1 == vatRateToAdd)
                                        .FirstOrDefault();
                if(existingVatRate == null)
                {
                    var vatRate = new VatRate();
                    vatRate.AddedByUserId = userId;
                    vatRate.DateAdded = DateTime.Now;
                    vatRate.EffectiveFromDate = effectiveFromDate;
                    vatRate.VATRate1 = vatRateToAdd;

                    atlasDB.VatRates.Add(vatRate);
                    atlasDB.SaveChanges();

                    addedVatRateId = vatRate.Id;
                }
                else
                {
                    throw new Exception("VAT rate already exists, VAT rate not added.");
                }
            }

            return addedVatRateId;
        }
    }
}