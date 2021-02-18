/*
	SCRIPT: Create CourseCloneRequest Table
	Author: Dan Hough
	Created: 03/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_05.01_Create_CourseCloneRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseCloneRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseCloneRequest'
		
		/*
		 *	Create CourseCloneRequest Table
		 */
		IF OBJECT_ID('dbo.CourseCloneRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseCloneRequest;
		END

		CREATE TABLE CourseCloneRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT
			, CourseId INT 
			, CourseTypeId INT
			, CourseTypeCategoryId INT
			, RequestedByUserId INT
			, DateRequested DATETIME
			, StartDate DATETIME
			, EndDate DATETIME
			, CourseReferenceGeneratorId INT
			, UseSameReference BIT DEFAULT 'False'
			, UseSameTrainers BIT DEFAULT 'False'
			, MaxCourses INT
			, WeeklyCourses BIT DEFAULT 'False'
			, MonthlyCourses BIT DEFAULT 'False'
			, EveryNWeeks INT
			, EveryNMonths INT
			, NewCoursesCreated BIT DEFAULT 'False'
			, DateNewCoursesCreated DATETIME
			, ClonedCoursesRemoved BIT DEFAULT'False'
			, CONSTRAINT FK_CourseCloneRequest_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_CourseCloneRequest_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_CourseCloneRequest_CourseTypeCategory FOREIGN KEY (CourseTypeCategoryId) REFERENCES CourseTypeCategory(Id)
			, CONSTRAINT FK_CourseCloneRequest_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseCloneRequest_CourseReferenceGenerator FOREIGN KEY (CourseReferenceGeneratorId) REFERENCES CourseReferenceGenerator(Id)
		);
		
		CREATE NONCLUSTERED INDEX [IX_CourseCloneRequestCourseId] ON [dbo].[CourseCloneRequest]
		(
			[CourseId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;