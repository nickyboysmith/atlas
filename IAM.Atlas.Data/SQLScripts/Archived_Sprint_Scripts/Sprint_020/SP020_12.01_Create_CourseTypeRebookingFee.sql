/*
	SCRIPT: Create CourseTypeFee Table
	Author: Dan Hough
	Created: 05/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_12.01_Create_CourseTypeRebookingFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseTypeRebookingFee Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseTypeRebookingFee'
		
		/*
		 *	Create CourseTypeRebookingFee Table
		 */
		IF OBJECT_ID('dbo.CourseTypeRebookingFee', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTypeRebookingFee;
		END

		CREATE TABLE CourseTypeRebookingFee(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int
			, CourseTypeId int
			, ConditionNumber int
			, EffectiveDate DateTime
			, RebookingFee money
			, DaysBefore int
			, [Disabled] bit DEFAULT 0
			, AddedByUserId int NOT NULL
			, DateAdded DateTime
			, DisabledByUserId int NULL
			, DateDisabled DateTime
			, CONSTRAINT FK_CourseTypeRebookingFee_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_CourseTypeRebookingFee_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_CourseTypeRebookingFee_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;