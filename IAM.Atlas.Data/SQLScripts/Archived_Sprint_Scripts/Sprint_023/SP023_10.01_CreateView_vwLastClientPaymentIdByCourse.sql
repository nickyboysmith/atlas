
/*
	SCRIPT: Create a view to find the last client payment Id by course
	Author: Dan Hough
	Created: 12/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_10.01_CreateView_vwLastClientPaymentIdByCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to find the last client payment Id by course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwLastClientPaymentIdByCourse', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwLastClientPaymentIdByCourse;
	END		
	GO

	/*
		Create View vwLastClientPaymentIdByCourse
	*/
	CREATE VIEW dbo.vwLastClientPaymentIdByCourse AS	
		
		SELECT MAX(PaymentId) as LastPaymentId, ClientId, CourseId
		FROM CourseClientPayment 
		GROUP BY ClientId, CourseId

GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_10.01_CreateView_vwLastClientPaymentIdByCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
