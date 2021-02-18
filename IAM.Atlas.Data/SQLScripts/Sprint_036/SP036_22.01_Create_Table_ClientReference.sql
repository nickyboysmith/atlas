/*
	SCRIPT: Create Client Reference Table
	Author: Robert Newnham
	Created: 26/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_22.01_Create_Table_ClientReference.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Report ClientReference Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientReference'
		
		/*
		 *	Create ClientReference Table
		 */
		IF OBJECT_ID('dbo.ClientReference', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientReference;
		END

		CREATE TABLE ClientReference(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL INDEX IX_ClientReferenceClientId NONCLUSTERED
			, IsPoliceReference bit NOT NULL DEFAULT 'False' INDEX IX_ClientReferenceIsPoliceReference NONCLUSTERED
			, Reference VARCHAR(100) NOT NULL INDEX IX_ClientReferenceReference NONCLUSTERED
			, CreatedByUserId INT NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT FK_ClientReference_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientReference_CreatedByUser FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_ClientReference_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;