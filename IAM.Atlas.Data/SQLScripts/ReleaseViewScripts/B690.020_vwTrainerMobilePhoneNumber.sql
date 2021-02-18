
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerMobilePhoneNumber', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerMobilePhoneNumber;
		END		

		GO
		/*
			Create vwTrainerMobilePhoneNumber
		*/
		CREATE VIEW dbo.vwTrainerMobilePhoneNumber
		AS		
			SELECT 
				TP.TrainerId				AS TrainerId
				, TP.Number					AS PhoneNumber
			FROM TrainerPhone TP
			INNER JOIN PhoneType PT		ON PT.Id = TP.PhoneTypeId
			WHERE PT.[Type] = 'Mobile'
		GO
		
		/*********************************************************************************************************************/
		