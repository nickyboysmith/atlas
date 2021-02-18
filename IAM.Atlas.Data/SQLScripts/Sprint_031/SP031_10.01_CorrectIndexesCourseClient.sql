
/*
 * SCRIPT: Correct Indexes to table CourseClient.
 * Author: Robert Newnham
 * Created: 29/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP031_10.01_CorrectIndexesCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct Index to table CourseClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Remove Duplicates First
		DELETE CC
		FROM [dbo].[CourseClient] CC
		INNER JOIN (
					SELECT CourseId, ClientId, COUNT(*) AS CNT, MIN(Id) AS DTE
					FROM [dbo].[CourseClient]
					GROUP BY CourseId, ClientId
					HAVING COUNT(*) > 1
					) CCT ON CCT.CourseId = CC.CourseId
						AND CCT.ClientId = CC.ClientId
		WHERE CC.Id != CCT.DTE;

		/********************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientCourseIdClientId' 
				AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [IX_CourseClientCourseIdClientId] ON [dbo].[CourseClient];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_CourseClientCourseIdClientId' 
				AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [UX_CourseClientCourseIdClientId] ON [dbo].[CourseClient];
		END


		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_CourseClientCourseIdClientId] ON [dbo].[CourseClient]
		(
			[CourseId], [ClientId] ASC
		);
		
		/********************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

