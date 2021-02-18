using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Payment
{
    public class Card
    {
        public string HolderName { get;  set;}
        public string Type { get; set; }
        public string Number { get; set; }
        public string CV2 { get; set; }
        public int? IssueNumber { get; set; }
        public CardDates Expiry { get; set; }
        public CardDates Start { get; set; }

        public string GetDates(dynamic CardDate)
        {

            if (CardDate.Month == null || CardDate.Year == null)
            {
                return "/";
            }

            var month = CardDate.Month;
            var year = CardDate.Year;

            if (month == "" || year == "")
            {
                return "";
            }
            return month + "/" + year;
        }

    }

    public class CardDates
    {
        public string Month { get; set; }
        public string Year { get; set; }

    }

}
