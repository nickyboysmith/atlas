/*
	SCRIPT: Create CourseTypeTolerance Table
	Author: Robert Newnham
	Created: 14/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_19.01_Create_CourseTypeToleranceTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseTypeTolerance Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseTypeTolerance'
		
		/*
		 *	Create CourseTypeTolerance Table
		 */
		IF OBJECT_ID('dbo.CourseTypeTolerance', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTypeTolerance;
		END

		CREATE TABLE CourseTypeTolerance(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseTypeId int NOT NULL
			, Notes VARCHAR(400)
			, FirstRatio INT
			, SecondRatio INT
			, MaximumAttendees INT
			, Tolerance INT
			, EffectiveDate DATE DEFAULT GetDate()
			, UpdatedByUserId INT
			, DateUpdated DATE DEFAULT GetDate()
			, CONSTRAINT FK_CourseTypeTolerance_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_CourseTypeTolerance_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

