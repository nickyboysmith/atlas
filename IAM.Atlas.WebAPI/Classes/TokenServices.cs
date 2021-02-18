using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Controllers;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Validation;
using System.Linq;

namespace IAM.Atlas.WebAPI.Classes
{
    public class TokenServices : AtlasBaseController
    {
        //put all db calls in a try catch
        public int tokenExpiry = 1800;

        // create token methods
        public LoginSession GenerateToken(int userId)
        {
            var token = Guid.NewGuid().ToString();
            DateTime issuedOn = DateTime.Now;
            DateTime expiredOn = DateTime.Now.AddSeconds(
            Convert.ToDouble(tokenExpiry));

            try
            {
                LoginSession tokenDomain = new LoginSession
                {
                    UserId = userId,
                    AuthToken = token,
                    IssuedOn = issuedOn,
                    ExpiresOn = expiredOn
                };

                atlasDB.LoginSessions.Add(tokenDomain);
                atlasDB.SaveChanges();

                return tokenDomain;

            }
            catch (DbEntityValidationException ex)
            {
                return new LoginSession
                {
                    UserId = 0,
                    AuthToken = "",
                    IssuedOn = DateTime.Now,
                    ExpiresOn = DateTime.Now
                };
            }
        }

        public bool ValidateToken(string tokenId)
        {
            try
            {
                using (Atlas_DevEntities tokenAtlasDB = new Atlas_DevEntities())
                {
                    var token = tokenAtlasDB.LoginSessions.Where(
                    login =>
                        login.AuthToken == tokenId &&
                        login.ExpiresOn > DateTime.Now
                    )
                    .FirstOrDefault();

                    if (token != null)
                    {
                        tokenAtlasDB.Entry(token).Reload();

                        if (token.ExpiresOn > DateTime.Now)
                        {
                            // add an extra 900 seconds
                            token.ExpiresOn = DateTime.Now.AddSeconds(Convert.ToDouble(tokenExpiry));
                            tokenAtlasDB.Entry(token).State = EntityState.Modified;
                            tokenAtlasDB.SaveChanges();
                            return true;
                        }
                    }
                    return false;
                }
            }
            catch (Exception ex)
            {
                //TODO: Tactical Fix - Need to understand why the code raises a NotSupportedException and fix properly
                //This should be safe as the only problem will be not updating the ExpiryTime and exception only seems to be raised by drag and drop
                //if (ex is NotSupportedException) 
                //{
                //    return true;
                //}
                //else
                //{
                return false;
                //}
            }
        }

        public int GetTokenUserId(string tokenId)
        {
            var userId = 0;
            try
            {
                // There was a bizarre problem with token services causing an exception
                // when sending documents to print queue.
                // The below code fixed it..inexplicably.
                List<LoginSession> tokenList;

                try
                {
                    tokenList = atlasDB.LoginSessions
                                        .Where(login => login.AuthToken == tokenId)
                                        .ToList();
                }
                catch (Exception ex)
                {
                    tokenList = atlasDB.LoginSessions
                                        .Where(login => login.AuthToken == tokenId)
                                        .ToList();
                }

                int tokenCount = 0;
                tokenCount = tokenList.Count();

                if (tokenCount == 0)
                {
                    userId = 0;
                }
                else
                {
                    userId = tokenList.First().UserId;
                }


            }
            catch (DbEntityValidationException ex)
            {
                userId = 0;
            }
            return userId;
        }

        public bool KillToken(string tokenId)
        {

            try
            {
                var tokenList = atlasDB.LoginSessions.Where(
                    login => login.AuthToken == tokenId
                )
                .ToList();

                foreach (LoginSession token in tokenList)
                {
                    atlasDB.LoginSessions.Remove(token);
                }

                atlasDB.SaveChanges();

                var isNotDeleted = atlasDB.LoginSessions.Select(
                    tokens => tokens.AuthToken == tokenId
                ).Any();

                if (isNotDeleted)
                {
                    return false;
                }
                return true;
            }
            catch (DbEntityValidationException ex)
            {
                return false;
            }

        }

        public bool DeleteTokenByUserId(int userId)
        {
            try
            {
                var tokenList = atlasDB.LoginSessions.Where(
                    login => login.UserId == userId
                )
                .ToList();

                // Remove all previous tokens associated
                // With the previous login
                foreach (LoginSession token in tokenList)
                {
                    atlasDB.LoginSessions.Remove(token);
                }

                atlasDB.SaveChanges();

                var isNotDeleted = atlasDB.LoginSessions.Select(
                    tokens => tokens.UserId == userId
                ).Any();

                return !isNotDeleted;
            }
            catch (DbEntityValidationException ex)
            {
                return false;
            }

        }

    }

}