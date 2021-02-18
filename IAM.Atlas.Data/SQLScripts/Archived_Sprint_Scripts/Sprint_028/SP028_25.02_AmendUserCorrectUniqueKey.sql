/*
 * SCRIPT: Alter Table User Correct UniqueKey
	Author: Robert Newnham
	Created: 30/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_25.02_AmendUserCorrectUniqueKey.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table User Correct UniqueKey';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		--A Uniquer Constraint has been created for table User with the column Login.
		-- The Constraint is not Specifically Named
		-- So we have to find all and remove them then Recreate the Constraint with a Specific Name
		DECLARE @ConstraintNameToRemove VARCHAR(400);
		DECLARE @SQLCommand  VARCHAR(1000);
		DECLARE @MaxCount INT = 0;

		SELECT TOP 1 @ConstraintNameToRemove=TC.CONSTRAINT_NAME
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU ON CCU.TABLE_SCHEMA = TC.TABLE_SCHEMA
																	AND CCU.TABLE_NAME = TC.TABLE_NAME
		WHERE TC.TABLE_NAME = 'User'
		AND TC.CONSTRAINT_TYPE = 'UNIQUE'
		AND CCU.COLUMN_NAME = 'LoginId';

		WHILE (@ConstraintNameToRemove IS NOT NULL)
		BEGIN
			SET @MaxCount = @MaxCount + 1;
			SET @SQLCommand = 'ALTER TABLE dbo.[User] DROP CONSTRAINT ' + @ConstraintNameToRemove;

			PRINT ('Executing: "' + @SQLCommand + '"')
			EXECUTE (@SQLCommand)
			SET @ConstraintNameToRemove = NULL;

			SELECT TOP 1 @ConstraintNameToRemove=TC.CONSTRAINT_NAME
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU ON CCU.TABLE_SCHEMA = TC.TABLE_SCHEMA
																		AND CCU.TABLE_NAME = TC.TABLE_NAME
			WHERE TC.TABLE_NAME = 'User'
			AND TC.CONSTRAINT_TYPE = 'UNIQUE'
			AND CCU.COLUMN_NAME = 'LoginId';
		END
		
		CREATE UNIQUE INDEX UX_User_LoginId
		ON dbo.[User] (LoginId);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
