/*
	SCRIPT: Rename Column on table ClientDORSData
	Author: Robert Newnham
	Created: 18/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_38.02_RenameColumnDORSReferenceTableClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Column on table ClientDORSData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDORSDataDORSReference' 
				AND object_id = OBJECT_ID('ClientDORSData'))
		BEGIN
		   DROP INDEX [IX_ClientDORSDataDORSReference] ON [dbo].[ClientDORSData];
		END
		
		-- ClientDORSData
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSReference' 
						and Object_ID = Object_ID(N'ClientDORSData')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.ClientDORSData.DORSReference', N'DORSAttendanceRef', 'COLUMN' 
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDORSDataDORSAttendanceRef' 
				AND object_id = OBJECT_ID('ClientDORSData'))
		BEGIN
		   DROP INDEX [IX_ClientDORSDataDORSAttendanceRef] ON [dbo].[ClientDORSData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDORSDataDORSAttendanceRef] ON [dbo].[ClientDORSData]
		(
			[DORSAttendanceRef] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;