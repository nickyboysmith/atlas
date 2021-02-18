/*
 * SCRIPT: Alter Table PaymentMethod - add in OrganisationId and Disabled Columns
 * Author: Dan Hough
 * Created: 24/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_03.01_AmendPaymentMethod.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add OrganisationId and Disabled columns to PaymentMethod table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.PaymentMethod
		  ADD OrganisationId int
		, [Disabled] bit 
	    , CONSTRAINT FK_PaymentMethod_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;