/*
 * SCRIPT: Create Table DashboardMeterData_Client 
 * Author: Robert Newnham
 * Created: 05/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_14.01_CreateTableDashboardMeterData_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DashboardMeterData_Client';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_Client'
		
		/*
		 *	Create DashboardMeterData_Client Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_Client', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_Client;
		END

		CREATE TABLE DashboardMeterData_Client(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_ClientOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, TotalClients INT NOT NULL DEFAULT 0
			, RegisteredOnlineToday INT NOT NULL DEFAULT 0
			, RegisteredToday INT NOT NULL DEFAULT 0
			, RegisteredOnlineYesterday INT NOT NULL DEFAULT 0
			, RegisteredYesterday INT NOT NULL DEFAULT 0
			, NumberOfUnpaidCourses INT NOT NULL DEFAULT 0
			, TotalAmountUnpaid MONEY NOT NULL DEFAULT 0
			, ClientsWithRequirementsRegisteredOnlineToday INT NOT NULL DEFAULT 0
			, TotalUpcomingClientsWithRequirements INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_Client_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_Course'
		
		/*
		 *	Create DashboardMeterData_Course Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_Course', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_Course;
		END

		CREATE TABLE DashboardMeterData_Course(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_CourseOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, CoursesWithoutAttendance INT NOT NULL DEFAULT 0
			, CoursesWithoutAttendanceVerfication INT NOT NULL DEFAULT 0
			, TotalAmountUnpaid MONEY NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_Course_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_DocumentStat'
		
		/*
		 *	Create DashboardMeterData_DocumentStat Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_DocumentStat', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_DocumentStat;
		END

		CREATE TABLE DashboardMeterData_DocumentStat(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_DocumentStatOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, TotalSize BIGINT NOT NULL DEFAULT 0
			, NumberOfDocumentsThisMonth BIGINT NOT NULL DEFAULT 0
			, TotalSizeOfDocumentsThisMonth BIGINT NOT NULL DEFAULT 0
			, NumberOfDocumentsPreviousMonth BIGINT NOT NULL DEFAULT 0
			, TotalSizeOfDocumentsPreviousMonth BIGINT NOT NULL DEFAULT 0
			, NumberOfDocumentsThisYear BIGINT NOT NULL DEFAULT 0
			, TotalSizeOfDocumentsThisYear BIGINT NOT NULL DEFAULT 0
			, NumberOfDocumentsPreviousYear BIGINT NOT NULL DEFAULT 0
			, TotalSizeOfDocumentsPreviousYear BIGINT NOT NULL DEFAULT 0
			, NumberOfDocumentsPreviousTwoYears BIGINT NOT NULL DEFAULT 0
			, TotalSizeOfDocumentsPreviousTwoYears BIGINT NOT NULL DEFAULT 0
			, NumberOfDocumentsPreviousThreeYears BIGINT NOT NULL DEFAULT 0
			, TotalSizeOfDocumentsPreviousThreeYears BIGINT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_DocumentStat_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_DORSOfferWithdrawn'
		
		/*
		 *	Create DashboardMeterData_DORSOfferWithdrawn Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_DORSOfferWithdrawn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_DORSOfferWithdrawn;
		END

		CREATE TABLE DashboardMeterData_DORSOfferWithdrawn(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_DORSOfferWithdrawnOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, TotalCreatedToday INT NOT NULL DEFAULT 0
			, TotalCreatedYesterday INT NOT NULL DEFAULT 0
			, TotalCreatedThisWeek INT NOT NULL DEFAULT 0
			, TotalCreatedThisMonth INT NOT NULL DEFAULT 0
			, TotalCreatedPreviousMonth INT NOT NULL DEFAULT 0
			, TotalCreatedTwoMonthsAgo INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_DORSOfferWithdrawn_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_Email'
		
		/*
		 *	Create DashboardMeterData_Email Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_Email', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_Email;
		END

		CREATE TABLE DashboardMeterData_Email(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_EmailOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, EmailsSentToday INT NOT NULL DEFAULT 0
			, EmailsSentYesterday INT NOT NULL DEFAULT 0
			, EmailsSentThisMonth INT NOT NULL DEFAULT 0
			, EmailsSentLastMonth INT NOT NULL DEFAULT 0
			, ScheduledEmails INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_Email_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_OnlineClientsSpecialRequirement'
		
		/*
		 *	Create DashboardMeterData_OnlineClientsSpecialRequirement Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_OnlineClientsSpecialRequirement', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_OnlineClientsSpecialRequirement;
		END

		CREATE TABLE DashboardMeterData_OnlineClientsSpecialRequirement(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_OnlineClientsSpecialRequirementOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, ClientsWithRequirementsRegisteredOnlineToday INT NOT NULL DEFAULT 0
			, TotalUpcomingClientsWithRequirements INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_OnlineClientsSpecialRequirement_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_Payment'
		
		/*
		 *	Create DashboardMeterData_Payment Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_Payment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_Payment;
		END

		CREATE TABLE DashboardMeterData_Payment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_PaymentOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, NumberOfPaymentsTakenToday INT NOT NULL DEFAULT 0
			, NumberOfPaymentsTakenYesterday INT NOT NULL DEFAULT 0
			, NumberOfPaymentsTakenThisWeek INT NOT NULL DEFAULT 0
			, NumberOfPaymentsTakenThisMonth INT NOT NULL DEFAULT 0
			, NumberOfPaymentsTakenPreviousMonth INT NOT NULL DEFAULT 0
			, NumberOfPaymentsTakenThisYear INT NOT NULL DEFAULT 0
			, NumberOfPaymentsTakenPreviousYear INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenToday INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenYesterday INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenThisWeek INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenThisMonth INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenPreviousMonth INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenThisYear INT NOT NULL DEFAULT 0
			, NumberOfOnlinePaymentsTakenPreviousYear INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenToday INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenYesterday INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenThisWeek INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenThisMonth INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenPreviousMonth INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenThisYear INT NOT NULL DEFAULT 0
			, NumberOfUnallocatedPaymentsTakenPreviousYear INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenToday INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenYesterday INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenThisWeek INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenThisMonth INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenPreviousMonth INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenThisYear INT NOT NULL DEFAULT 0
			, NumberOfRefundedPaymentsTakenPreviousYear INT NOT NULL DEFAULT 0
			, PaymentSumTakenToday MONEY NOT NULL DEFAULT 0
			, PaymentSumTakenYesterday MONEY NOT NULL DEFAULT 0
			, PaymentSumTakenThisWeek MONEY NOT NULL DEFAULT 0
			, PaymentSumTakenThisMonth MONEY NOT NULL DEFAULT 0
			, PaymentSumTakenPreviousMonth MONEY NOT NULL DEFAULT 0
			, PaymentSumTakenThisYear MONEY NOT NULL DEFAULT 0
			, PaymentSumTakenPreviousYear MONEY NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_Payment_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_UnpaidBookedCourse'
		
		/*
		 *	Create DashboardMeterData_UnpaidBookedCourse Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_UnpaidBookedCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_UnpaidBookedCourse;
		END

		CREATE TABLE DashboardMeterData_UnpaidBookedCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_UnpaidBookedCourseOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, TotalNumberUnpaid INT NOT NULL DEFAULT 0
			, TotalAmountUnpaid INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_UnpaidBookedCourse_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;