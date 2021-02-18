using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.Data;
using System.Data.Entity;

namespace IAM.Atlas.PasswordService
{
    public class PasswordChange
    {
        protected Atlas_DevEntities atlasDB = new Atlas_DevEntities();

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public int GeneratePIN(string usernameOrEmailAddress)
        {
            int PIN = -1;
            User user = atlasDB.Users.Where(a => (a.LoginId == usernameOrEmailAddress || a.Email == usernameOrEmailAddress)).FirstOrDefault();
            if (user != null)
            {
                PIN = new Random().Next(1000, 9999);
                user.PasswordChangePin = PIN;
                try
                {
                    atlasDB.SaveChanges();
                    sendChangePasswordPINEmail(user);
                }
                catch (Exception ex)
                {
                    PIN = -1;
                }
            }
            return PIN;
        }

        void sendChangePasswordPINEmail(User user)
        {
            string fromAddress = "noreply@iamAtlas.co.uk";
            emailService email = new emailService();
            email.send(user.Email, fromAddress, "Password change requested", new StringBuilder().AppendFormat("Your PIN to change your password is {0}.  You can change your password here: some link.", user.PasswordChangePin).ToString());
        }

        /// <summary>
        /// This is just a placeholder class that will be replaced by the real email service when it is done
        /// </summary>
        class emailService
        {
            public void send(string toAddress, string fromAddress, string subject, string body)
            {

            }
        }
    }
}
