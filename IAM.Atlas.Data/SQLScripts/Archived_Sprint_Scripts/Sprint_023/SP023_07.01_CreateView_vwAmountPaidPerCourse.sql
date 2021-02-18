
/*
	SCRIPT: Create a view to find the amount paid for each course
	Author: Dan Hough
	Created: 11/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_07.01_CreateView_vwAmountPaidPerCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to find the amount paid for each course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwAmountPaidPerCourse', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwAmountPaidPerCourse;
	END		
	GO

	/*
		Create View vwAmountPaidPerCourse
	*/
	CREATE VIEW dbo.vwAmountPaidPerCourse AS	
	
		SELECT ccp.CourseId
			 , SUM(p.Amount) AS PaidSum
		FROM dbo.CourseClientPayment ccp INNER JOIN
		dbo.Payment p ON ccp.PaymentId = p.Id
		GROUP BY CourseId

GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_07.01_CreateView_vwAmountPaidPerCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
