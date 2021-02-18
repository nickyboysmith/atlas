

/*
	Data Migration Script :- Migrate Net Call Data.
	Script Name: Migration_150.001_MigrateNetcallData.sql
	Author: Robert Newnham
	Created: 03/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

*/

/*
	Old Tables Data Migrated So Far
	[tbl_LU_LicenceType] ---------> [DriverLicenceType]
*/


/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_150.001_MigrateNetcallData.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	PRINT('');PRINT('*Migrate Net Call Data Tables ' + CAST(GETDATE() AS VARCHAR));
	--*Setup Temp Columns for previous Ids
	BEGIN
		PRINT('');PRINT('*Setup Temp Columns for previous Ids ' + CAST(GETDATE() AS VARCHAR));
		-- Add a Temp Column to the Client Table. This will be removed further down this Script
		BEGIN
			ALTER TABLE dbo.NetcallRequest
			ADD TempFieldPreviousNetcallRequestId int NULL;
		END
	END
	GO


	--*Get System User Ids
	BEGIN
		PRINT('');PRINT('*Get System User Ids ' + CAST(GETDATE() AS VARCHAR));
		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';
	END

	BEGIN		
		--INSERT INTO NetcallRequest Table
		PRINT('');PRINT('-INSERT INTO NetcallRequest Table');
		INSERT INTO [dbo].[NetcallRequest] (
			TempFieldPreviousNetcallRequestId
			, [Date]
			, Method
			, InSessionIdentifier
			, InRequestIdentifier
			, InRequestDateTime
			, InCallingNumber
			, InAppContext
			, InClientIdentifier
			, InDateOfBirth
			, InAuthorisationReference
			, InAuthorisationCode
			, OutResponseDate
			, OutResult
			, OutResultDescription
			, OutClientIdentifier
			, OutPaymentAmountInPence
			, OutSurchargeToApplyInPence
			, OutTotalPaymentAmountInPence
			, OutCourseVenue
			, OutTransactionReference
			)
		SELECT 
			[ncr_id] AS TempFieldPreviousNetcallRequestId
			, [ncr_date] AS [Date]
			, [ncr_Method] AS Method
			, [ncr_in_SessionID] AS InSessionIdentifier
			, [ncr_in_RequestID] AS InRequestIdentifier
			, (CASE WHEN [ncr_in_RequestTime] IS NULL
					THEN NULL
					WHEN ISDATE([ncr_in_RequestTime]) = 1
					THEN CAST([ncr_in_RequestTime] AS DATETIME)
					ELSE CONVERT(DATETIME, [ncr_in_RequestTime], 103)
					END
					) AS InRequestDateTime
			, [ncr_in_CallingNumber] AS InCallingNumber
			, [ncr_in_AppContext] AS InAppContext
			, [ncr_in_ClientID] AS InClientIdentifier
			, [ncr_in_DOB] AS InDateOfBirth
			, [ncr_in_AuthReference] AS InAuthorisationReference
			, NULL AS InAuthorisationCode
			, [ncr_out_ResponseDate] AS OutResponseDate
			, [ncr_out_Result] AS OutResult
			, [ncr_out_ResultDescription] AS OutResultDescription
			, [ncr_out_ClientID] AS OutClientIdentifier
			, [ncr_out_AmountToPay] AS OutPaymentAmountInPence
			, NULL AS OutSurchargeToApplyInPence
			, [ncr_out_AmountToPay] AS OutTotalPaymentAmountInPence
			, [ncr_out_CourseVenue] AS OutCourseVenue
			, [ncr_out_ShopperReference] AS OutTransactionReference
		FROM [migration].[tbl_Netcall_Request] OldNR
		LEFT JOIN [dbo].[NetcallRequestPreviousId] NRPI ON NRPI.[PreviousNetcallRequestId] = OldNR.[ncr_id]
		WHERE NRPI.Id IS NULL; /* IE NOT INSERTED YET */
	END
	
	BEGIN		
		--UPDATE [NetcallRequestPreviousId] Table
		PRINT('');PRINT('-UPDATE [NetcallRequestPreviousId] Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[NetcallRequestPreviousId] (PreviousNetcallRequestId, NetcallRequestId)
		SELECT TempFieldPreviousNetcallRequestId AS PreviousNetcallRequestId
			, NR.Id AS NetcallRequestId
		FROM [dbo].[NetcallRequest] NR
		LEFT JOIN [dbo].[NetcallRequestPreviousId] NRPI ON NRPI.[PreviousNetcallRequestId] = NR.TempFieldPreviousNetcallRequestId
		WHERE NR.TempFieldPreviousNetcallRequestId IS NOT NULL
		AND NRPI.Id IS NULL; /* IE NOT INSERTED YET */
	END
	
	BEGIN		
		--UPDATE [NetcallErrorLog] Table
		PRINT('');PRINT('-UPDATE [NetcallErrorLog] Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[NetcallErrorLog] (
			RequestDate
			, Request
			, ErrorMessage
			, WarningMessageSentToSupport
			, DateWarningMessageSent
			)
		SELECT 
			OldNL.[RequestDate] AS RequestDate
			, OldNL.[Request]  AS Request
			, OldNL.[ErrorMessage] AS ErrorMessage
			, 'True' AS WarningMessageSentToSupport
			, OldNL.[RequestDate] AS DateWarningMessageSent
		--FROM [migration].[tbl_NetcallLog] OldNL
		--LEFT JOIN [dbo].[NetcallErrorLog] NEL ON NEL.RequestDate = OldNL.RequestDate
		--										AND CAST(NEL.Request AS VARCHAR(990)) = CAST(OldNL.Request AS VARCHAR(990))
		--										AND CAST(NEL.ErrorMessage AS VARCHAR(990)) = CAST(OldNL.ErrorMessage AS VARCHAR(990))
		--WHERE NEL.Id IS NULL; /* IE NOT INSERTED YET */
		FROM (SELECT [RequestDate] AS RequestDate, CAST([Request] AS VARCHAR(990))  AS Request, CAST([ErrorMessage] AS VARCHAR(990)) AS ErrorMessage
			FROM [migration].[tbl_NetcallLog]) OldNL
		LEFT JOIN (SELECT Id, RequestDate, CAST(Request AS VARCHAR(990)) AS Request, CAST(ErrorMessage AS VARCHAR(990)) AS ErrorMessage
					FROM [dbo].[NetcallErrorLog]) NEL ON NEL.RequestDate = OldNL.RequestDate
														AND NEL.Request = OldNL.Request
														AND NEL.ErrorMessage = OldNL.ErrorMessage
		WHERE NEL.Id IS NULL; /* IE NOT INSERTED YET */
		--NB. Had to use the above sub queries as SQL has issues with large columns?????
	END
	
	BEGIN		
		--UPDATE [NetcallAgent] Table
		PRINT('');PRINT('-UPDATE [NetcallAgent] Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[NetcallAgent] (
			UserId
			, DefaultCallingNumber
			, [Disabled]
			, DateUpdated
			, UpdateByUserId
			)
		SELECT 
			UPI.UserId AS UserId
			, OldU.[usr_agent_ext] AS DefaultCallingNumber
			, 'False' AS [Disabled]
			, GetDate() AS DateUpdated
			, @MigrationUserId AS UpdateByUserId
		FROM [migration].[tbl_Users] OldU
		INNER JOIN [dbo].[UserPreviousId] UPI ON UPI.PreviousUserId = OldU.[usr_ID]
		LEFT JOIN [dbo].[NetcallAgent] NA ON NA.UserId = UPI.UserId
		WHERE LEN(ISNULL(OldU.[usr_agent_ext],'')) > 0
		AND NA.Id IS NULL; /* IE NOT INSERTED YET */
	END
	
	
	BEGIN
		DECLARE @nowt int;

	END



	BEGIN
	
		PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR));
		--IF OBJECT_ID('tempdb..#Organisation', 'U') IS NOT NULL
		--BEGIN
		--	DROP TABLE #Organisation;
		--END

	END
	GO

	PRINT('');PRINT('*Tidy Up Temp Columns ' + CAST(GETDATE() AS VARCHAR));
	-- Remove the Temp Column on the Course Table
	BEGIN
		ALTER TABLE dbo.NetcallRequest
		DROP COLUMN TempFieldPreviousNetcallRequestId;
	END
	GO
	

	
PRINT('');PRINT('**Completed Script: "Migration_150.001_MigrateNetcallData.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/