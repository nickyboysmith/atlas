
		--Create dbo.vwClientPhoneNumbers_SubView
		-- NB. This view is used within view "vwCourseClientWithSMSRemindersDue"
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientPhoneNumbers_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientPhoneNumbers_SubView;
		END		

		GO

		--NO LONGER REQUIRED
		/*
			Create vwClientPhoneNumbers_SubView
		*/
		--CREATE VIEW dbo.vwClientPhoneNumbers_SubView
		--AS		
		--	SELECT 
		--		ClientId
		--		, PhoneNumber
		--		, 1 AS TopPhone
		--	FROM ClientPhone
		--	WHERE DefaultNumber = 'True'

		--GO
		
		/*********************************************************************************************************************/
		