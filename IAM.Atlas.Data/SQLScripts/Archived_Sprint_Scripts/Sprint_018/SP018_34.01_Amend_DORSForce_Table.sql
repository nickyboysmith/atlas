/*
 * SCRIPT: Alter Table DORSForce - add in DORSForceId, and PNCCode
 * Author: Paul Tuck
 * Created: 05/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_34.01_Amend_DORSForce_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to DORSForce table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.DORSForce
		  ADD	DORSForceId int NULL,
				PNCCode varchar(20) NULL

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;