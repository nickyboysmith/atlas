/*
	SCRIPT: Create ReferringAuthorityUserDepartment Table
	Author: Dan Murray	
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_04.01_Create_ReferringAuthorityUserDepartment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReferringAuthorityUserDepartment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityUserDepartment'
		
		/*
		 *	Create ReferringAuthorityClient Table
		 */
		IF OBJECT_ID('dbo.ReferringAuthorityUserDepartment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityUserDepartment;
		END

		CREATE TABLE ReferringAuthorityUserDepartment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , ReferringAuthorityId INT
		  , ReferringAuthorityUserId INT		  
		  , CONSTRAINT FK_ReferringAuthorityUserDepartment_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES [ReferringAuthority](Id)
		  , CONSTRAINT FK_ReferringAuthorityUserDepartment_ReferringAuthorityUser FOREIGN KEY (ReferringAuthorityUserId) REFERENCES [ReferringAuthorityUser](Id)
		  
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;