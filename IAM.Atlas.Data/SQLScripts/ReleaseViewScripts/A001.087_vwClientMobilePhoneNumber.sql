
		--Create dbo.vwClientMobilePhoneNumber
		-- NB. This view is used within view "vwCourseClientWithSMSRemindersDue"
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientMobilePhoneNumber', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientMobilePhoneNumber;
		END		

		GO
		/*
			Create vwClientMobilePhoneNumber
		*/
		CREATE VIEW dbo.vwClientMobilePhoneNumber
		AS		
			SELECT 
				CP.ClientId				AS ClientId
				, CP.PhoneNumber		AS PhoneNumber
				, CP.DefaultNumber		AS DefaultNumber
			FROM ClientPhone CP
			INNER JOIN PhoneType PT		ON PT.Id = CP.PhoneTypeId
			WHERE PT.[Type] = 'Mobile'
		GO
		
		/*********************************************************************************************************************/
		