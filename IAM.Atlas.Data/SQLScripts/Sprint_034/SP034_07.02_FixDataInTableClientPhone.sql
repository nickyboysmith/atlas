/*
 * SCRIPT: Fix Data In Table ClientPhone
 * Author: Robert Newnham
 * Created: 28/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP034_07.02_FixDataInTableClientPhone.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Fix Data In ClientPhone Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		UPDATE CP
		SET CP.DefaultNumber = 'False'
		FROM dbo.ClientPhone CP
		WHERE CP.DefaultNumber IS NULL;
		
		UPDATE CP
		SET CP.DateAdded = DATEADD(DAY, -1, GETDATE())
		FROM dbo.ClientPhone CP
		WHERE CP.DateAdded IS NULL;

		UPDATE CP
		SET CP.DefaultNumber = (CASE WHEN CP.Id = CPX.FirstId THEN 'True' ELSE 'False' END)
		FROM (SELECT ClientId
				, MIN(Id) AS FirstId
				, COUNT(*) AS CNT
				, SUM(CASE WHEN CP.DefaultNumber = 'True' THEN 1 ELSE 0 END) AS NumberOfDefaults
			FROM dbo.ClientPhone CP
			GROUP BY ClientId
			HAVING SUM(CASE WHEN CP.DefaultNumber = 'True' THEN 1 ELSE 0 END) = 0
					OR SUM(CASE WHEN CP.DefaultNumber = 'True' THEN 1 ELSE 0 END) > 1
			) CPX
		INNER JOIN dbo.ClientPhone CP ON CP.ClientId = CPX.ClientId
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
