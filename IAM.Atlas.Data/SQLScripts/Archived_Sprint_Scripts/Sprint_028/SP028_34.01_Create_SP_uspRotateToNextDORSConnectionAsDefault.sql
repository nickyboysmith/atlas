/*
	SCRIPT: Create uspRotateToNextDORSConnectionAsDefault
	Author: Dan Hough
	Created: 07/11/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_34.01_Create_SP_uspRotateToNextDORSConnectionAsDefault.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspRotateToNextDORSConnectionAsDefault';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRotateToNextDORSConnectionAsDefault', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRotateToNextDORSConnectionAsDefault;
END		
GO

	/*
		Create uspRotateToNextDORSConnectionAsDefault
	*/

	CREATE PROCEDURE dbo.uspRotateToNextDORSConnectionAsDefault 
	AS
	BEGIN
		DECLARE  @dateTimeOfLastTimeAsDefault DATETIME
			   , @hoursBetweenDORSConnectionRotation INT
			   , @combinedTime DATETIME
			   , @newDORSConnectionId INT
			   , @dorsConnectionForRotationId INT;

		--Retrieve HoursBetweenDORSConnectionRotation from SystemControl
		--There should only be one row on SystemControl
		SELECT @hoursBetweenDORSConnectionRotation = HoursBetweenDORSConnectionRotation
		FROM dbo.SystemControl 
		WHERE Id = 1;

		-- If HoursBetweenDORSConnectionRotation is null or zero then update SystemControl 
		-- and @hoursBetweenDORSConnectionRotation variable
		IF (@hoursBetweenDORSConnectionRotation = 0 OR @hoursBetweenDORSConnectionRotation IS NULL)
		BEGIN
			UPDATE dbo.SystemControl
			SET HoursBetweenDORSConnectionRotation = 2
			WHERE Id = 1;

			SET @hoursBetweenDORSConnectionRotation = 2;
		END

		--Get the earliest  DateTimeOfLastTimeAsDefault from DORSConnectionForRotation
		SELECT @dateTimeOfLastTimeAsDefault = DateTimeOfLastTimeAsDefault FROM (SELECT TOP(1) DateTimeOfLastTimeAsDefault 
																				FROM dbo.DORSConnectionForRotation
																				ORDER BY DateTimeOfLastTimeAsDefault) AS DateQuery;
		
		-- add @hoursBetweenDORSConnectionRotation to @dateTimeOfLastTimeAsDefault
		SET @combinedTime = DATEADD(hour, @hoursBetweenDORSConnectionRotation, @dateTimeOfLastTimeAsDefault);

		IF (@combinedTime > GETDATE())
		BEGIN
			-- Retrieve the top 1 DateTimeOfLastTimeAsDefault when ordered in reverse
			SELECT @newDORSConnectionId = DORSConnectionId, @dorsConnectionForRotationId = Id
			FROM (SELECT TOP(1) DORSConnectionId, Id
				  FROM dbo.DORSConnectionForRotation
				  ORDER BY DateTimeOfLastTimeAsDefault DESC) AS DateQuery;
			
			-- Update DateTimeOfLastTimeAsDefault to now
			UPDATE dbo.DORSConnectionForRotation
			SET DateTimeOfLastTimeAsDefault = GETDATE()
			WHERE Id = @dorsConnectionForRotationId;

			--Update systemcontrol to use the new dors connection id
			--There should only be one row on SystemControl
			UPDATE dbo.SystemControl
			SET DefaultDORSConnectionId = @newDORSConnectionId
			WHERE Id = 1;
		END

	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP028_34.01_Create_SP_uspRotateToNextDORSConnectionAsDefault.sql';
	EXEC dbo.uspScriptCompleted @ScriptName; 
GO