/*
	SCRIPT: Create CourseTypeFee Table
	Author: Dan Hough
	Created: 05/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_11.01_Create_CourseTypeFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseTypeFee Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseTypeFee'
		
		/*
		 *	Create CourseTypeFee Table
		 */
		IF OBJECT_ID('dbo.CourseTypeFee', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTypeFee;
		END

		CREATE TABLE CourseTypeFee(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int
			, CourseTypeId int
			, EffectiveDate DateTime
			, CourseFee money
			, BookingSupplement money
			, PaymentDays int
			, AddedByUserId int NOT NULL
			, DateAdded DateTime
			, CONSTRAINT FK_CourseTypeFee_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_CourseTypeFee_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_CourseTypeFee_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;