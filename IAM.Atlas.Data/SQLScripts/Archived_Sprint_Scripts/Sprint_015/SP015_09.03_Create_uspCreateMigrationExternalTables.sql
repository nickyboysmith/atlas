
/*
	SCRIPT: Create a stored procedure to Create the Migration External Tables Linked to Old Atlas
	Author: Robert Newnham
	Created: 29/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_08.02_Create_uspCreateMigrationExternalTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to Create the Migration External Tables Linked to Old Atlas';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateMigrationExternalTables', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateMigrationExternalTables;
END		
GO

/*
	Create uspCreateMigrationExternalTables
*/
CREATE PROCEDURE uspCreateMigrationExternalTables
AS
BEGIN
	
	IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_Logins')
	BEGIN
		CREATE EXTERNAL TABLE migration.[tbl_DORS_Logins]
		(
			[lg_id] [int] NOT NULL,
			[lg_username] [varchar](50) NOT NULL,
			[lg_password] [varchar](50) NOT NULL,
			[lg_notificationAddress] [varchar](500) NOT NULL,
			[lg_owner_org_id] [int] NOT NULL,
			[lg_lastDateChanged] [datetime] NOT NULL,
			[lg_isGeneralPurposeLogin] [bit] NOT NULL,
			[lg_sendNotificationEmailOnExpiry] [bit] NOT NULL,
			[lg_disable_dors] [bit] NOT NULL
		)
		WITH 
		(
			DATA_SOURCE = IAM_Elastic_Old_Atlas
		)
		;
	END

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Organisation')
	BEGIN
		CREATE EXTERNAL TABLE migration.[tbl_LU_Organisation](
			[org_id] [int] NOT NULL,
			[org_name] [varchar](50) NULL,
			[org_inactivityLockout] [int] NOT NULL,
			[org_forceId] [varchar](50) NULL,
			[org_passwordWarning] [int] NULL,
			[org_passwordExpiry] [int] NULL,
			[org_dors_for_id] [int] NULL,
			[org_old_contactSalutation] [varchar](50) NULL,
			[org_old_contactName] [varchar](50) NULL,
			[org_old_address] [varchar](200) NULL,
			[org_old_postcode] [varchar](50) NULL,
			[org_old_telephone] [varchar](50) NULL,
			[org_old_fax] [varchar](50) NULL,
			[org_old_emailAddress] [varchar](200) NULL,
			[org_old_onlineRejectionEmailAddress] [varchar](200) NULL,
			[org_old_isReferrer] [bit] NOT NULL,
			[org_old_isServiceProvider] [bit] NOT NULL,
			[org_active] [bit] NOT NULL
		)
		WITH 
		(
			DATA_SOURCE = IAM_Elastic_Old_Atlas
		)
		;
	END


END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP015_08.02_Create_uspCreateMigrationExternalTables.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

