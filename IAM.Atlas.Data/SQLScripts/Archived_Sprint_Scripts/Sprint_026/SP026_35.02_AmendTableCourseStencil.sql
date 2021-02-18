/*
	SCRIPT: Alter CourseStencil Table
	Author: John_Cocklin
	Created: 27/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_35.02_AmendTableCourseStencil';
DECLARE @ScriptComments VARCHAR(800) = 'Amend CourseStencil Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseStencil ADD
			DateUpdated DATETIME NULL,
			UpdatedByUserId INT NULL,
			CourseCreationInitiatedByUserId INT NULL,
			DateCourseCreationInitiated DATETIME NULL,
			CourseRemoveInitialByUserId INT NULL,
			DateCourseRemoveInitiated DATETIME NULL
		

		ALTER TABLE dbo.CourseStencil ADD CONSTRAINT
			FK_CourseStencil_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES dbo.[User] (Id)
		
		
		ALTER TABLE dbo.CourseStencil ADD CONSTRAINT
			FK_CourseStencil_CourseCreationInitiatedByUserId FOREIGN KEY (CourseCreationInitiatedByUserId) REFERENCES dbo.[User] (Id)
		

		ALTER TABLE dbo.CourseStencil ADD CONSTRAINT
			FK_CourseStencil_CourseRemoveInitialByUserId FOREIGN KEY (CourseRemoveInitialByUserId) REFERENCES dbo.[User] (Id)
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

