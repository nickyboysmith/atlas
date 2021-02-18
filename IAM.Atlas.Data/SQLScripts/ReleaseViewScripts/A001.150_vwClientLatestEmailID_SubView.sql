
		
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwClientLatestEmailID', 'V') IS NOT NULL
		BEGIN
			--Previous Name of the View
			DROP VIEW dbo.vwClientLatestEmailID;
		END		
		GO
		IF OBJECT_ID('dbo.vwClientLatestEmailID_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientLatestEmailID_SubView;
		END		
		GO

		/*
			Create View vwClientLatestEmailID_SubView
			NB. This view is used within view "vwCourseDetail"
		*/
		CREATE VIEW dbo.vwClientLatestEmailID_SubView
		AS		
			SELECT MAX(EmailId) as EmailId, ClientId
			FROM ClientEmail
			Group By ClientId;
		GO
		
		/*********************************************************************************************************************/
		