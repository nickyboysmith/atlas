/*
	This script recompiles Stored Procedures and Functions
	This script should be run every release.

	Date Created: 24/02/2016 By Dan Hough

*/

DECLARE @ScriptName VARCHAR(100) = 'RecompileStoredProceduresAndFunctions.sql';
DECLARE @ScriptComments VARCHAR(800) = 'This script recompiles Stored Procedures and Functions';


/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
	
	DECLARE proccurs CURSOR
	FOR
		SELECT [name]
		  FROM sysobjects
		 WHERE xtype in ('p', 'fn')

	OPEN proccurs
	DECLARE @pname VARCHAR(800)

	FETCH NEXT FROM proccurs INTO @pname
	WHILE @@fetch_status = 0
	BEGIN
		BEGIN TRY
			EXEC sp_recompile @pname
		END TRY
		BEGIN CATCH
			PRINT 'Validation failed for : ' + 
					@pname + ', Error:' + 
					ERROR_MESSAGE();
		END CATCH

		FETCH NEXT FROM proccurs INTO @pname
	END
	CLOSE proccurs
	DEALLOCATE proccurs

EXEC dbo.uspScriptCompleted @ScriptName; 
GO