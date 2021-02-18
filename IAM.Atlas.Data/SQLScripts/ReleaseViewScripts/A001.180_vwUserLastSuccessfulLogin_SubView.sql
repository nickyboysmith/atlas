
		--vwUserLastSuccessfulLogin_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwUserLastSuccessfulLogin_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwUserLastSuccessfulLogin_SubView;
		END		
		GO
		/*
			Create vwUserLastSuccessfulLogin_SubView
			NB. This view is used within view "vwUserDetail" 
		*/
		CREATE VIEW vwUserLastSuccessfulLogin_SubView 
		AS
			SELECT DISTINCT
				U.Id					AS UserId
				, U.LoginId				AS LoginId
				, MAX(UL.DateCreated)	AS LastSuccessfulLogin
			FROM [dbo].[User] U
			LEFT JOIN [dbo].[UserLogin] UL ON UL.LoginId = U.LoginId
											AND UL.Success = 'True' 
			GROUP BY U.Id, U.LoginId
			;
		GO
		/*********************************************************************************************************************/
