
/*
	SCRIPT: Create a view to find the clients within a course
	Author: Dan Murray
	Created: 15/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_15.02_AmendView_vwClientsWithinCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to find the clients within a course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwClientsWithinCourse', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientsWithinCourse;
		END		
		GO
		/*
			Create vwClientsWithinCourse
		*/
		CREATE VIEW vwClientsWithinCourse AS
		
					SELECT c.Id					AS CourseId 
						 , c.OrganisationId		AS OrganisationId
						 , cd.DateStart			AS CourseStartDate
						 , ct.Title				AS CourseType
						 , ctc.Name				AS CourseTypeCategory
						 , c.Reference			AS CourseReference
						 , cl.Id				AS ClientId
						 , cl.DisplayName		AS ClientName
						 , cl.DateOfBirth		AS ClientDateOfBirth
						 , cc.DateAdded			AS DateClientAdded
						 , u.Name			    AS ClientAddedByUser
						 , ct.DORSOnly			AS DORSCourse
						 , p.TransactionDate    AS ClientLastPaymentDate
						 , p.Amount             AS ClientLastPaymentAmount
						 , vwappc.PaidSum       AS TotalAmountPaid
					     , CASE 
								WHEN vwappc.PaidSum IS NOT NULL
									THEN cc.TotalPaymentDue - vwappc.PaidSum
								ELSE cc.TotalPaymentDue
							END AS AmountOutstanding

					FROM  CourseClient cc
						  JOIN Course c
							  ON cc.CourseId = c.Id	
						  JOIN Client cl
							  ON cl.Id = cc.ClientId					  
						  LEFT JOIN CourseDate cd
							  ON cd.CourseId = c.id
						  LEFT JOIN CourseType ct
							  ON ct.Id = c.CourseTypeId
						  LEFT JOIN CourseTypeCategory ctc						
						      ON ctc.Id = c.CourseTypeCategoryId
						  LEFT JOIN [User] u
							  ON u.Id = cc.AddedByUserId
						  LEFT JOIN vwAmountPaidPerCourse vwappc
							  ON cc.CourseId = vwappc.CourseId
						  LEFT JOIN vwLastClientPaymentIdByCourse vwclcpibc
							  ON cc.ClientId = vwclcpibc.ClientId AND cc.CourseId = vwclcpibc.CourseId
						  LEFT JOIN Payment p
							  ON vwclcpibc.LastPaymentId = p.Id
																
		GO	

GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_15.02_AmendView_vwClientsWithinCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
