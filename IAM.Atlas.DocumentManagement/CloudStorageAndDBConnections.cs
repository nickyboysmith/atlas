using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using IAM.Atlas.Data;

namespace IAM.Atlas.DocumentManagement
{
    public class CloudStorageAndDBConnections
    {
        private Atlas_DevEntities _atlasDB;
        private CloudBlobClient _blobClient;
        private CloudStorageAccount _storageAccount;

        public Atlas_DevEntities atlasDB
        {
            get
            {
                _atlasDB.Configuration.LazyLoadingEnabled = false;
                return _atlasDB;
            }
        }
        
        public CloudStorageAccount storageAccount
        {
            get
            {
                return _storageAccount;
            }
        }

        public CloudBlobClient blobClient
        {
            get
            {
                return _blobClient;
            }
        }

        public CloudStorageAndDBConnections()
        {
            string connectionString = ConfigurationManager.AppSettings["StorageConnectionString"];
            _storageAccount = CloudStorageAccount.Parse(connectionString);
            _blobClient = storageAccount.CreateCloudBlobClient();
            _atlasDB = new Atlas_DevEntities();
        }
    }
}
