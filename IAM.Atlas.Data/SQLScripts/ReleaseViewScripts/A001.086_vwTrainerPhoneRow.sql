
		--All Trainer Phone Numbers in One Row
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerPhoneRow', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerPhoneRow;
		END		
		GO
		/*
			Create vwTrainerPhoneRow
		*/
		CREATE VIEW vwTrainerPhoneRow 
		AS		
			SELECT
				TP.Id
				, TP.TrainerId								AS TrainerId
				, TP.Number									AS TrainerMainPhoneNumber
				, PT.Id										AS TrainerMainPhoneTypeId
				, PT.Type									AS TrainerMainPhoneType
				, (CASE WHEN TP3B.Id = TP.Id
						THEN NULL
						ELSE TP3B.TrainerSecondPhoneNumber
						END)								AS TrainerSecondPhoneNumber
				, (CASE WHEN TP3B.Id = TP.Id
						THEN NULL
						ELSE TP3B.TrainerSecondPhoneTypeId
						END)								AS TrainerSecondPhoneTypeId
				, (CASE WHEN TP3B.Id = TP.Id
						THEN NULL
						ELSE TP3B.TrainerSecondPhoneType
						END)								AS TrainerSecondPhoneType
			FROM TrainerPhone TP
			INNER JOIN PhoneType PT ON PT.Id = TP.PhoneTypeId
			INNER JOIN (SELECT TP2.TrainerId, MIN(TP2.Id) AS Id
						FROM TrainerPhone TP2
						GROUP BY TP2.TrainerId
						) TP2A ON TP2A.TrainerId = TP.TrainerId
								AND TP2A.Id = TP.Id
			LEFT JOIN ( --Use The Last One Entered as the Second Number
						SELECT
							TPO.Id
							, TPO.TrainerId			AS TrainerId
							, TPO.Number			AS TrainerSecondPhoneNumber
							, PTO.Id				AS TrainerSecondPhoneTypeId
							, PTO.Type				AS TrainerSecondPhoneType
						FROM TrainerPhone TPO
						INNER JOIN PhoneType PTO ON PTO.Id = TPO.PhoneTypeId
						INNER JOIN (SELECT TP3.TrainerId, MAX(TP3.Id) AS Id
									FROM TrainerPhone TP3
									GROUP BY TP3.TrainerId
									) TP3A ON TP3A.TrainerId = TPO.TrainerId
											AND TP3A.Id = TPO.Id
						) TP3B ON TP3B.TrainerId = TP.TrainerId
			;

		GO
		/*********************************************************************************************************************/




		/*		
					SELECT DISTINCT
						CP5.ClientId					AS ClientId
						, STUFF(
									(
									SELECT '; ' + CP_O.PhoneNumber
									FROM ClientPhone CP_O
									LEFT JOIN (SELECT CP_O2.ClientId, MIN(CP_O2.Id) AS Id
												FROM ClientPhone CP_O2
												WHERE CP_O2.DefaultNumber = 'False'
												GROUP BY CP_O2.ClientId) CP_O2B ON CP_O2B.Id = CP_O.Id
									WHERE CP_O2B.Id IS NULL
									AND CP_O.ClientId = CP5.ClientId
									AND CP_O.DefaultNumber = 'False'
									FOR XML PATH('')
									)
									, 1, 1, '') AS ClientOtherPhoneNumbers
					FROM ClientPhone CP5
					LEFT JOIN (SELECT CP6.ClientId, MIN(CP6.Id) AS Id
								FROM ClientPhone CP6
								WHERE CP6.DefaultNumber = 'False'
								GROUP BY CP6.ClientId) CP6B ON CP6B.Id = CP5.Id
					WHERE CP6B.Id IS NULL
					AND CP5.DefaultNumber = 'False'*/