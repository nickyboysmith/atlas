/*
 * SCRIPT: Alter Column Default on Table Venue
 * Author: Robert Newnham
 * Created: 15/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_25.01_AmendTableVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Column Default on Table Venue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF EXISTS(SELECT * FROM information_schema.columns 
				   WHERE table_name='Venue' AND column_name='DORSVenue' 
					 AND Table_schema='dbo' AND column_default IS NOT NULL) 
		BEGIN 
			DECLARE @ConstraintName NVARCHAR(100), @SQL NVARCHAR(200);
			SELECT @ConstraintName = OBJECT_NAME([default_object_id]) FROM SYS.COLUMNS
			WHERE [object_id] = OBJECT_ID('[dbo].[Venue]') AND [name] = 'DORSVenue';

			SET @SQL = 'ALTER TABLE [dbo].[Venue] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql  @SQL

		END

		ALTER TABLE Venue ADD CONSTRAINT DF_Venue_DORSVenue DEFAULT 'True' FOR DORSVenue;
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


