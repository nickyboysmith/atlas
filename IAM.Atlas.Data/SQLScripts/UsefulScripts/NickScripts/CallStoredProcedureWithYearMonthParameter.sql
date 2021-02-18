
-- Iterate through year month, call an SP with parameters

DECLARE @year INT;
DECLARE @month INT ;

SET @year = 2015;
SET @month = 0;

DECLARE trainers CURSOR
	FOR
		SELECT Id
		  FROM Trainer

	OPEN trainers

	DECLARE @Id INT;

	FETCH NEXT FROM trainers INTO @Id
	WHILE @@fetch_status = 0
	BEGIN

	SET @year = 2015;

	WHILE @year < 2018
		BEGIN
		SET @year = @year + 1;
		WHILE @month < 12
		BEGIN
			SET @month = @month + 1;

			BEGIN TRY
				
				PRINT Cast(@Id AS VARCHAR) + ', ' + Cast(@year AS VARCHAR) + ', ' + Cast(@month AS VARCHAR);

				--IF(@trainerId IS NOT NULL AND 
				--  @year IS NOT NULL AND 
				--  @month IS NOT NULL)

				EXEC dbo.uspUpdateTrainerSummaryForMonth @Id, @year, @month;
			END TRY
			BEGIN CATCH
				PRINT 'Failed for : ' + Cast(@Id AS VARCHAR) + ', ' + Cast(@year AS VARCHAR) + ', ' + Cast(@month AS VARCHAR) + ', ' + ERROR_MESSAGE();
			END CATCH

		END

		SET @month = 0;

	END

	FETCH NEXT FROM trainers INTO @Id

	END

	CLOSE trainers
	DEALLOCATE trainers

