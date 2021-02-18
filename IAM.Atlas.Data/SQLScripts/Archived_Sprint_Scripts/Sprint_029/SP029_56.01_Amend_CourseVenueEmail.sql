/*
	SCRIPT:  Amend CourseVenueEmail Table 
	Author: Dan Hough
	Created: 30/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_56.01_Amend_CourseVenueEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend CourseVenueEmail Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseVenueEmail'
		
		/*
		 *	Create CourseVenueEmail Table
		 */
		IF OBJECT_ID('dbo.CourseVenueEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseVenueEmail;
		END

		CREATE TABLE CourseVenueEmail(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, VenueId INT NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, ScheduledEmailId INT NOT NULL
			, CourseVenueEmailReasonId INT NOT NULL
			, CONSTRAINT FK_CourseVenueEmail_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseVenueEmail_Venue FOREIGN KEY (VenueId) REFERENCES Venue(Id)
			, CONSTRAINT FK_CourseVenueEmail_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ScheduledEmail(Id)
			, CONSTRAINT FK_CourseVenueEmail_CourseVenueEmailReason FOREIGN KEY (CourseVenueEmailReasonId) REFERENCES CourseVenueEmailReason(Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;