
		--Course Trainer Default Contact Details
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerDefaultContactInformation', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerDefaultContactInformation;
		END		
		GO
		/*
			Create vwTrainerDefaultContactInformation
		*/
		CREATE VIEW vwTrainerDefaultContactInformation 
		AS	
			SELECT 
				T.Id					AS TrainerId
				, T.DisplayName			AS TrainerName
				, T.DateOfBirth			AS TrainerDateOfBirth
				, T.UserId				AS TrainerUserId
				, T.GenderId			AS TrainerGenderId
				, G.[Name]				AS TrainerGender
				--------------------------------------------------------------
				, (CASE WHEN E.Id IS NULL 
						THEN (CASE WHEN TEO.Id IS NOT NULL
										AND TEO.EmailAddress IS NOT NULL
									THEN TEO.EmailAddress
									ELSE '' END)
						ELSE E.[Address]
						END )			AS TrainerEmail
				--------------------------------------------------------------
				, (CASE WHEN L.Id IS NULL 
						THEN (CASE WHEN TLO.Id IS NOT NULL
										AND TLO.[Address] IS NOT NULL
									THEN TLO.[Address]
									ELSE '' END)
						ELSE ISNULL(L.[Address], '')
						END )			AS TrainerAddress
				, (CASE WHEN L.Id IS NULL 
						THEN (CASE WHEN TLO.Id IS NOT NULL
										AND TLO.PostCode IS NOT NULL
									THEN TLO.PostCode
									ELSE '' END)
						ELSE ISNULL(L.PostCode, '')
						END )			AS TrainerPostCode
				--------------------------------------------------------------
			FROM [dbo].[Trainer] T
			INNER JOIN [dbo].[Gender] G					ON G.Id = T.GenderId
			----------------------------------------------------------------------------------------
			LEFT JOIN [dbo].[TrainerEmail] TE_Main		ON TE_Main.TrainerId = T.Id
														AND TE_Main.MainEmail = 'True'
			LEFT JOIN Email E							ON E.Id = TE_Main.EmailId
			LEFT JOIN (SELECT TOP 1 TE_Other.Id, TE_Other.TrainerId, TE_Other.EmailId, TEO_E.[Address] AS EmailAddress
						FROM [dbo].[TrainerEmail] TE_Other
						INNER JOIN Email TEO_E ON TEO_E.Id = TE_Other.EmailId
						WHERE TE_Other.MainEmail = 'False'
						) TEO							ON TEO.TrainerId = T.Id
			----------------------------------------------------------------------------------------
			LEFT JOIN [dbo].[TrainerLocation] TL_Main	ON TL_Main.TrainerId = T.Id
														AND TL_Main.MainLocation = 'True'
			LEFT JOIN [dbo].[Location] L				ON L.Id = TL_Main.LocationId
			LEFT JOIN (SELECT TOP 1 TL_Other.Id, TL_Other.TrainerId, TL_Other.LocationId, TLO_L.[Address] AS [Address], TLO_L.PostCode AS PostCode
						FROM [dbo].[TrainerLocation] TL_Other
						INNER JOIN [dbo].[Location] TLO_L ON TLO_L.Id = TL_Other.LocationId
						WHERE TL_Other.MainLocation = 'False'
						) TLO							ON TLO.TrainerId = T.Id
			----------------------------------------------------------------------------------------
			
			;
		GO
		/*********************************************************************************************************************/
		