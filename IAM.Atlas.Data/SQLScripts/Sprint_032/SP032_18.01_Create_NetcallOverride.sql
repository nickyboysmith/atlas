/*
	SCRIPT: Create NetcallOverride Table 
	Author: Paul Tuck
	Created: 23/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_18.01_Create_NetcallOverride.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallOverride Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		CREATE TABLE NetcallOverride(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, CourseId INT NULL
			, DateAdded DateTime NOT NULL
			, AddedByUserId INT NOT NULL
			, Amount MONEY NOT NULL
			, Comment VARCHAR(200) NULL
			, [Disabled] BIT CONSTRAINT DF_NetcallOverride_Disabled  DEFAULT 'False'
			, DisabledByUserId INT NULL
			, CONSTRAINT FK_NetcallOverride_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_NetcallOverride_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_NetcallOverride_AddedByUser FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_NetcallOverride_DisabledByUser FOREIGN KEY (DisabledByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;