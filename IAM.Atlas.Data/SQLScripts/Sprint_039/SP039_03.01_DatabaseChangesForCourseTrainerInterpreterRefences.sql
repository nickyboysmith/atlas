/*
	SCRIPT: DatabasChanges For Course Trainer Interpreter Refences
	Author: Robert Newnham
	Created: 11/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_03.01_DatabaseChangesForCourseTrainerInterpreterRefences.sql';
DECLARE @ScriptComments VARCHAR(800) = 'DatabasChanges For Course Trainer Interpreter Refences';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration 
		ADD
			TrainersHaveCourseReference BIT NOT NULL DEFAULT 'False'
			, InterpretersHaveCourseReference BIT NOT NULL DEFAULT 'False'
			;
		/************************************************************************************************************************/

		ALTER TABLE dbo.CourseTrainer ADD
			Reference VARCHAR(80) NULL
			, PaymentDue MONEY
			, DateUpdated DATETIME NULL
			, UpdatedByUserId INT NULL
			, CONSTRAINT FK_CourseTrainer_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			;
		/************************************************************************************************************************/
			
		ALTER TABLE dbo.CourseInterpreter ADD
			Reference VARCHAR(80) NULL
			, PaymentDue MONEY
			, DateUpdated DATETIME NULL
			, UpdatedByUserId INT NULL
			, CONSTRAINT FK_CourseInterpreter_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			;
		/************************************************************************************************************************/


		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'UniqueCourseTrainerInterpreterReferenceNumber'
		
		/*
		 *	Create ClientEncryption Table
		 */
		IF OBJECT_ID('dbo.UniqueCourseTrainerInterpreterReferenceNumber', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UniqueCourseTrainerInterpreterReferenceNumber;
		END

		CREATE TABLE UniqueCourseTrainerInterpreterReferenceNumber(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, RefeneceNumber INT NOT NULL
			);
		/************************************************************************************************************************/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationTrainerSetting'
		
		/*
		 *	Create ClientEncryption Table
		 */
		IF OBJECT_ID('dbo.OrganisationTrainerSetting', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationTrainerSetting;
		END

		CREATE TABLE OrganisationTrainerSetting(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, AutoGenerateTrainerCourseReference BIT NOT NULL DEFAULT 'True'
			, LetAtlasSystemGenerateUniqueNumber BIT NOT NULL DEFAULT 'True'
			, ReferencesStartWithCourseTypeCode BIT NOT NULL DEFAULT 'False'
			, StartAllReferencesWith VARCHAR(20) NULL
			, ReferenceEditable BIT NOT NULL DEFAULT 'False'
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL
			, DateUpdated DATETIME NULL
			, UpdatedByUserId INT NULL
			, CONSTRAINT FK_OrganisationTrainerSetting_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationTrainerSetting_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_OrganisationTrainerSetting_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			);
		/************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationInterpreterSetting'
		
		/*
		 *	Create ClientEncryption Table
		 */
		IF OBJECT_ID('dbo.OrganisationInterpreterSetting', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationInterpreterSetting;
		END

		CREATE TABLE OrganisationInterpreterSetting(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, AutoGenerateInterpreterCourseReference BIT NOT NULL DEFAULT 'True'
			, LetAtlasSystemGenerateUniqueNumber BIT NOT NULL DEFAULT 'True'
			, ReferencesStartWithCourseTypeCode BIT NOT NULL DEFAULT 'False'
			, StartAllReferencesWith VARCHAR(20) NULL
			, ReferenceEditable BIT NOT NULL DEFAULT 'False'
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL
			, DateUpdated DATETIME NULL
			, UpdatedByUserId INT NULL
			, CONSTRAINT FK_OrganisationInterpreterSetting_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationInterpreterSetting_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_OrganisationInterpreterSetting_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			);
		/************************************************************************************************************************/
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END