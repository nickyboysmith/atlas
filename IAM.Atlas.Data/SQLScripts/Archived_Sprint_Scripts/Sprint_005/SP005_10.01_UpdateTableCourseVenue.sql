

/*
	SCRIPT: Update Table CourseVenue Rename Column "CourseVenueId" to "VenueId"
	Author: Robert Newnham
	Created: 13/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP005_10.01_UpdateTableCourseVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
				
		/*
			DROP FOREIGN KEY CONSTRAINT
		*/
		IF EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseVenue_Venue')
		   AND parent_object_id = OBJECT_ID(N'dbo.CourseVenue')
		)
		BEGIN
			ALTER TABLE CourseVenue DROP CONSTRAINT [FK_CourseVenue_Venue]
		END
		
		/*
			Update Table CourseVenue Rename Column "CourseVenueId" to "VenueId"
		*/
		IF OBJECT_ID('dbo.CourseVenue', 'U') IS NOT NULL
		BEGIN
			IF EXISTS(select * from sys.columns 
				WHERE Name = N'CourseVenueId' and Object_ID = Object_ID(N'CourseVenue'))
			BEGIN
				EXEC sp_rename 'dbo.CourseVenue.CourseVenueId', 'VenueId', 'COLUMN';
			END
		END
		
		/*
			Update Table CourseVenue Add the Foreign Key Back
		*/
		ALTER TABLE dbo.CourseVenue
		ADD CONSTRAINT FK_CourseVenue_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

