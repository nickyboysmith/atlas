
/*
 * SCRIPT: Update Indexes to table PostCodeInformation.
 * Author: Robert Newnham
 * Created: 12/01/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP032_04.03_CorrectIndexesPostCodeInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct Index to table PostCodeInformation';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='PostCodeIndex' 
				AND object_id = OBJECT_ID('PostCodeInformation'))
		BEGIN
		   DROP INDEX [PostCodeIndex] ON [dbo].[PostCodeInformation];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PostCodeInformationPostCode' 
				AND object_id = OBJECT_ID('PostCodeInformation'))
		BEGIN
		   DROP INDEX [IX_PostCodeInformationPostCode] ON [dbo].[PostCodeInformation];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PostCodeInformationPostCode] ON [dbo].[PostCodeInformation]
		(
			[PostCode] ASC
		) INCLUDE ([Easting], [Northing]) WITH (ONLINE = ON);;
		
		/********************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PostCodeInformationPostCodeNoSpaces' 
				AND object_id = OBJECT_ID('PostCodeInformation'))
		BEGIN
		   DROP INDEX [IX_PostCodeInformationPostCodeNoSpaces] ON [dbo].[PostCodeInformation];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PostCodeInformationPostCodeNoSpaces] ON [dbo].[PostCodeInformation]
		(
			[PostCodeNoSpaces] ASC
		) INCLUDE ([Easting], [Northing]) WITH (ONLINE = ON);;
		
		/********************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

