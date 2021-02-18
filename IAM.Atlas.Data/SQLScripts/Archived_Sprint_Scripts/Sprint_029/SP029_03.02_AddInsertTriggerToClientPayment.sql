/*
	SCRIPT: Add Insert Trigger on the ClientPayment table
	Author: Robert Newnham
	Created: 14/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_03.02_AddInsertTriggerToClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert Trigger on the ClientPayment table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ClientPayment_Insert]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_ClientPayment_Insert];
	END
GO
	CREATE TRIGGER TRG_ClientPayment_Insert ON dbo.ClientPayment AFTER INSERT, UPDATE
	AS
	BEGIN
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
	END;
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_03.02_AddInsertTriggerToClientPayment.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO