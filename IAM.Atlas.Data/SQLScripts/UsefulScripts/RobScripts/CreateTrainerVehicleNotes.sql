

IF OBJECT_ID('tempdb..#TempNote', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TempNote;
END

DECLARE @TheDate DateTime =  GETDATE();

SELECT TrainerVehicleId, TrainerId, Note, DateCreated, CreatedByUserId, Removed, NoteTypeId
INTO #TempNote
FROM (
		SELECT DISTINCT
			TV.Id AS TrainerVehicleId
			, TV.TrainerId AS TrainerId
			, 'This is a Test Note From the Trainer (AKA Instructor) about his Vehicle' 
				+ CHAR(13) + CHAR(10) + ' TrainerId: ' + CAST(TV.TrainerId AS VARCHAR)
				+ CHAR(13) + CHAR(10) + ' Vehicle: ' + TV.NumberPlate
						AS Note
			, @TheDate AS DateCreated
			, dbo.udfGetSystemUserId() AS CreatedByUserId
			, 'False' AS Removed
			, NT.Id AS NoteTypeId
		FROM NoteType NT
		, TrainerVehicle TV
		WHERE NT.[Name] = 'Instructor'
		UNION 
		SELECT DISTINCT
			TV.Id AS TrainerVehicleId
			, TV.TrainerId AS TrainerId
			, 'This is another Test Note From a User about This Vehicle' 
				+ CHAR(13) + CHAR(10) + ' TrainerId: ' + CAST(TV.TrainerId AS VARCHAR)
				+ CHAR(13) + CHAR(10) + ' Vehicle: ' + TV.NumberPlate
				+ CHAR(13) + CHAR(10) + ' and I say Blah Blah Blah'
						AS Note
			, @TheDate AS DateCreated
			, dbo.udfGetSystemUserId() AS CreatedByUserId
			, 'False' AS Removed
			, NT.Id AS NoteTypeId
		FROM NoteType NT
		, TrainerVehicle TV
		WHERE NT.[Name] = 'General'
		AND RIGHT(CAST(TV.TrainerId AS VARCHAR), 1) IN ('1', '3', '5', '7', '9')
		) T;

SELECT * FROM #TempNote;

INSERT INTO [dbo].[Note] (Note, DateCreated, CreatedByUserId, Removed, NoteTypeId)
SELECT Note, DateCreated, CreatedByUserId, Removed, NoteTypeId
FROM #TempNote;

INSERT INTO [dbo].[TrainerVehicleNote] (TrainerVehicleId, NoteId)
SELECT DISTINCT TN.TrainerVehicleId, N.Id
FROM #TempNote TN
INNER JOIN [dbo].[Note] N ON N.DateCreated = TN.DateCreated
							AND N.CreatedByUserId = TN.CreatedByUserId
							AND N.Note = TN.Note
LEFT JOIN [dbo].[TrainerVehicleNote] TVN ON TVN.TrainerVehicleId = TN.TrainerVehicleId
											AND TVN.NoteId = N.Id
WHERE TVN.Id IS NULL;

