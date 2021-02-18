/*
 * SCRIPT: Alter Table ClientPhone - Part 4
 * Author: Robert Newnham
 * Created: 08/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_02.04_Amend_ClientPhoneAddDefault_Part4.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new columns to table ClientPhone';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		--Set the First Number as Default. Update the empty dates.
		DECLARE @SetDate DateTime;
		SET @SetDate =  Getdate() -1;
		UPDATE dbo.ClientPhone
		SET DateAdded = (CASE WHEN DateAdded IS NULL THEN @SetDate ELSE DateAdded END)
		, DefaultNumber = (CASE WHEN DefaultNumber IS NULL 
								THEN 'False' 
								ELSE DefaultNumber 
								END)
		;
		
		UPDATE dbo.ClientPhone
		SET DefaultNumber = 'True'
		WHERE ClientId IN (SELECT DISTINCT ClientId 
							FROM (SELECT ClientId, Count(*) AS TheCount
								FROM dbo.ClientPhone
								GROUP BY ClientId
								HAVING Count(*) = 1) CP_CNT
							)
		;

				 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;