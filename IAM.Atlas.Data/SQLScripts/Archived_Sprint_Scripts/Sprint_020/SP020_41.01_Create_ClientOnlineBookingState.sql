/*
	SCRIPT: Create ClientOnlineBookingState Table
	Author: Dan Hough
	Created: 19/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_41.01_Create_ClientOnlineBookingState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientOnlineBookingState Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientOnlineBookingState'
		
		/*
		 *	Create ClientOnlineBookingState Table
		 */
		IF OBJECT_ID('dbo.ClientOnlineBookingState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientOnlineBookingState;
		END

		CREATE TABLE ClientOnlineBookingState(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT
			, DetailsRecorded BIT DEFAULT 0
			, DORSSchemeId INT NULL
			, AvailableForDORSScheme BIT DEFAULT 0
			, ConfirmedName BIT DEFAULT 0
			, ConfirmedCourseAttendance BIT DEFAULT 0
			, ConfirmedWillPayCourseSupplier BIT DEFAULT 0
			, CompletedSpecialRequirements BIT DEFAULT 0
			, CourseBooked BIT DEFAULT 0
			, CourseId INT NULL
			, DateTimeCourseBooked DATETIME
			, AgreedToTermsAndConditions BIT
			, DateTimeAgreedToTermsAndConditions DATETIME
			, CONSTRAINT FK_ClientOnlineBookingState_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientOnlineBookingState_DORSSCheme FOREIGN KEY (DORSSchemeId) REFERENCES DORSScheme(Id)
			, CONSTRAINT FK_ClientOnlineBookingState_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;