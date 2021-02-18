/*
	SCRIPT: Rename DORS Id's to Identifier
	Author: Nick Smith
	Created: 11/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_29.01_Rename DORS Ids to Identifier.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename DORS Id''s to Identifier';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/

		-- DORSCourse
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSCourseId' and Object_ID = Object_ID(N'DORSCourse')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSCourse.DORSCourseId', N'DORSCourseIdentifier', 'COLUMN' 
		END

		-- DORSCourseData
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSCourseId' and Object_ID = Object_ID(N'DORSCourseData')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSCourseData.DORSCourseId', N'DORSCourseIdentifier', 'COLUMN' 
		END

		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'ForceContractId' and Object_ID = Object_ID(N'DORSCourseData')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSCourseData.ForceContractId', N'DORSForceContractIdentifier', 'COLUMN' 
		END

		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'SiteId' and Object_ID = Object_ID(N'DORSCourseData')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSCourseData.SiteId', N'DORSSiteIdentifier', 'COLUMN' 
		END

		-- DORSForce
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSForceId' and Object_ID = Object_ID(N'DORSForce')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSForce.DORSForceId', N'DORSForceIdentifier', 'COLUMN' 
		END

		-- DORSForceContract
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'ForceContractID' and Object_ID = Object_ID(N'DORSForceContract')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSForceContract.ForceContractID', N'DORSForceContractIdentifier', 'COLUMN' 
		END

		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'ForceID' and Object_ID = Object_ID(N'DORSForceContract')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSForceContract.ForceID', N'DORSForceIdentifier', 'COLUMN' 
		END

		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'SchemeID' and Object_ID = Object_ID(N'DORSForceContract')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSForceContract.SchemeID', N'DORSSchemeIdentifier', 'COLUMN' 
		END

		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'AccreditationID' and Object_ID = Object_ID(N'DORSForceContract')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSForceContract.AccreditationID', N'DORSAccreditationIdentifier', 'COLUMN' 
		END
	
		-- DORSLicenceCheckCompleted
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSAttendanceRef' and Object_ID = Object_ID(N'DORSLicenceCheckCompleted')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSLicenceCheckCompleted.DORSAttendanceRef', N'DORSAttendanceIdentifier', 'COLUMN' 
		END

		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'SessionId' and Object_ID = Object_ID(N'DORSLicenceCheckCompleted')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSLicenceCheckCompleted.SessionId', N'DORSSessionIdentifier', 'COLUMN' 
		END
	
		-- DORSSite
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSSiteId' and Object_ID = Object_ID(N'DORSSite')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSSite.DORSSiteId', N'DORSSiteIdentifier', 'COLUMN' 
		END

		-- DORSSiteVenue
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSSiteId' and Object_ID = Object_ID(N'DORSSiteVenue')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSSiteVenue.DORSSiteId', N'DORSSiteIdentifier', 'COLUMN' 
		END

		-- DORSTrainerScheme
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'DORSSchemeId' and Object_ID = Object_ID(N'DORSTrainerScheme')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.DORSTrainerScheme.DORSSchemeId', N'DORSSchemeIdentifier', 'COLUMN' 
		END


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;