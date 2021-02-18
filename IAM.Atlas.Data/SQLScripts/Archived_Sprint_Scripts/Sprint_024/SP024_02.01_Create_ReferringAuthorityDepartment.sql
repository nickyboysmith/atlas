/*
	SCRIPT: Create ReferringAuthorityDepartment Table
	Author: Dan Murray	
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_02.01_Create_ReferringAuthorityDepartment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReferringAuthorityDepartment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityDepartment'
		
		/*
		 *	Create ReferringAuthorityDepartment Table
		 */
		IF OBJECT_ID('dbo.ReferringAuthorityDepartment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityDepartment;
		END

		CREATE TABLE ReferringAuthorityDepartment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , ReferringAuthorityId INT
		  , Name VARCHAR(100)
		  , Description VARCHAR(100)
		  , Disabled BIT DEFAULT (0)
		  , DateCreated DATETIME
		  , CreatedByUserId INT		  
		  , CONSTRAINT FK_ReferringAuthorityDepartment_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES [ReferringAuthority](Id)
		  , CONSTRAINT FK_ReferringAuthorityDepartment_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		  
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;