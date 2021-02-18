#####################################################
# 
# This scripts connects to the old Atlas database
# and amends the client doc filenames before
# uploading the renamed files to Azure.
#
# Pre-requistes - Create two folders on D:\ drive
# - D:\AtlasDocs and D:\AtlasRenamed
# Alternatively, change the variables below.
#
# Author: Dan Hough
# Date: 01/06/2016
#
#####################################################






#Uncomment Add-AzureAccount if you need to login
#Add-AzureAccount

$StorageAccountName = "atlasdocument"
$StorageAccountKey = "XbfsSV9LxJngI6eR7UwAtsVrTcgrGlDs6ncwSeaL96/JKTgfesbSEvpqHrRQ8NnRlk/1oMyT7BkSgqwcwDTlhg=="
$StorageContainerName = "Client"
$SQLServer = Get-AzureSqlDatabase -ServerName "ymw3trna08"
$SQLDBName = “Atlas_Dev”
$extractFile = @"
C:\AtlasDocs\AtlasDocumentMigration.csv
"@
$source = 'D:\AtlasDocs'
$dest = 'D:\AtlasRenamed'
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

#SQL Query - Calculates new filename from old filename
$SqlQuery = 
"EXEC [dbo].[uspCreateMigrationConnectionToOldAtlasDB]

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Documents')
	BEGIN
		CREATE EXTERNAL TABLE migration.[tbl_Driver_Documents]
		(
			[drdoc_id] [int] NOT NULL,
			[drdoc_original_drdoc_id] [int] NULL,
			[drdoc_dr_id] [int] NOT NULL,
			[drdoc_usr_id] [int] NOT NULL,
			[drdoc_originalFilename] [varchar](150) NOT NULL,
			[drdoc_documentName] [varchar](150) NOT NULL,
			[drdoc_uploadDate] [datetime] NOT NULL 
		)
		WITH 
		(
			DATA_SOURCE = IAM_Elastic_Old_Atlas
		)
		;
	END

EXEC [dbo].[uspDropMigrationConnectionToOldAtlasDB]

SELECT 'ClientDoc_' + RIGHT(REPLACE(STR(drdoc_id),' ','0'),8) as OldAtlasFileName
, drdoc_OriginalFileName
, 'Client' + CAST(cpi.ClientId as varchar)  + '_' + REPLACE(REVERSE(SUBSTRING(REVERSE(drdoc_originalFilename), CHARINDEX('.', REVERSE(drdoc_originalFilename)) + 1, 999)), ' ','') AS NewFileName
, tdd.drdoc_dr_id
, cpi.clientid
FROM [migration].[tbl_Driver_Documents] tdd inner join
ClientPreviousId cpi ON cpi.PreviousClientId = tdd.drdoc_dr_id

DROP EXTERNAL TABLE migration.[tbl_Driver_Documents]"
 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
 
$SqlConnection.ConnectionString = 
“Server=tcp:ymw3trna08.database.windows.net,1433;Data Source=ymw3trna08.database.windows.net;Initial Catalog=Atlas_Dev;Persist Security Info=False;User ID=AtlasDev@ymw3trna08;Password=IAM2015dev~!;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;”
 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
 
$SqlCmd.CommandText = $SqlQuery
 
$SqlCmd.Connection = $SqlConnection
 
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
 
$SqlAdapter.SelectCommand = $SqlCmd
 
$DataSet = New-Object System.Data.DataSet
 
#Fills dataset with query and exports it to CSV - done this way so there's a saved log
$nRecs = $SqlAdapter.Fill($DataSet)
$DataSet.Tables[0] | Export-Csv $extractFile

#Imports CSV and loops through renaming and moving the matched files to a separate directory
$fileinfo = Import-Csv $extractFile
foreach($line in $fileinfo) {
    Get-ChildItem $source | where {$_.name -eq $line.OldAtlasFileName} | % {
        Move-Item $_.FullName -Destination $(Join-Path $dest $line.NewFileName)
    }
}


#Uploads files to Azure
New-AzureStorageContainer -Name $StorageContainerName -Permission Off -Context $ctx
$upload = Get-ChildItem –Path $dest | Set-AzureStorageBlobContent -Container $StorageContainerName -Context $ctx