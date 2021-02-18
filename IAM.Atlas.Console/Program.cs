using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.Data;
using IAM.Atlas.DocumentManagement;

namespace IAM.Atlas.Console
{
    class Program
    {

        static void Main(string[] args)
        {
            var csv = new DataImporter();
            csv.ImportCSVDataFile(1);

            // initialise the database connection
            Atlas_DevEntities _atlasDB;
            _atlasDB = new Atlas_DevEntities();
            _atlasDB.Configuration.LazyLoadingEnabled = false;

            // Retrieve data from DB
            List<SystemControl> systemControlList = _atlasDB.SystemControls.ToList();

            for (int i = 0; i < systemControlList.Count; i++)
            {
                System.Console.WriteLine(
                    "System Available: " + systemControlList[i].SystemAvailable + "\n" +
                    "System Status: " + systemControlList[i].SystemStatus + "\n" +
                    "System Status Colour:" + systemControlList[i].SystemStatusColour + "\n" +
                    "System Blocked Message: " + systemControlList[i].SystemBlockedMessage + "\n" +
                    "Max Failed Logins: " + systemControlList[i].MaxFailedLogins + "\n" +
                    "System Inactivity Timeout: " + systemControlList[i].SystemInactivityTimeout);
            }
            
            var blobService = new DocumentManagement.BlobService();
            blobService.DeleteBlob();
            var blobServiceTest = blobService.ListBlobs(null, 1);
            foreach (var blob in blobServiceTest)
            {
                System.Console.WriteLine(blob);
            }

            System.Console.ReadLine();
        }

        public static void blobConnectionService()
        {
            // CloudStorageConnection blobService = new CloudStorageConnection();
            BlobService containerService = new DocumentManagement.BlobService();
        }

        public static void listBlobs()
        {
            BlobService blobService = new DocumentManagement.BlobService();
        }

        public static void emailTest()
        {
            CloudStorageAndDBConnections cloudStorageAndDBConnections = new CloudStorageAndDBConnections();
        }
    }
}
