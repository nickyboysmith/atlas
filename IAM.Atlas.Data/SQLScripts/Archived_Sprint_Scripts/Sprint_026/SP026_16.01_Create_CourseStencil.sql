/*
	SCRIPT: Create CourseStencil Table
	Author: Dan Hough
	Created: 12/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_16.01_Create_CourseStencil.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseStencil Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseStencil'
		
		/*
		 *	Create CourseStencil Table
		 */
		IF OBJECT_ID('dbo.CourseStencil', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseStencil;
		END

		CREATE TABLE CourseStencil(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name VARCHAR(200)
			, VersionNumber INT
			, [Disabled] BIT DEFAULT 'False'
			, MaxCourses INT
			, ExcludeBankHolidays BIT DEFAULT 'True'
			, ExcludeWeekends BIT DEFAULT 'True'
			, EarliestStartDate DATETIME
			, LastetStartDate DATETIME
			, SessionStartTime1 VARCHAR(5)
			, SessionEndTime1 VARCHAR(5)
			, SessionStartTime2 VARCHAR(5)
			, SessionEndTime2 VARCHAR(5)
			, SessionStartTime3 VARCHAR(5)
			, SessionEndTime3 VARCHAR(5)
			, MultiDayCourseDaysBetween INT
			, CourseTypeId INT
			, CourseTypeCategoryId INT NULL
			, VenueId INT
			, TrainerCost money
			, TrainersRequired INT
			, CoursePlaces INT
			, ReservedPlaces INT
			, CourseReferenceGeneratorId INT
			, BeginReferenceWith VARCHAR(20)
			, EndReferenceWith VARCHAR(20)
			, WeeklyCourses BIT DEFAULT 'False'
			, WeeklyCourseStartDay INT
			, MonthlyCourses BIT DEFAULT 'False'
			, MonthlyCoursesPreferredDayStart INT
			, DailyCourses BIT DEFAULT 'False'
			, DailCoursesSkipDays INT
			, ExcludeMonday BIT DEFAULT 'False'
			, ExcludeTuesday BIT DEFAULT 'False'
			, ExcludeWednesday BIT DEFAULT 'False'
			, ExcludeThursday BIT DEFAULT 'False'
			, ExcludeFriday BIT DEFAULT 'False'
			, ExcludeSaturday BIT DEFAULT 'False'
			, ExcludeSunday BIT DEFAULT 'False'
			, Notes VARCHAR(1000)
			, CreateCourses BIT DEFAULT 'False'
			, RemoveCourses BIT DEFAULT 'False'
			, DateCreated DATETIME
			, CreatedByUserId INT
			, DateCoursesCreated DATETIME
			, DateCoursesRemoved DATETIME
			, CONSTRAINT FK_CourseStencil_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_CourseStencil_CourseTypeCategory FOREIGN KEY (CourseTypeCategoryId) REFERENCES CourseTypeCategory(Id)
			, CONSTRAINT FK_CourseStencil_Venue FOREIGN KEY (VenueId) REFERENCES Venue(Id)
			, CONSTRAINT FK_CourseStencil_CourseReferenceGenerator FOREIGN KEY (CourseReferenceGeneratorId) REFERENCES CourseReferenceGenerator(Id)
			, CONSTRAINT FK_CourseStencil_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

