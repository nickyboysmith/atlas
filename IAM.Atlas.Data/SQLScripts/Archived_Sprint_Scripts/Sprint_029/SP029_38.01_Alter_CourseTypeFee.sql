/*
 * SCRIPT: Add columns to CourseTypeFee
 * Author: Dan Hough
 * Created: 25/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_38.01_Alter_CourseTypeFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to CourseTypeFee';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseTypeFee
		ADD [Disabled] BIT NOT NULL DEFAULT 'False'
			, DisabledByUserId INT NULL
			, DateDisabled DATETIME NULL
			, CONSTRAINT FK_CourseTypeFeeDisabledByUserId_User FOREIGN KEY (DisabledByUserId) REFERENCES [User](Id) 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
