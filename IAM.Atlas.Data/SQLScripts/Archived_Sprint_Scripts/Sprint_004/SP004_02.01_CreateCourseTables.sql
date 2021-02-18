/*
	SCRIPT: Create Organisation Extension Tables
	Author: Miles Stewart
	Created: 27/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_02.01_CreateCourseTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the releated Course Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'VenueEmail'
		EXEC dbo.uspDropTableContraints 'CourseVenue'
		EXEC dbo.uspDropTableContraints 'CourseNote'
		EXEC dbo.uspDropTableContraints 'CourseDates'
		EXEC dbo.uspDropTableContraints 'CourseTimes'		
		EXEC dbo.uspDropTableContraints 'Course'
		EXEC dbo.uspDropTableContraints 'VenueCourseType'		
		EXEC dbo.uspDropTableContraints 'CourseType'
		EXEC dbo.uspDropTableContraints 'VenueAddress'
		EXEC dbo.uspDropTableContraints 'VenueDirections'
		EXEC dbo.uspDropTableContraints 'VenueCost'
		EXEC dbo.uspDropTableContraints 'Venue'




		/*
		 *	Create Venue Table
		 */
		IF OBJECT_ID('dbo.Venue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Venue;
		END

		CREATE TABLE Venue(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(250)
			, [Description] varchar(250)
			, Notes varchar(4000)
			, Prefix varchar(50)
			, OrganisationId int NOT NULL
			, CONSTRAINT FK_Venue_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		

		/*
		 *	Create VenueAddress Table
		 */
		IF OBJECT_ID('dbo.VenueAddress', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueAddress;
		END
		
		CREATE TABLE VenueAddress (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int NOT NULL
			, LocationId int NOT NULL
			, CONSTRAINT FK_VenueAddress_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
			, CONSTRAINT FK_VenueAddress_Location FOREIGN KEY (LocationId) REFERENCES [Location](Id)
		);
		
		/*
		 *	Create VenueDirections Table
		 */
		IF OBJECT_ID('dbo.VenueDirections', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueDirections;
		END
		
		CREATE TABLE VenueDirections (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int NOT NULL
			, Directions varchar(1000)
			, CONSTRAINT FK_VenueDirections_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
		);
		
		/*
		 * Create VenueCostType Table
		 */
		IF OBJECT_ID('dbo.VenueCostType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueCostType;
		END
		
		CREATE TABLE VenueCostType (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(200)
		);
		
		/*
		 * Insert Values for Venue Cost type
		 */
		IF OBJECT_ID('dbo.VenueCostType', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.VenueCostType(Name)
			SELECT DISTINCT T.Name
			FROM (
					SELECT 'Weekday' AS Name
					UNION SELECT 'Weekend' AS Name
				) T
			LEFT JOIN dbo.VenueCostType VCT ON VCT.Name = T.Name
			WHERE VCT.Name IS NULL;
		END
		
		/*
		 * Create VenueCost Table
		 */
		IF OBJECT_ID('dbo.VenueCost', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueCost;
		END
		
		CREATE TABLE VenueCost (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int NOT NULL
			, CostTypeId int NOT NULL
			, Cost Money NOT NULL
			, ValidFromDate DateTime
			, ValidToDate DateTime
			, CONSTRAINT FK_VenueCost_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
			, CONSTRAINT FK_VenueCost_VenueCostType FOREIGN KEY (CostTypeId) REFERENCES [VenueCostType](Id)
		);
		
		
		/*
		 * Create CourseType Table
		 */
		IF OBJECT_ID('dbo.CourseType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseType;
		END
		
		CREATE TABLE CourseType (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(250)
			, Code varchar(250)
			, [Description] varchar(250)
			, OrganisationId int NOT NULL
			, CONSTRAINT FK_CourseType_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		
		/*
		 *
		 */
		IF OBJECT_ID('dbo.VenueCourseType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueCourseType;
		END 
		
		CREATE TABLE VenueCourseType (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int NOT NULL
			, CourseTypeId int NOT NULL
			, CONSTRAINT FK_VenueCourseType_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
			, CONSTRAINT FK_VenueCourseType_CourseType FOREIGN KEY (CourseTypeId) REFERENCES [CourseType](Id)
		);		
		
			
		/*
		 * Venue Email Table
		 */
		IF OBJECT_ID('dbo.VenueEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueEmail;
		END 
		
		CREATE TABLE VenueEmail (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EmailId int NOT NULL
			, MainEmail bit
			, CONSTRAINT FK_VenueEmail_Email FOREIGN KEY (EmailId) REFERENCES [Email](Id)
		);		
		
		/*
		 * Course Table
		 */
		IF OBJECT_ID('dbo.Course', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Course;
		END 
		
		CREATE TABLE Course (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseTypeId int NOT NULL
			, DefaultStartTime DateTime
			, DefaultEndTime DateTime
			, Available bit
			, OrganisationId int NOT NULL
			, CONSTRAINT FK_Course_CourseType FOREIGN KEY (CourseTypeId) REFERENCES [CourseType](Id)
			, CONSTRAINT FK_Course_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);		
				
		/*
		 * Course Dates Table
		 */
		IF OBJECT_ID('dbo.CourseDates', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDates;
		END 
		
		CREATE TABLE CourseDates (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, DateStart DateTime
			, DateEnd DateTime
			, Available bit
			, CONSTRAINT FK_CourseDates_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
		);	
		
						
		/*
		 * Course Times
		 */
		IF OBJECT_ID('dbo.CourseTimes', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTimes;
		END 
		
		CREATE TABLE CourseTimes (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, [Date] Date
			, StartTime Time
			, EndTime Time
			, CONSTRAINT FK_CourseTimes_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
		);	
	
							
		/*
		 * Course Note Types
		 */
		IF OBJECT_ID('dbo.CourseNoteType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseNoteType;
		END 
		
		CREATE TABLE CourseNoteType (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(250)
		);	
		
		/*
		 * Insert Values for Venue Cost type
		 */
		IF OBJECT_ID('dbo.CourseNoteType', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.CourseNoteType(Title)
			SELECT DISTINCT T.Title
			FROM (
					SELECT 'Register' AS Title
					UNION SELECT 'Instructor' AS Title
					UNION SELECT 'General' AS Title
				) T
			LEFT JOIN dbo.CourseNoteType CNT ON CNT.Title = T.Title
			WHERE CNT.Title IS NULL;
		END
		
		/*
		 * Course Note Types
		 */
		IF OBJECT_ID('dbo.CourseNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseNote;
		END 
		
		CREATE TABLE CourseNote (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, CourseNoteTypeId int NOT NULL
			, Note varchar (1000)
			, DateCreated DateTime
			, CreatedByUserId int NOT NULL
			, Removed bit
			, CONSTRAINT FK_CourseNote_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseNote_CourseNoteType FOREIGN KEY (CourseNoteTypeId) REFERENCES [CourseNoteType](Id)
			, CONSTRAINT FK_CourseNote_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		
				
		/*
		 * Course Note Types
		 */
		IF OBJECT_ID('dbo.CourseVenue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseVenue;
		END 
		
		CREATE TABLE CourseVenue (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, CourseVenueId int NOT NULL
			, MaximumPlaces int NOT NULL
			, CONSTRAINT FK_CourseVenue_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseVenue_Venue FOREIGN KEY (CourseVenueId) REFERENCES [Venue](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;