using IAM.Atlas.WebAPI.Controllers;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Controllers.Tests
{
    [TestClass()]
    public class AtlasBaseControllerTests
    {
        /*
         var config = new HttpConfiguration();
var request = new HttpRequestMessage(HttpMethod.Post, "http://localhost/api/products");
var route = config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{id}");
var routeData = new HttpRouteData(route, new HttpRouteValueDictionary { { "controller", "products" } });

controller.ControllerContext = new HttpControllerContext(config, routeData, request);
controller.Request = request;
controller.Request.Properties[HttpPropertyKeys.HttpConfigurationKey] = config;
             */
        [TestMethod()]
        public void GetUserIdFromTokenTest()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void IsValidEmailTest()
        {
            var email = "test@test.com";
            var controller = new AtlasBaseController();

            var result = controller.IsValidEmail(email);

            Assert.AreEqual(true, result);

            email = "test~test.com";
            result = controller.IsValidEmail(email);
            Assert.AreEqual(false, result);
        }

        [TestMethod()]
        public void UserAuthorisedForOrganisationTest()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void GetUserIdFromTokenTest1()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserMatchesTokenTest()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserAuthorisedForClientTest()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserAuthorisedForCourseTest()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void IsValidEmailTest1()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserAuthorisedForOrganisationTest1()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void GetUserIdFromTokenTest2()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserMatchesTokenTest1()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserAuthorisedForClientTest1()
        {
            Assert.Fail();
        }

        [TestMethod()]
        public void UserAuthorisedForCourseTest1()
        {
            Assert.Fail();
        }
    }
}