
		-- vwTrainingSession
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainingSession', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainingSession;
		END		
		GO
		/*
			Create vwTrainingSession
		*/
		CREATE VIEW vwTrainingSession
		AS	
			SELECT 
				TS.Number		AS SessionNumber
				, Title			AS SessionTitle
				, StartTime		AS SessionStartTime
				, EndTime		AS SessionEndTime
			FROM TrainingSession TS
			--UNION
			--SELECT 
			--	12				AS SessionNumber
			--	, (SELECT TOP 1 TS1.Title FROM TrainingSession TS1 WHERE TS1.Number = 1)
			--		+ ' & ' + (SELECT TOP 1 TS2.Title FROM TrainingSession TS2 WHERE TS2.Number = 2)
			--					AS SessionTitle
			--	, ''			AS SessionStartTime
			--	, ''			AS SessionEndTime
			--UNION
			--SELECT 
			--	13				AS SessionNumber
			--	, (SELECT TOP 1 TS1.Title FROM TrainingSession TS1 WHERE TS1.Number = 1)
			--		+ ' & ' + (SELECT TOP 1 TS3.Title FROM TrainingSession TS3 WHERE TS3.Number = 3)
			--					AS SessionTitle
			--	, ''			AS SessionStartTime
			--	, ''			AS SessionEndTime
			--UNION
			--SELECT 
			--	23				AS SessionNumber
			--	, (SELECT TOP 1 TS2.Title FROM TrainingSession TS2 WHERE TS2.Number = 2)
			--		+ ' & ' + (SELECT TOP 1 TS3.Title FROM TrainingSession TS3 WHERE TS3.Number = 3)
			--					AS SessionTitle
			--	, ''			AS SessionStartTime
			--	, ''			AS SessionEndTime
			;
		GO
		/*********************************************************************************************************************/
		