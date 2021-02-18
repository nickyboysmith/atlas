/*
 * SCRIPT: Correct Duplicate Data if Any on Table Venue
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_20.04_CorrectDuplicateDataOnTableVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct Duplicate Data if Any on Table Venue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/* DELETE the Duplicates */
		DELETE V3
		FROM dbo.Venue V3
		INNER JOIN ( /* Used to Find the Duplicates */
				--This Bit find Duplicate Titles per Organisation
				SELECT V4.OrganisationId, V4.Title, COUNT(*) CNT
				FROM dbo.Venue V4
				GROUP BY V4.OrganisationId, V4.Title
				HAVING COUNT(*) > 1
				) V5 ON V5.OrganisationId = V3.OrganisationId
					AND V5.Title = V3.Title
		LEFT JOIN ( /* Will be used to Exclude the first of the Duplicates */
			--This bit Find's the First of the Duplicates Created
			SELECT V2.OrganisationId, V2.Title, MIN(V2.Id) AS FirstIdCreated
			FROM (
				--This Bit find Duplicate Titles per Organisation
				SELECT V.OrganisationId, V.Title, COUNT(*) CNT
				FROM dbo.Venue V
				GROUP BY V.OrganisationId, V.Title
				HAVING COUNT(*) > 1) V1
			INNER JOIN dbo.Venue V2 ON V2.OrganisationId = V1.OrganisationId
									AND V2.Title = V1.Title
			GROUP BY V2.OrganisationId, V2.Title
			) V7 ON V7.OrganisationId = V3.OrganisationId
				AND V7.Title = V3.Title
		WHERE V7.FirstIdCreated != V3.Id /* Exclude the first of the Duplicates */
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;