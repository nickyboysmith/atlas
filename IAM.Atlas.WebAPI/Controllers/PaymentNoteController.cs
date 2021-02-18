using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net.Http.Formatting;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class PaymentNoteController : AtlasBaseController 
    {
        [Route("api/PaymentNote/GetTypes")]
        public IEnumerable<NoteTypeJSON> GetNoteTypes()
        {
            return atlasDB.NoteType.Select(n => new NoteTypeJSON { Id = n.Id, Name = n.Name }).ToList();
        }

        // POST: api/Client
        public string Post([FromBody] FormDataCollection formBody)
        {
            string status = "";
            if (formBody.Count() > 0)
            {
                var formPaymentId = formBody.Get("PaymentId");
                var formNote = formBody.Get("Note");
                var formUserId = formBody.Get("UserId");
                var formNoteTypeId = formBody["NoteTypeId"];

                try
                {
                    if (formPaymentId != null && formNote != null && formUserId != null)
                    {
                        int paymentId = Int32.Parse(formPaymentId.ToString());
                        string noteText = formNote.ToString();
                        int userId = Int32.Parse(formUserId.ToString());
                        int noteTypeId = Int32.Parse(formNoteTypeId.ToString());

                        Payment payment = atlasDB.Payment.Where(p => p.Id == paymentId).FirstOrDefault();

                        if (payment != null)
                        {
                            if (userHasPermission(userId))
                            {
                                Note note = new Note();
                                note.CreatedByUserId = userId;  // this needs to be checked that the user exists when this functionality is done
                                note.DateCreated = DateTime.Now;
                                note.Note1 = noteText;
                                note.NoteTypeId = noteTypeId;

                                PaymentNote paymentNote = new PaymentNote();
                                paymentNote.Payment = payment;
                                paymentNote.Note = note;

                                payment.PaymentNotes.Add(paymentNote);

                                atlasDB.SaveChanges();
                                status = "success";
                            }
                        }
                    }
                }
                catch (DbEntityValidationException ex)
                {
                    status = "error: data validation error";
                }
            }
            else
            {
                status = "error: JSON not sent.";
            }
            return status;
        }

        private bool userHasPermission(int userId)
        {
            return true;
        }

        /// <summary>
        /// 
        /// </summary>
        [Route("api/PaymentNote/GetNotesByPayment/{Id}")]
        public List<NoteJSON> GetNotesByPayment(int Id)
        {
            var notes = atlasDB.PaymentNotes
                                .Include(pn => pn.Note)
                                .Include(pn => pn.Note.NoteType)
                                .Where(pn => pn.PaymentId == Id)
                                .Select(pn => new NoteJSON
                                {
                                    Text = pn.Note.Note1,
                                    NoteId = pn.Note.Id,
                                    NoteTypeName = pn.Note.NoteType.Name
                                })
                                .ToList();
            return notes;
        }
    }
}
