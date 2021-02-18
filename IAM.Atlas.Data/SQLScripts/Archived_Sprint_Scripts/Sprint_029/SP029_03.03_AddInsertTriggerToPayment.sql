/*
	SCRIPT: Add Insert Trigger on the Payment table
	Author: Robert Newnham
	Created: 14/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_03.03_AddInsertTriggerToPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert Trigger on the Payment table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Payment_INSERTUPDATE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Payment_INSERTUPDATE];
	END
GO
	CREATE TRIGGER TRG_Payment_INSERTUPDATE ON dbo.Payment AFTER INSERT, UPDATE
	AS
	BEGIN
		BEGIN TRY
			SELECT DISTINCT
				(CASE WHEN OPT.OrganisationId IS NOT NULL THEN OPT.OrganisationId
					WHEN PM.OrganisationId IS NOT NULL THEN PM.OrganisationId
					WHEN OU.OrganisationId IS NOT NULL AND SAU.Id IS NULL THEN OU.OrganisationId
					ELSE NULL END)		AS OrganisationId
				, I.Id					AS PaymentId
			INTO #OrganisationPayment
			FROM INSERTED I
			LEFT JOIN [dbo].[OrganisationPaymentType] OPT		ON OPT.PaymentTypeId = I.PaymentTypeId	--Find Organisation By Payment Type
			LEFT JOIN [dbo].[PaymentMethod] PM					ON PM.Id = I.PaymentMethodId -- In Case No Payment Type Use Payment Method to Get Organisation
			LEFT JOIN [dbo].[OrganisationUser] OU				ON OU.UserId = I.CreatedByUserId -- If No Payment Method The Use the User Id
			LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = I.CreatedByUserId -- DO Not Allow User Organisation if a System Administration User Id is Used
			LEFT JOIN [dbo].[OrganisationPayment] OP			ON OP.PaymentId = I.Id
			WHERE OP.Id IS NULL; --Only Insert if Not Already on the Table
			/*
				NB. There is a Chance here that a Payment Created by a System Administrator will not get assigned to an Organisation.
					There is a Trigger in the Table ClientPayment that will pick it up there.
			*/
			INSERT INTO [dbo].[OrganisationPayment] (OrganisationId, PaymentId)
			SELECT DISTINCT
				OP.OrganisationId		AS OrganisationId
				, OP.PaymentId			AS PaymentId
			FROM #OrganisationPayment OP
			INNER JOIN Organisation O		ON O.Id = OP.OrganisationId -- Only Valid Organisations. Will Exclude NULLS too
			LEFT JOIN [dbo].[OrganisationPayment] OP			ON OP.PaymentId = I.Id
			WHERE OP.OrganisationId IS NOT NULL
			AND OP.Id IS NULL; --Only Insert if Not Already on the Table
			;
		END TRY
		BEGIN CATCH
			--SET @errMessage = '*Error Inserting Into OrganisationPayment Table';
			/*
				We Don't Need to do anything with This at the moment 
				If It is a Duplicate then it should not hapen anyway.
			*/
		END CATCH
	END;
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_03.03_AddInsertTriggerToPayment.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO