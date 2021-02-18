
		--Trainers Within PostalArea And District
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainersWithinPostalAreaAndDistrict', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainersWithinPostalAreaAndDistrict;
		END		
		GO
		/*
			Create vwTrainersWithinPostalAreaAndDistrict
		*/
		CREATE VIEW vwTrainersWithinPostalAreaAndDistrict AS
		
					SELECT tro.OrganisationId						AS OrganisationId
						 , dbo.ufn_GetPostCodeArea( l.PostCode)		AS PostalArea			
						 , dbo.ufn_GetPostCodeDistrict( l.PostCode)	AS PostalDistrict			
						 , tr.Id									AS TrainerId
						 , tr.FirstName + ' ' + tr.Surname			AS TrainerName
						 , tr.DateOfBirth							AS TrainerDateofBirth
						 , g.Name									AS TrainerGender
					
					FROM  Trainer tr	
						  LEFT JOIN TrainerLocation tl
						  ON tr.id = tl.TrainerId
						  LEFT JOIN Location l
						  ON l.Id = tl.LocationId	
						  LEFT JOIN TrainerOrganisation tro
						  ON tro.TrainerId = tr.Id
						  LEFT JOIN Gender g
						  ON tr.GenderId = g.Id								
		GO
		/*********************************************************************************************************************/
