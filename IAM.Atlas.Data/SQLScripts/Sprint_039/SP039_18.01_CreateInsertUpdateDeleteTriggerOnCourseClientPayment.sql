/*
	SCRIPT: Create Insert/Update/Delete trigger TRG_CourseClientPayment_InsertUpdateDelete on table CourseClientPayment
	Author: Paul Tuck
	Created: 22/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_18.01_CreateInsertUpdateDeleteTriggerOnCourseClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend & Rename Insert Update trigger on table CourseClientPayment';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseClientPayment_InsertUpdateDelete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseClientPayment_InsertUpdateDelete;
	END
GO
	CREATE TRIGGER TRG_CourseClientPayment_InsertUpdateDelete ON dbo.CourseClientPayment AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClientPayment', 'TRG_CourseClientPayment_InsertUpdateDelete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			UPDATE CC
			SET CC.TotalPaymentMade = T2.TotalPaymentMade
			, CC.LastPaymentMadeDate = T2.LastPaymentMadeDate
			FROM (
				SELECT DISTINCT T.CourseId, T.ClientId, SUM(P.Amount) AS TotalPaymentMade, MAX(P.TransactionDate) AS LastPaymentMadeDate
				FROM (
					SELECT I.CourseId, I.ClientId
					FROM INSERTED I
					UNION SELECT D.CourseId, D.ClientId
					FROM DELETED D
					) T
				INNER JOIN dbo.CourseClientPayment CCP		ON CCP.CourseId = T.CourseId
															AND CCP.ClientId = T.ClientId
				INNER JOIN dbo.Payment P					ON P.Id = CCP.PaymentId
				GROUP BY T.CourseId, T.ClientId
				) T2
			INNER JOIN dbo.CourseClient CC		ON CC.CourseId = T2.CourseId
												AND CC.ClientId = T2.ClientId
			LEFT JOIN dbo.CourseClientRemoved CCR	ON CCR.CourseId = T2.CourseId
													AND CCR.ClientId = T2.ClientId
													AND CCR.CourseClientId = CC.Id
			WHERE 
				(ISNULL(CC.TotalPaymentMade, 0) <> T2.TotalPaymentMade
				OR ISNULL(CC.LastPaymentMadeDate, 0) <> T2.LastPaymentMadeDate)
				AND CCR.Id IS NULL;

		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_18.01_CreateInsertUpdateDeleteTriggerOnCourseClientPayment.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO