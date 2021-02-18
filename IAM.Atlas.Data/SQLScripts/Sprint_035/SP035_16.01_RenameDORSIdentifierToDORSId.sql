/*
	SCRIPT: Rename Missnamed Column
	Author: Robert Newnham
	Created: 23/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_16.01_RenameDORSIdentifierToDORSId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Missnamed Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/


		-- DORSSite
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSSiteIdentifier' 
						AND Object_ID = Object_ID(N'DORSSiteVenue')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSSiteVenue.DORSSiteIdentifier', N'DORSSiteId', 'COLUMN' 
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;