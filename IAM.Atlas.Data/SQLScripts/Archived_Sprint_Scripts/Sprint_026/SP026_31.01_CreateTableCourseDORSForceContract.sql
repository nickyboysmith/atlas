/*
	SCRIPT: Create CourseDORSForceContract Table
	Author: Robert Newnham
	Created: 22/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_31.01_CreateTableCourseDORSForceContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDORSForceContract Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDORSForceContract'
		
		/*
		 *	Create CourseDORSForceContract Table
		 */
		IF OBJECT_ID('dbo.CourseDORSForceContract', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDORSForceContract;
		END

		CREATE TABLE CourseDORSForceContract(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, DORSForceContractId INT NOT NULL
			, CONSTRAINT FK_CourseDORSForceContract_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDORSForceContract_DORSForceContractId FOREIGN KEY (DORSForceContractId) REFERENCES DORSForceContract(Id)
		);
		
		INSERT INTO CourseDORSForceContract (CourseId, DORSForceContractId)
		SELECT DISTINCT C.Id AS CourseId, ODFC.DORSForceContractId
		FROM Course C
		INNER JOIN [dbo].[OrganisationDORSForceContract] ODFC ON ODFC.OrganisationId = C.Id
		WHERE NOT EXISTS (SELECT * FROM CourseDORSForceContract CDFC WHERE CDFC.CourseId = C.Id AND CDFC.DORSForceContractId = ODFC.DORSForceContractId);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

