/*This script populates the Document, ClientDocument and DocumentOwner tables 
  based upon the information held in the Old Atlas database.

  Author: Dan Hough
  Date: 08/06/2016
*/


/*Creates connection to old Atlas database*/

EXEC [dbo].[uspCreateMigrationConnectionToOldAtlasDB]

/*Creates migration.tbl_Driver_Documents table from old Atlas database*/

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Documents')
	BEGIN
		CREATE EXTERNAL TABLE migration.[tbl_Driver_Documents]
		(
			[drdoc_id] [int] IDENTITY(1,1) NOT NULL,
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

	/* 
	Inserts in to Document table.
	This will insert several thousand more rows than the amount of docs that was uploaded to Azure.
	The document migration process uploaded around 4.8k docs to Azure, query returns circa 9k - 
	due to lack of documents actually present / clients no longer active. Confirmed ok with Rob.
	*/

	BEGIN
		INSERT INTO dbo.Document
				   ([FileName]
				   , OriginalFileName
				   , Title
				   , DateUpdated)
		SELECT 'Client' + CAST(cpi.ClientId AS VARCHAR) + '_' + REPLACE(REVERSE(SUBSTRING(REVERSE(tdd.drdoc_originalFilename), CHARINDEX('.', REVERSE(tdd.drdoc_originalFilename)) + 1, 999)), ' ', '')
			  , tdd.drdoc_originalFilename
			  , drdoc_documentName
			  , tdd.drdoc_uploadDate
		FROM migration.tbl_Driver_Documents tdd INNER JOIN
			 ClientPreviousId cpi ON cpi.PreviousClientId = tdd.drdoc_dr_id
	END
	GO

	/*
	Inserts in to ClientDocument table, finding the ClientId from the Document filename.
	*/

	BEGIN
		INSERT INTO dbo.ClientDocument
				   (ClientId
				   , DocumentId)
		SELECT SUBSTRING([FileName], 7, 7), Id
		FROM Document d
		WHERE d.[FileName] LIKE 'Client%'
	END
	GO

	/* 
	Inserts all rows from 'Document' table into DocumentOwner, where the document starts with 'Client'
	*/

	BEGIN
		INSERT INTO dbo.DocumentOwner
					(DocumentId
				   , OrganisationId)
		SELECT d.Id
			 , co.OrganisationId
		FROM Document d LEFT OUTER JOIN
			 ClientOrganisation co ON SUBSTRING([FileName], 7, 7) = co.ClientId
		WHERE d.[FileName] LIKE 'Client%'
	END
	GO

DROP EXTERNAL TABLE migration.[tbl_Driver_Documents]