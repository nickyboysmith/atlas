/*
 * SCRIPT: Update All Course Client Payment Totals
 * Author: Robert Newnham
 * Created: 16/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_29.06_UpdateAllCourseClientPaymentTotals.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update All Course Client Payment Totals';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
			UPDATE CC
			SET CC.TotalPaymentMade = T2.TotalPaymentMade
			, CC.LastPaymentMadeDate = T2.LastPaymentMadeDate
			FROM (
				SELECT DISTINCT CCP.CourseId, CCP.ClientId, SUM(P.Amount) AS TotalPaymentMade, MAX(P.TransactionDate) AS LastPaymentMadeDate
				FROM dbo.CourseClientPayment CCP
				INNER JOIN dbo.Payment P					ON P.Id = CCP.PaymentId
				GROUP BY CCP.CourseId, CCP.ClientId
				) T2
			INNER JOIN dbo.CourseClient CC		ON CC.CourseId = T2.CourseId
												AND CC.ClientId = T2.ClientId
			WHERE ISNULL(CC.TotalPaymentMade, 0) <> T2.TotalPaymentMade
			OR ISNULL(CC.LastPaymentMadeDate, 0) <> T2.LastPaymentMadeDate;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;