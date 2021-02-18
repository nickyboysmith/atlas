/*
 * SCRIPT: Fix Missing Data in OrganisationPayment
 * Author: Robert Newnham
 * Created: 22/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_04.01_FixMissingDataOrganisationPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Fix Missing Data in OrganisationPayment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		INSERT INTO dbo.OrganisationPayment (OrganisationId, PaymentId)
		SELECT CO.OrganisationId, CP.PaymentId
		FROM dbo.ClientPayment CP
		INNER JOIN dbo.ClientOrganisation CO ON CO.ClientId = CP.ClientId
		LEFT JOIN dbo.OrganisationPayment OP ON OP.OrganisationId = CO.OrganisationId
											AND OP.PaymentId = CP.PaymentId
		WHERE OP.Id IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

