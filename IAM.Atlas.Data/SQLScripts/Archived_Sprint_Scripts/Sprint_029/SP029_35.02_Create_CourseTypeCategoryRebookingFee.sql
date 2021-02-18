/*
	SCRIPT: Create CourseTypeCategoryRebookingFee Table
	Author: Robert Newnham
	Created: 24/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_35.02_Create_CourseTypeCategoryRebookingFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseTypeCategoryRebookingFee Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseTypeCategoryRebookingFee'
		
		/*
		 *	Create CourseTypeCategoryRebookingFee Table
		 */
		IF OBJECT_ID('dbo.CourseTypeCategoryRebookingFee', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTypeCategoryRebookingFee;
		END

		CREATE TABLE CourseTypeCategoryRebookingFee(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int
			, CourseTypeId int
			, CourseTypeCategoryId int
			, ConditionNumber int
			, EffectiveDate DateTime
			, RebookingFee money
			, DaysBefore int
			, AddedByUserId int NOT NULL
			, DateAdded DateTime
			, [Disabled] bit NOT NULL DEFAULT 'False'
			, DisabledByUserId int NULL
			, DateDisabled DateTime
			, CONSTRAINT FK_CourseTypeCategoryRebookingFee_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_CourseTypeCategoryRebookingFee_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_CourseTypeCategoryRebookingFee_CourseTypeCategory FOREIGN KEY (CourseTypeCategoryId) REFERENCES CourseTypeCategory(Id)
			, CONSTRAINT FK_CourseTypeCategoryRebookingFee_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseTypeCategoryRebookingFee_User2 FOREIGN KEY (DisabledByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;