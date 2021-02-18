
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 24/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_05.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSClientCourseAttendanceDORSForceIdentifier' 
				AND object_id = OBJECT_ID('DORSClientCourseAttendance'))
		BEGIN
		   DROP INDEX [IX_DORSClientCourseAttendanceDORSForceIdentifier] ON [dbo].[DORSClientCourseAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSClientCourseAttendanceDORSForceIdentifier] ON [dbo].[DORSClientCourseAttendance]
		(
			[DORSForceIdentifier] ASC
		) INCLUDE ([ClientId]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DocumentOwnerOrganisationIdDocumentId' 
				AND object_id = OBJECT_ID('DocumentOwner'))
		BEGIN
		   DROP INDEX [IX_DocumentOwnerOrganisationIdDocumentId] ON [dbo].[DocumentOwner];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DocumentOwnerOrganisationIdDocumentId] ON [dbo].[DocumentOwner]
		(
			[OrganisationId], [DocumentId] ASC
		) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseAvailableOrganisationId' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseAvailableOrganisationId] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseAvailableOrganisationId] ON [dbo].[Course]
		(
			[Available], [OrganisationId] ASC
		) INCLUDE ([CourseTypeCategoryId], [CourseTypeId], [DORSCourse], [HasInterpreter], [LastBookingDate], [Reference]) WITH (ONLINE = ON) ;
		/************************************************************************************/


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

