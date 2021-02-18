/*
	SCRIPT: Add insert trigger to the Organisation table to insert entry into OrganisationSystemTaskMessaging table
	Author: Dan Murray and Assisted by Robert Newnham
	Created: 25/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_33.01_AddInsertTriggerToOrganisationToAddOrganisationSystemTaskMessaging.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the Organisation table to insert entry into OrganisationSystemTaskMessaging table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_OrganisationToAddOrganisationSystemTaskMessaging_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_OrganisationToAddOrganisationSystemTaskMessaging_INSERT];
	END
GO
	CREATE TRIGGER TRG_OrganisationToAddOrganisationSystemTaskMessaging_INSERT ON Organisation FOR INSERT
	AS
	
		DECLARE @SysUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';

		INSERT INTO dbo.OrganisationSystemTaskMessaging (
			OrganisationId
			, SystemTaskId
			, SendMessagesViaEmail
			, SendMessagesViaInternalMessaging
			, UpdatedByUserId
			, DateUpdated
			)
		SELECT 
			I.Id AS OrganisationId
			, ST.Id AS SystemTaskId
			, 'True' AS SendMessagesViaEmail
			, 'True' AS SendMessagesViaInternalMessaging
			, @SysUserId AS UpdatedByUserId
			, GetDate() AS DateUpdated
		FROM INSERTED I, dbo.SystemTask ST;
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP023_33.01_AddInsertTriggerToOrganisationToAddOrganisationSystemTaskMessaging.sql';
	EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	GO

