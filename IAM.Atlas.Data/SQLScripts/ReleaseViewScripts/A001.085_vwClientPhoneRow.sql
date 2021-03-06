
		--All Client Phone Numbers in One Row
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientPhoneRow', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientPhoneRow;
		END		
		GO
		/*
			Create vwClientPhoneRow
		*/
		CREATE VIEW vwClientPhoneRow 
		AS		
			SELECT 
				CP.ClientId						AS ClientId
				, CP.PhoneNumber				AS ClientMainPhoneNumber
				, CP.PhoneTypeId				AS ClientMainPhoneTypeId
				, PT.[Type]						AS ClientMainPhoneType
				, CP4.ClientSecondPhoneNumber	AS ClientSecondPhoneNumber
				, CP4.ClientSecondPhoneTypeId	AS ClientSecondPhoneTypeId
				, CP4.ClientSecondPhoneType		AS ClientSecondPhoneType
				, CP7.ClientOtherPhoneNumbers	AS ClientOtherPhoneNumbers
			FROM ClientPhone CP
			INNER JOIN PhoneType PT ON PT.Id = CP.PhoneTypeId
			LEFT JOIN (			
					SELECT 
						CP2.ClientId					AS ClientId
						, CP2.PhoneNumber				AS ClientSecondPhoneNumber
						, CP2.PhoneTypeId				AS ClientSecondPhoneTypeId
						, PT2.[Type]					AS ClientSecondPhoneType
					FROM ClientPhone CP2
					INNER JOIN PhoneType PT2 ON PT2.Id = CP2.PhoneTypeId
					INNER JOIN (SELECT CP3.ClientId, MIN(CP3.Id) AS Id
								FROM ClientPhone CP3
								WHERE CP3.DefaultNumber = 'False'
								GROUP BY CP3.ClientId) CP3B ON CP3B.Id = CP2.Id
					WHERE CP2.DefaultNumber = 'False'
					) CP4 ON CP4.ClientId = CP.ClientId
			LEFT JOIN (			
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
					AND CP5.DefaultNumber = 'False'
					) CP7 ON CP7.ClientId = CP.ClientId
			WHERE CP.DefaultNumber = 'True'
			;

		GO
		/*********************************************************************************************************************/