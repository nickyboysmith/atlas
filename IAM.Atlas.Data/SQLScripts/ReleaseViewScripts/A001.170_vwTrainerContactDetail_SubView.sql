
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTraineContactDetail_SubView', 'V') IS NOT NULL
		BEGIN
			--Remove Incorrectly Named View
			DROP VIEW dbo.vwTraineContactDetail_SubView;
		END		
		GO
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTrainerContactDetail_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerContactDetail_SubView;
		END		
		GO

		/*
			Create View vwTrainerContactDetail_SubView
		*/
		CREATE VIEW vwTrainerContactDetail_SubView 
		AS	
			SELECT
				T.Id					AS TrainerId
				, T.DisplayName			AS TrainerName
				, (SELECT TOP 1 TP.Number
					FROM [dbo].[TrainerPhone] TP
					INNER JOIN [dbo].[PhoneType] PT ON PT.Id = TP.PhoneTypeId
					WHERE TP.TrainerId = T.Id
					AND PT.[Type] = 'Mobile'
					)					AS TrainerMobileNumber
				, (SELECT TOP 1 TP.Number
					FROM [dbo].[TrainerPhone] TP
					INNER JOIN [dbo].[PhoneType] PT ON PT.Id = TP.PhoneTypeId
					WHERE TP.TrainerId = T.Id
					AND PT.[Type] = 'Home'
					)					AS TrainerHomeNumber
				, (SELECT TOP 1 TP.Number
					FROM [dbo].[TrainerPhone] TP
					INNER JOIN [dbo].[PhoneType] PT ON PT.Id = TP.PhoneTypeId
					WHERE TP.TrainerId = T.Id
					AND PT.[Type] = 'Work'
					)					AS TrainerWorkNumber
				, (SELECT TOP 1 E.[Address] AS EmailAddress
					FROM [dbo].[TrainerEmail] TE
					INNER JOIN [dbo].[Email] E ON E.Id = TE.EmailId
					WHERE TE.TrainerId = T.Id
					AND TE.MainEmail = 'True'
					)					AS TrainerEmail
			FROM [dbo].[Trainer] T
			;
		GO
			/*****************************************************************************************************************/
		