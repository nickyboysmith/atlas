/*
	SCRIPT: ReCreate DORSAttendanceState Table
	Author: Robert Newnham
	Created: 07/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.02_ReCreate_DORSAttendanceState_PutDataBack.sql';
DECLARE @ScriptComments VARCHAR(800) = 'ReCreate DORSAttendanceState Table - PutDataBack';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF OBJECT_ID('tempdb..#DORSAttendanceState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #DORSAttendanceState;
		END

		DECLARE @DAS_SysUserId int;
		SELECT @DAS_SysUserId=Id FROM [User] WHERE Name = 'Atlas System';

		/* NB. The DORS Attendance State (Status) Id is set by DORS. The table should not have "Identity" set against the Id Column. */

		SELECT *
		INTO #DORSAttendanceState
		FROM (
			SELECT 
				2 AS [DORSAttendanceStateIdentifier]
				, 'Booked' AS [Name]
				, 'Booked' AS [Description]
				, @DAS_SysUserId AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT 
				3 AS [DORSAttendanceStateIdentifier]
				, 'Booked and Paid' AS [Name]
				, 'Booked and Paid' AS [Description]
				, @DAS_SysUserId AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT 
				4 AS [DORSAttendanceStateIdentifier]
				, 'Attended and Completed' AS [Name]
				, 'Attended and Completed' AS [Description]
				, @DAS_SysUserId AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT 
				5 AS [DORSAttendanceStateIdentifier]
				, 'Attended and Not Completed' AS [Name]
				, 'Attended and Not Completed' AS [Description]
				, @DAS_SysUserId AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT 
				6 AS [DORSAttendanceStateIdentifier]
				, 'Did Not Attend' AS [Name]
				, 'Did Not Attend' AS [Description]
				, @DAS_SysUserId AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			) T
		;

		--Insert if Not Already There
		INSERT INTO dbo.DORSAttendanceState ( 
								[DORSAttendanceStateIdentifier]
								, [Name]
								, [Description]
								, [UpdatedByUserId]
								, [DateUpdated]
								)
		SELECT 
			TDAS.[DORSAttendanceStateIdentifier]
			, TDAS.[Name]
			, TDAS.[Description]
			, TDAS.[UpdatedByUserId]
			, TDAS.[DateUpdated]
		FROM #DORSAttendanceState TDAS
		LEFT JOIN dbo.DORSAttendanceState DAS ON DAS.[DORSAttendanceStateIdentifier] = TDAS.[DORSAttendanceStateIdentifier]
		WHERE DAS.Id IS NULL;

		--Update if Changed
		UPDATE DAS
		SET DAS.[Name] = TDAS.[Name]
		, DAS.[Description] = TDAS.[Description]
		, DAS.[UpdatedByUserId] = @DAS_SysUserId
		, DAS.[DateUpdated] = Getdate()
		FROM dbo.DORSAttendanceState DAS
		INNER JOIN #DORSAttendanceState TDAS ON TDAS.[DORSAttendanceStateIdentifier] = DAS.[DORSAttendanceStateIdentifier]
		WHERE DAS.[Name] <> TDAS.[Name]
		OR DAS.[Description] <> TDAS.[Description];
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;