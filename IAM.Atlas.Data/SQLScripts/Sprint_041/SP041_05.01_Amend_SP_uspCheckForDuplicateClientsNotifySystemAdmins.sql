/*
	SCRIPT: Amend Stored procedure uspCheckForDuplicateClientsNotifySystemAdmins
	Author: Robert Newnham
	Created: 23/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_05.01_Amend_SP_uspCheckForDuplicateClientsNotifySystemAdmins.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored procedure uspCheckForDuplicateClientsNotifySystemAdmins';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCheckForDuplicateClientsNotifySystemAdmins', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspCheckForDuplicateClientsNotifySystemAdmins];
END		
GO
	/*
		Create [uspCheckForDuplicateClientsNotifySystemAdmins]
	*/
	
	CREATE PROCEDURE [dbo].[uspCheckForDuplicateClientsNotifySystemAdmins]
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspCheckForDuplicateClientsNotifySystemAdmins'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;			
		/*****************************************************************************************************************************/			
		BEGIN TRY
			IF EXISTS(SELECT * 
						FROM dbo.SystemControl 
						WHERE Id =1 AND MonitorForDuplicateClients = 'True'
						) BEGIN

				DECLARE @clientId INT;
				DECLARE @licenceNumber VARCHAR(40);
				DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
				DECLARE @CurrentSystem VARCHAR(20);
				SELECT TOP 1 @CurrentSystem=AtlasSystemName FROM dbo.SystemControl WHERE Id = 1;
				DECLARE @Subject VARCHAR(100) = @CurrentSystem + ' - Duplicate Client Information';
	
				DECLARE duplicateClients CURSOR FOR  
					SELECT CLL2.ClientId, CLL2.[LicenceNumber]
					FROM (
						SELECT CLL.[LicenceNumber], COUNT(DISTINCT CLL.ClientId) CNT
						FROM Client CL
						INNER JOIN dbo.ClientLicence CLL ON CLL.ClientId = CL.Id
						LEFT JOIN dbo.ClientMarkedForDelete CLMD ON CLMD.ClientId = CL.Id
						LEFT JOIN dbo.ClientMarkedForDeleteCancelled CLMDC ON CLMD.ClientId = CL.Id
						WHERE CAST(CL.DateCreated AS DATE) >= CAST(DATEADD(DAY, -7, GETDATE()) AS DATE)
						AND LEN(ISNULL(CLL.[LicenceNumber],'')) > 0
						AND (CLMD.Id IS NULL OR (CLMD.Id IS NOT NULL AND CLMDC.Id IS NULL)) --Client Deleted
						GROUP BY CLL.[LicenceNumber]
						HAVING COUNT(DISTINCT CLL.ClientId) > 1
						) T
					INNER JOIN dbo.ClientLicence CLL2 ON CLL2.[LicenceNumber] = T.[LicenceNumber]
					ORDER BY CLL2.[LicenceNumber]
					;
				OPEN duplicateClients
			   
				DECLARE @thisLicNum VARCHAR(40) = '';
				DECLARE @content VARCHAR(4000) = 'Reporting on System: ' + @CurrentSystem + @NewLine;

				FETCH NEXT FROM duplicateClients INTO @clientId, @licenceNumber;

				WHILE @@FETCH_STATUS = 0   
				BEGIN
					IF (@thisLicNum = @licenceNumber) BEGIN
						SELECT 
							@content = @content
										+ @NewLine + '-------------------------------------------------------'
										+ @NewLine + 'AND'
										+ @NewLine + '  Client Id: ' + CAST(CL.Id AS VARCHAR)
										+ @NewLine + '  Client Name: ' + CL.DisplayName
										+ @NewLine + '  Date Client Created: ' + (CASE WHEN CL.DateCreated IS NULL THEN ''
																				ELSE CAST(CL.DateCreated AS VARCHAR) END)
										+ @NewLine + '  Client DOB: ' + (CASE WHEN CL.DateOfBirth IS NULL THEN ''
																		ELSE CAST(CL.DateOfBirth AS VARCHAR) END)
										+ @NewLine + '  Client Login Id: ' + (CASE WHEN U.LoginId IS NULL THEN '*NONE CREATED*'
																					ELSE U.LoginId + ' ('
																						+ (CASE WHEN U.LastLoginAttempt IS NULL THEN '*NEVER LOGGED IN*'
																								ELSE CAST(U.LastLoginAttempt AS VARCHAR)
																								END)
																						+ ')'
																					END)
										+ @NewLine + '  Client Licence: ' + @licenceNumber
										+ @NewLine + '  Client Payment Made: ' + CAST(SUM(ISNULL(P.Amount,0)) AS VARCHAR)
										+ @NewLine + '  Booked ON Course: ' + (CASE WHEN CO.Id IS NULL THEN '*NONE*'
																				ELSE 'Course Id: "' + CAST(CO.Id AS VARCHAR) + '"'
																					+ ' .... Ref: "' + CO.Reference + '"'
																					+ ' .... Type: "' + COTY.Title + '"'
																				END)
										+ (CASE WHEN COCLR.Id IS NULL THEN ''
												ELSE @NewLine + '  *Removed From Course Above"'
												END)

						FROM dbo.Client CL
						LEFT JOIN dbo.ClientPayment CLP ON CLP.ClientId = CL.Id
						LEFT JOIN dbo.Payment P ON P.Id = CLP.PaymentId
						LEFT JOIN dbo.CourseClient COCL ON COCL.ClientId = CL.Id
						LEFT JOIN dbo.Course CO ON CO.Id = COCL.CourseId
						LEFT JOIN dbo.CourseType COTY ON COTY.Id = CO.CourseTypeId
						LEFT JOIN dbo.CourseClientRemoved COCLR ON COCLR.CourseClientId = COCL.Id
						LEFT JOIN dbo.[User] U ON U.Id = CL.UserId
						WHERE CL.Id = @clientId
						GROUP BY CL.Id, CL.DisplayName, CL.DateCreated, CL.DateOfBirth, CO.Id, CO.Reference, COTY.Title, COCLR.Id, U.LoginId, U.LastLoginAttempt
						;
					END
					ELSE BEGIN
						IF (LEN(@content) > 60) BEGIN
							SET @content = @content
										+ @NewLine + '-------------------------------------------------------'
							INSERT INTO SendSystemAdminsEmail (RequestedByUserId, SubjectText, ContentText)
							VALUES (dbo.udfGetSystemUserId(), @Subject, @content);
							SET @content = 'Reporting on System: ' + @CurrentSystem + @NewLine;
						END
						SELECT 
							@content = 'Duplicate Client Information Appears on the Database as follows:'
										+ @NewLine
										+ @NewLine + '  Client Id: ' + CAST(CL.Id AS VARCHAR)
										+ @NewLine + '  Client Name: ' + CL.DisplayName
										+ @NewLine + '  Date Client Created: ' + (CASE WHEN CL.DateCreated IS NULL THEN ''
																				ELSE CAST(CL.DateCreated AS VARCHAR) END)
										+ @NewLine + '  Client DOB: ' + (CASE WHEN CL.DateOfBirth IS NULL THEN ''
																		ELSE CAST(CL.DateOfBirth AS VARCHAR) END)
										+ @NewLine + '  Client Login Id: ' + (CASE WHEN U.LoginId IS NULL THEN '*NONE CREATED*'
																					ELSE U.LoginId + ' ('
																						+ (CASE WHEN U.LastLoginAttempt IS NULL THEN '*NEVER LOGGED IN*'
																								ELSE CAST(U.LastLoginAttempt AS VARCHAR)
																								END)
																						+ ')'
																					END)
										+ @NewLine + '  Client Licence: ' + @licenceNumber
										+ @NewLine + '  Client Payment Made: ' + CAST(SUM(ISNULL(P.Amount,0)) AS VARCHAR)
										+ @NewLine + '  Booked ON Course: ' + (CASE WHEN CO.Id IS NULL THEN '*NONE*'
																				ELSE 'Course Id: "' + CAST(CO.Id AS VARCHAR) + '"'
																					+ ' .... Ref: "' + CO.Reference + '"'
																					+ ' .... Type: "' + COTY.Title + '"'
																				END)
										+ (CASE WHEN COCLR.Id IS NULL THEN ''
												ELSE @NewLine + '  *Removed From Course Above"'
												END)

						FROM dbo.Client CL
						LEFT JOIN dbo.ClientPayment CLP ON CLP.ClientId = CL.Id
						LEFT JOIN dbo.Payment P ON P.Id = CLP.PaymentId
						LEFT JOIN dbo.CourseClient COCL ON COCL.ClientId = CL.Id
						LEFT JOIN dbo.Course CO ON CO.Id = COCL.CourseId
						LEFT JOIN dbo.CourseType COTY ON COTY.Id = CO.CourseTypeId
						LEFT JOIN dbo.CourseClientRemoved COCLR ON COCLR.CourseClientId = COCL.Id
						LEFT JOIN dbo.[User] U ON U.Id = CL.UserId
						WHERE CL.Id = @clientId
						GROUP BY CL.Id, CL.DisplayName, CL.DateCreated, CL.DateOfBirth, CO.Id, CO.Reference, COTY.Title, COCLR.Id, U.LoginId, U.LastLoginAttempt
						;

					END
					SET @thisLicNum = @licenceNumber;

					FETCH NEXT FROM duplicateClients INTO @clientId, @licenceNumber;
				END   

				CLOSE duplicateClients   
				DEALLOCATE duplicateClients
			
				SET @content = @content
							+ @NewLine + '-------------------------------------------------------'
				INSERT INTO SendSystemAdminsEmail (RequestedByUserId, SubjectText, ContentText)
				VALUES (dbo.udfGetSystemUserId(), @Subject, @content);

			END	--IF EXISTS(SELECT * 		
		END TRY  
		BEGIN CATCH  
			SELECT 
				@ErrorNumber = ERROR_NUMBER()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE()
				, @ErrorProcedure = ERROR_PROCEDURE()
				, @ErrorLine = ERROR_LINE()
				, @ErrorMessage = ERROR_MESSAGE()
				;

			EXECUTE uspSaveDatabaseError @ProcedureName
										, @ErrorMessage
										, @ErrorNumber
										, @ErrorSeverity
										, @ErrorState
										, @ErrorProcedure
										, @ErrorLine
										;
		END CATCH
	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP041_05.01_Amend_SP_uspCheckForDuplicateClientsNotifySystemAdmins.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
