/*
	SCRIPT: Create a function to Split a Word With Upper Case Characters into it's Words
	Author: Robert Newnham
	Created: 26/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_04.01_CreateFunctionudfGetVatRateByDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return the VAT Rate based on Date';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetVatRateByDate', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetVatRateByDate;
	END		
	GO
	
	/*
		Create udfGetVatRateByDate
	*/
	CREATE FUNCTION [dbo].[udfGetVatRateByDate] (@effectiveDate DATETIME)
	RETURNS FLOAT
	AS
	BEGIN
		DECLARE @VATRate FLOAT = 0;

		SELECT TOP(1) @VATRate =VATRate
		FROM dbo.VatRate
		WHERE EffectiveFromDate <= @effectiveDate
		ORDER BY EffectiveFromDate DESC;

		RETURN @VATRate;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_04.01_CreateFunctionudfGetVatRateByDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO