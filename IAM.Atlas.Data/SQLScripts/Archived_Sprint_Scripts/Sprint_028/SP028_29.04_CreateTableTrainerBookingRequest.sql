/*
 * SCRIPT: Create TrainerBookingRequest Table
 * Author: Robert Newnham
 * Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_29.04_CreateTableTrainerBookingRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerBookingRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerBookingRequest'
		
		/*
		 *	Create TrainerBookingRequest Table
		 */
		IF OBJECT_ID('dbo.TrainerBookingRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerBookingRequest;
		END
		
		CREATE TABLE TrainerBookingRequest(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [TrainerId] INT NOT NULL
			, [Date] DATETIME NOT NULL
			, [SessionNumber] INT NOT NULL
			, [CourseId] INT NOT NULL
			, [DateRequested] DATETIME DEFAULT GETDATE()
			, [RequestAccepted] BIT DEFAULT 'False'
			, [DateRequestAccepted] DATETIME
			, CONSTRAINT FK_TrainerBookingRequest_Trainer FOREIGN KEY (TrainerId) REFERENCES [Trainer](Id)
			, CONSTRAINT FK_TrainerBookingRequest_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

