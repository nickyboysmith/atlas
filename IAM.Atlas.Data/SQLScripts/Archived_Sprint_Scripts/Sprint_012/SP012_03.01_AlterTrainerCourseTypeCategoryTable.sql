/*
	SCRIPT: Alter Trainer Course Type Category Add New Columns
	Author: Miles Stewart
	Created: 09/12/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP012_03.01_AlterTrainerCourseTypeCategoryTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to the Trainer Course Type Category';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.TrainerCourseTypeCategory
		ADD [Disabled] bit,
			DisabledByUserId int,
			DisabledDate DateTime,
			CONSTRAINT FK_TrainerCourseTypeCategory_User FOREIGN KEY (DisabledByUserId) REFERENCES [User](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

