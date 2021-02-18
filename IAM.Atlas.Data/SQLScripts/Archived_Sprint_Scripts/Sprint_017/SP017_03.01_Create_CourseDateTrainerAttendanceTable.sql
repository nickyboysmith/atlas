/*
	SCRIPT: Create CourseDateTrainerAttendance Table
	Author: Dan Hough
	Created: 04/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_03.01_Create_CourseDateTrainerAttendanceTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the CourseDateTrainerAttendance Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDateTrainerAttendance'
		
		/*
		 *	Create CourseDateTrainerAttendance Table
		 */
		IF OBJECT_ID('dbo.CourseDateTrainerAttendance', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDateTrainerAttendance;
		END

		CREATE TABLE CourseDateTrainerAttendance(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseDateId int NOT NULL
			, CourseId int NOT NULL
			, TrainerId int NOT NULL
			, CreatedByUserId int NULL
			, DateTimeAdded DateTime DEFAULT GETDATE()
			, CONSTRAINT FK_CourseDateTrainerAttendance_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDateTrainerAttendance_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_CourseDateTrainerAttendance_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseDateTrainerAttendance_CourseDate FOREIGN KEY (CourseDateId) REFERENCES CourseDate(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;