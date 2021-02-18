/*
	SCRIPT: Create CourseLocked Table 
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_30.01_Create_Table_CourseLocked.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseLocked Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseLocked'
		
		/*
		 *	Create CourseLocked Table
		 */
		IF OBJECT_ID('dbo.CourseLocked', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseLocked;
		END

		CREATE TABLE CourseLocked(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, AfterDate DateTime NOT NULL DEFAULT GETDATE()
			, Reason VARCHAR(200) NULL
			, UpdatedByUserId INT NOT NULL
			, CONSTRAINT FK_CourseLocked_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseLocked_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;