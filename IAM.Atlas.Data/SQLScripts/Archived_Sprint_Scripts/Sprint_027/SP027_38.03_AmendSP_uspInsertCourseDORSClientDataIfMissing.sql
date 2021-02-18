
/*
	SCRIPT: Amend SP to Insert CourseDORSClient Data If Missing.
	Author: Robert Newnham
	Created: 18/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_38.03_AmendSP_uspInsertCourseDORSClientDataIfMissing.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SP to Insert CourseDORSClient Data If Missing.';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspInsertCourseDORSClientDataIfMissing', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspInsertCourseDORSClientDataIfMissing;
END		
GO

	/*
		Create uspCheckUser
	*/
	CREATE PROCEDURE uspInsertCourseDORSClientDataIfMissing
	(	
		@courseId int
		, @clientId int
	)
	AS
	BEGIN
			INSERT INTO [dbo].[CourseDORSClient] (
						CourseId
						, ClientId
						, DateAdded
						, DORSNotified
						, DateDORSNotified
						, DORSAttendanceRef
						, DORSAttendanceStateIdentifier
						, NumberOfDORSNotificationAttempts
						, DateDORSNotificationAttempted
						, PaidInFull
						, OnlyPartPaymentMade
						, DatePaidInFull
						)
			SELECT 
				CO.Id			AS CourseId
				, CL.Id			AS ClientId
				, GetDate()		AS DateAdded
				, 'False'		AS DORSNotified
				, NULL			AS DateDORSNotified
				, CDD.[DORSAttendanceRef]										AS DORSAttendanceRef
				, dbo.udfGetDORSAttendanceStateIdentifier('Booking Pending')	AS DORSAttendanceStateIdentifier
				, 0				AS NumberOfDORSNotificationAttempts
				, NULL			AS DateDORSNotificationAttempted
				, 'False'		AS PaidInFull
				, 'False'		AS OnlyPartPaymentMade
				, NULL			AS DatePaidInFull
			FROM [dbo].[Course] CO
			INNER JOIN [dbo].[Client] CL ON CL.Id = @clientId
			LEFT JOIN [dbo].[ClientDORSData] CDD ON CDD.ClientId = CL.Id
			LEFT JOIN [dbo].[CourseDORSClient] CDC ON CDC.CourseId = CO.Id
													AND CDC.ClientId = CL.Id
			WHERE CO.Id = @courseId
			AND CO.DORSCourse = 'True' --Only if it is a DORS Course will data be inserted
			AND CDC.Id IS NULL -- Not Already on Table
			;
	END
	GO
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP027_38.03_AmendSP_uspInsertCourseDORSClientDataIfMissing.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


