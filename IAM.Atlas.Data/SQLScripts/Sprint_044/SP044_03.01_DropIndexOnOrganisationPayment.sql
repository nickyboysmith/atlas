/*
 * SCRIPT: Drop Index On OrganisationPayment
 * Author: Dan Hough
 * Created: 22/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_03.01_DropIndexOnOrganisationPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop Index On OrganisationPayment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF EXISTS(SELECT * 
					FROM sys.indexes
					WHERE [Name] ='UX_OrganisationPaymentPaymentId'
					and OBJECT_ID = OBJECT_ID('dbo.OrganisationPayment'))
		BEGIN
			DROP INDEX [UX_OrganisationPaymentPaymentId] ON [dbo].[OrganisationPayment]
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;