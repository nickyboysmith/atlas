

		/*
			Drop the View if it already exists
			NB - Used in vwCourseInterpretersWithoutEmail
		*/
		IF OBJECT_ID('dbo.vwInterpreterPhoneRow', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterPhoneRow;
		END		
		GO
		/*
			Create vwInterpreterPhoneRow
		*/
		CREATE VIEW dbo.vwInterpreterPhoneRow 
		AS
			SELECT
				IP.Id
				, IP.InterpreterId							AS InterpreterId
				, IP.Number									AS InterpreterMainPhoneNumber
				, PT.Id										AS InterpreterMainPhoneTypeId
				, PT.[Type]									AS InterpreterMainPhoneType
				, (CASE WHEN IP3B.Id = IP.Id
						THEN NULL
						ELSE IP3B.InterpreterSecondPhoneNumber
						END)								AS InterpreterSecondPhoneNumber
				, (CASE WHEN IP3B.Id = IP.Id
						THEN NULL
						ELSE IP3B.InterpreterSecondPhoneTypeId
						END)								AS InterpreterSecondPhoneTypeId
				, (CASE WHEN IP3B.Id = IP.Id
						THEN NULL
						ELSE IP3B.InterpreterSecondPhoneType
						END)								AS InterpreterSecondPhoneType
			FROM InterpreterPhone IP

			INNER JOIN PhoneType PT ON PT.Id = IP.PhoneTypeId
			INNER JOIN (SELECT IP2.InterpreterId, MIN(IP2.Id) AS Id
						FROM InterpreterPhone IP2
						GROUP BY IP2.InterpreterId
						) IP2A ON IP2A.InterpreterId = IP.InterpreterId
								AND IP2A.Id = IP.Id
			LEFT JOIN ( --Use The Last One Entered as the Second Number
						SELECT
							IPO.Id
							, IPO.InterpreterId		AS InterpreterId
							, IPO.Number			AS InterpreterSecondPhoneNumber
							, PTO.Id				AS InterpreterSecondPhoneTypeId
							, PTO.[Type]			AS InterpreterSecondPhoneType
						FROM InterpreterPhone IPO
						INNER JOIN PhoneType PTO ON PTO.Id = IPO.PhoneTypeId
						INNER JOIN (SELECT IP3.InterpreterId, MAX(IP3.Id) AS Id
									FROM InterpreterPhone IP3
									GROUP BY IP3.InterpreterId
									) IP3A ON IP3A.InterpreterId = IPO.InterpreterId
											AND IP3A.Id = IPO.Id
						) IP3B ON IP3B.InterpreterId = IP.InterpreterId
			;

			GO
		/*********************************************************************************************************************/