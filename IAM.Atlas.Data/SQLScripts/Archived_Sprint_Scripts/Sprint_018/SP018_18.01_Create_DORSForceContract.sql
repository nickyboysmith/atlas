/*
	SCRIPT: Create DORSForceContract Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_18.01_Create_DORSForceContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSForceContract Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSForceContract'
		
		/*
		 *	Create DORSForceContract Table
		 */
		IF OBJECT_ID('dbo.DORSForceContract', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSForceContract;
		END

		CREATE TABLE DORSForceContract(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , ForceContractID int 
			, ForceID int
			, SchemeID int
			, StartDate DateTime
			, EndDate DateTime
			, CourseAdminFee decimal
			, AccreditationID int
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;