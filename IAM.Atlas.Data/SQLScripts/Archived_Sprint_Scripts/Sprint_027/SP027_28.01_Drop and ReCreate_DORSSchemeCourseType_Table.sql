/*
	SCRIPT: ReCreate DORSSchemeCourseType Table
	Author: Nick Smith
	Created: 11/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_28.01_Drop and ReCreate_DORSSchemeCourseType_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'ReCreate the DORSSchemeCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/

		/*
		 *	Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'DORSSchemeCourseType'
		
		/*
		 *	Create DDORSSchemeCourseType  Table
		 */
		IF OBJECT_ID('dbo.DORSSchemeCourseType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSSchemeCourseType;
		END

		CREATE TABLE DORSSchemeCourseType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseTypeId INT NOT NULL
		    , DORSSchemeId INT NOT NULL
			, DateCreated DATETIME
			, CONSTRAINT FK_DORSSchemeCourseType_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_DORSSchemeCourseType_DORSScheme FOREIGN KEY (DORSSchemeId) REFERENCES DORSScheme(Id)
		);



		ALTER TABLE [dbo].[DORSSchemeCourseType] ADD CONSTRAINT DF_DORSSchemeCourseType_DateCreated DEFAULT (GETDATE()) FOR [DateCreated]


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;