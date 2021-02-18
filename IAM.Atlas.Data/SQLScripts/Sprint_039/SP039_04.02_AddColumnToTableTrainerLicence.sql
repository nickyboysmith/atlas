/*
	SCRIPT: Add Column To Table TrainerLicence
	Author: Robert Newnham
	Created: 12/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_04.02_AddColumnToTableTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table TrainerLicence';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE TL
		SET DateCreated = DATEADD(DAY, -30, GETDATE())
		FROM (SELECT TrainerId, MAX([LicenceExpiryDate]) AS [LicenceExpiryDate]
					FROM [dbo].[TrainerLicence]
					GROUP BY TrainerId) T
		INNER JOIN [dbo].[TrainerLicence] TL ON TL.TrainerId = T.TrainerId
		WHERE TL.LicenceExpiryDate != T.LicenceExpiryDate
		;
		
		--Also a bit of DB Tidy
		UPDATE TL
		SET TL.MainLocation = (CASE WHEN TL.Id = T.maxId THEN 'True' ELSE 'False' END)
		FROM (SELECT [TrainerId], MAX(Id) AS maxId
			FROM [dbo].[TrainerLocation]
			GROUP BY [TrainerId]) T
		INNER JOIN [dbo].[TrainerLocation] TL ON TL.TrainerId = T.TrainerId
		;
		
		DELETE TL
		FROM (
			SELECT L.Id
			FROM [Location] L
			WHERE LEN(ISNULL(L.[Address],'')) <= 0
			AND LEN(ISNULL(L.PostCode,'')) <= 0) T
		INNER JOIN [TrainerLocation] TL ON TL.LocationId = T.Id
	
		DELETE TL
		FROM (
			SELECT L.Id
			FROM [Location] L
			WHERE LEN(ISNULL(L.[Address],'')) <= 0
			AND LEN(ISNULL(L.PostCode,'')) <= 0) T
		INNER JOIN [ClientLocation] TL ON TL.LocationId = T.Id
	
		DELETE TL
		FROM (
			SELECT L.Id
			FROM [Location] L
			WHERE LEN(ISNULL(L.[Address],'')) <= 0
			AND LEN(ISNULL(L.PostCode,'')) <= 0) T
		INNER JOIN VenueAddress TL ON TL.LocationId = T.Id
	
		DELETE L
		FROM [Location] L
		WHERE LEN(ISNULL(L.[Address],'')) <= 0
		AND LEN(ISNULL(L.PostCode,'')) <= 0

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END