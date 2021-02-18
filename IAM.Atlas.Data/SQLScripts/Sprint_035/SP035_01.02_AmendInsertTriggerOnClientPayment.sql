/*
	SCRIPT: Amend Insert trigger on ClientPayment
	Author: Robert Newnham
	Created: 16/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_01.02_AmendInsertTriggerOnClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on ClientPayment';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientPayment_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientPayment_Insert;
	END
GO
IF OBJECT_ID('dbo.TRG_ClientPayment_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientPayment_INSERT;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientPayment_INSERT] ON [dbo].[ClientPayment] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientPayment', 'TRG_ClientPayment_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			/****************************************************************************************************************/
			
			BEGIN TRY
				INSERT INTO [dbo].[OrganisationPayment] (OrganisationId, PaymentId)
				SELECT DISTINCT
					CO.OrganisationId		AS OrganisationId
					, I.PaymentId			AS PaymentId
				FROM INSERTED I
				INNER JOIN [dbo].[ClientOrganisation] CO ON CO.ClientId = I.ClientId
				LEFT JOIN [dbo].[OrganisationPayment] OP ON OP.PaymentId = I.PaymentId
				WHERE OP.Id IS NULL; --Only Insert if Not Already on the Table
			END TRY
			BEGIN CATCH
				--SET @errMessage = '*Error Inserting Into OrganisationPayment Table';
				/*
					We Don't Need to do anything with This at the moment 
					If It is a Duplicate then it should not hapen anyway.
					This May already have been inserted into via Payment Trigger.
				*/
			END CATCH
			/****************************************************************************************************************/

			INSERT INTO [dbo].[ClientChangeLog] (
				ClientId
				, ChangeType
				, ColumnName
				, PreviousValue
				, NewValue
				, Comment
				, DateCreated
				, AssociatedUserId
				)
			SELECT 
				I.Id									AS ClientId
				, 'Payment'								AS ChangeType
				, 'Name'								AS ColumnName
				, ''									AS PreviousValue
				, CONVERT(VARCHAR(30), P.[Amount], 1)	AS NewValue
				, (CASE WHEN ISNULL(P.Refund, 'False') = 'True'
						THEN 'A Client Payment has been recorded for £' 
							+ CONVERT(VARCHAR(30), P.[Amount], 1)
						ELSE 'A Client Refund has been recorded for £' 
							+ CONVERT(VARCHAR(30), (P.[Amount] * -1), 1)
						END)							AS Comment
				, GETDATE()								AS DateCreated
				, I.AddedByUserId						AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN dbo.Payment P ON P.Id = I.PaymentId
			;
			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_01.02_AmendInsertTriggerOnClientPayment.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO