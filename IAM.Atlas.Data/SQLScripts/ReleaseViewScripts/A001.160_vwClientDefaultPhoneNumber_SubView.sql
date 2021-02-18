
		
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwClientDefaultPhoneNumber', 'V') IS NOT NULL
		BEGIN
			--Previous Name of the View
			DROP VIEW dbo.vwClientDefaultPhoneNumber;
		END		
		GO
		IF OBJECT_ID('dbo.vwClientDefaultPhoneNumber_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientDefaultPhoneNumber_SubView;
		END		
		GO

		/*
			Create View vwClientDefaultPhoneNumber
			NB. This view is used within view "vwCourseDetail"

			!!!!!!!!!!!!!NOT REALLY NEEDED SO NOT RECREATED!!!!!!!!!!
		*/
		--CREATE VIEW dbo.vwClientDefaultPhoneNumber_SubView
		--AS		
		--	SELECT ClientId
		--			, PhoneNumber
		--	FROM ClientPhone
		--	WHERE DefaultNumber = 1;
		--GO

		
		/*********************************************************************************************************************/
		