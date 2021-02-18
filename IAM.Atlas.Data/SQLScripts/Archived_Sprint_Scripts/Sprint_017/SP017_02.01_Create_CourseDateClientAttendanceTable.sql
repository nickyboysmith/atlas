/*
	SCRIPT: Create CourseDateClientAttendance Table
	Author: Dan Hough
	Created: 04/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_02.01_Create_CourseDateClientAttendanceTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the CourseDateClientAttendance Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDateClientAttendance'
		
		/*
		 *	Create CourseDateClientAttendance Table
		 */
		IF OBJECT_ID('dbo.CourseDateClientAttendance', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDateClientAttendance;
		END

		CREATE TABLE CourseDateClientAttendance(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseDateId int NOT NULL
			, CourseId int NOT NULL
			, ClientId int NOT NULL
			, CreatedByUserId int NULL
			, DateTimeAdded DateTime DEFAULT GETDATE()
			, CONSTRAINT FK_CourseDateClientAttendance_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDateClientAttendance_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_CourseDateClientAttendance_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseDateClientAttendance_CourseDate FOREIGN KEY (CourseDateId) REFERENCES CourseDate(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;