
		-- Clients To Be Unlocked
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientsToBeUnlocked', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientsToBeUnlocked;
		END		
		GO
		/*
			Create vwClientsToBeUnlocked
		*/
		CREATE VIEW vwClientsToBeUnlocked
		AS	
			SELECT cl.Id
			FROM Client cl
			INNER JOIN ClientOrganisation co on co.ClientId = cl.Id
			INNER JOIN OrganisationSelfConfiguration osc on osc.OrganisationId =  co.OrganisationId
			WHERE cl.DateTimeLocked is not null 
			AND DATEADD(MINUTE, ISNULL(MaximumMinutesToLockClientsFor, 120), cl.DateTimeLocked) < GETDATE()
			;
		GO
		/*********************************************************************************************************************/
		